package com.campuspass.backend.service;

import com.campuspass.backend.dto.SubscribeRequest;
import com.campuspass.backend.dto.AdminSubscriptionPaymentResponse;
import com.campuspass.backend.dto.AdminPaymentAlertsResponse;
import com.campuspass.backend.exception.ResourceNotFoundException;
import com.campuspass.backend.model.SubscriptionPayment;
import com.campuspass.backend.model.SubscriptionPlan;
import com.campuspass.backend.model.StudentSubscription;
import com.campuspass.backend.model.User;
import com.campuspass.backend.model.AdminAuditLog;
import com.campuspass.backend.model.enums.PaymentStatus;
import com.campuspass.backend.model.enums.SubscriptionPlanType;
import com.campuspass.backend.model.enums.SubscriptionStatus;
import com.campuspass.backend.repository.SubscriptionPlanRepository;
import com.campuspass.backend.repository.SubscriptionPaymentRepository;
import com.campuspass.backend.repository.StudentProfileRepository;
import com.campuspass.backend.repository.StudentSubscriptionRepository;
import com.campuspass.backend.repository.UserRepository;
import com.campuspass.backend.repository.AdminAuditLogRepository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.HttpStatusCodeException;
import org.springframework.web.client.RestTemplate;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;

@Service
public class SubscriptionService {
    private static final Logger log = LoggerFactory.getLogger(SubscriptionService.class);

    private final SubscriptionPlanRepository planRepository;
    private final SubscriptionPaymentRepository paymentRepository;
    private final StudentProfileRepository studentProfileRepository;
    private final StudentSubscriptionRepository subscriptionRepository;
    private final UserRepository userRepository;
    private final AdminAuditLogRepository adminAuditLogRepository;
    private final RestTemplate restTemplate = new RestTemplate();

    @Value("${yengapay.api-key:}")
    private String yengapayApiKey;
    // groupId correspond souvent au premier segment de l'URL checkout (ex: 70812)
    // site-id est gardé pour compatibilité: yengapay.group-id = (si présent) sinon yengapay.site-id
    @Value("${yengapay.group-id:${yengapay.site-id:}}")
    private String yengapayGroupId;
    // projectId correspond au slug de la page de paiement (ex: cmn5x...)
    @Value("${yengapay.project-id:}")
    private String yengapayProjectId;
    @Value("${yengapay.base-url:https://api.yengapay.com/api/v1}")
    private String yengapayBaseUrl;
    @Value("${yengapay.notify-url:}")
    private String yengapayNotifyUrl;
    @Value("${yengapay.return-url:}")
    private String yengapayReturnUrl;
    @Value("${yengapay.paylink-url:}")
    private String yengapayPaylinkUrl;
    @Value("${subscription.payment.sync.window-hours:24}")
    private long paymentSyncWindowHours;
    @Value("${subscription.payment.expire-after-minutes:30}")
    private long paymentExpireAfterMinutes;
    @Value("${subscription.payment.hot-sync.window-minutes:5}")
    private long paymentHotSyncWindowMinutes;

    public SubscriptionService(SubscriptionPlanRepository planRepository,
                              SubscriptionPaymentRepository paymentRepository,
                              StudentProfileRepository studentProfileRepository,
                              StudentSubscriptionRepository subscriptionRepository,
                              UserRepository userRepository,
                              AdminAuditLogRepository adminAuditLogRepository) {
        this.planRepository = planRepository;
        this.paymentRepository = paymentRepository;
        this.studentProfileRepository = studentProfileRepository;
        this.subscriptionRepository = subscriptionRepository;
        this.userRepository = userRepository;
        this.adminAuditLogRepository = adminAuditLogRepository;
    }

    /** Initie un paiement abonnement Yengapay. */
    @Transactional
    public Map<String, Object> subscribe(Long studentId, SubscribeRequest req) {
        boolean verified = studentProfileRepository.findByUserId(studentId)
                .map(sp -> Boolean.TRUE.equals(sp.getVerified()))
                .orElse(false);
        if (!verified) {
            throw new IllegalArgumentException("Ton statut etudiant doit etre verifie avant de t'abonner.");
        }

        SubscriptionPlan plan = planRepository.findById(req.getPlanId())
                .orElseThrow(() -> new ResourceNotFoundException("Plan", req.getPlanId()));
        if (!Boolean.TRUE.equals(plan.getActive())) {
            throw new IllegalArgumentException("Ce plan n'est plus disponible.");
        }
        Double amount = plan.getEffectivePrice(LocalDate.now());
        SubscriptionPayment pay = new SubscriptionPayment();
        pay.setStudentId(studentId);
        pay.setPlanId(plan.getId());
        pay.setAmount(amount);
        pay.setCurrency("FCFA");
        pay.setPaymentMethod(req.getPaymentMethod());
        pay.setPhoneNumber(req.getPhoneNumber());
        pay.setStatus(PaymentStatus.CREATED);
        pay.setCreatedAt(LocalDateTime.now());
        pay = paymentRepository.save(pay);

        if (!isYengapayConfigured()) {
            throw new IllegalStateException("Yengapay non configure. Renseigne yengapay.api-key, yengapay.group-id et yengapay.project-id.");
        }

        String transactionId = "CPASS-" + pay.getId() + "-" + System.currentTimeMillis();

        // API Payment Intent (sandbox/production) YengaPay.
        // On passe "reference" = transactionId pour pouvoir retrouver ce paiement dans le webhook.
        Map<String, Object> payload = new HashMap<>();
        payload.put("paymentAmount", Math.round(amount));
        payload.put("reference", transactionId);
        payload.put("articles", List.of(
                Map.of(
                        "title", "Abonnement Campus Pass",
                        "description", plan.getName(),
                        "price", Math.round(amount)
                )
        ));

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.set("x-api-key", yengapayApiKey);
        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(payload, headers);

        String paymentIntentUrl = yengapayBaseUrl + "/groups/" + yengapayGroupId + "/payment-intent/" + yengapayProjectId;
        log.info("Yengapay payment-intent init url={}", paymentIntentUrl);
        log.info("Yengapay payment-intent payload keys={} reference={}", payload.keySet(), transactionId);
        ResponseEntity<Map> initResp;
        try {
            initResp = restTemplate.postForEntity(paymentIntentUrl, entity, Map.class);
        } catch (HttpStatusCodeException ex) {
            // Permet de savoir rapidement si c'est un problème de permissions (403) ou autre.
            String body = ex.getResponseBodyAsString();
            log.error("Yengapay payment-intent failed status={} body={}", ex.getStatusCode(), body);
            throw ex;
        }

        Map<String, Object> providerBody = initResp.getBody() != null ? initResp.getBody() : Map.of();
        Map<String, Object> data = providerBody;
        Object nested = providerBody.get("data");
        if (nested instanceof Map<?, ?> m) {
            data = (Map<String, Object>) m;
        }

        // Selon la version YengaPay, l’URL peut apparaître sous plusieurs clés.
        String paymentUrl = null;
        String[] candidateKeys = new String[]{
                "payment_url",
                "paymentUrl",
                "checkout_url",
                "checkoutUrl",
                "redirect_url",
                "redirectUrl",
                "payment_intent_url",
                "paymentIntentUrl",
                "payment_page_url",
                "paymentPageUrl",
                "checkoutPageUrlWithPaymentToken"
        };
        for (String k : candidateKeys) {
            Object v = data.get(k);
            if (v != null) {
                String s = v.toString();
                if (!s.isBlank()) {
                    paymentUrl = s;
                    break;
                }
            }
        }
        if (paymentUrl == null || paymentUrl.isBlank()) {
            throw new IllegalStateException("Impossible d'initier le paiement Yengapay. Provider keys=" + data.keySet());
        }

        pay.setPaymentReference(transactionId);
        paymentRepository.save(pay);

        Map<String, Object> result = new HashMap<>();
        result.put("paymentId", pay.getId());
        result.put("amount", amount);
        result.put("paymentUrl", paymentUrl);
        result.put("message", "Paiement initialise. Termine le paiement puis appuie sur verifier.");
        return result;
    }

    /** Ancien endpoint OTP mock conservé pour compatibilite. */
    @Transactional
    public Map<String, Object> confirmOtp(Long studentId, Long paymentId, String otp) {
        SubscriptionPayment pay = paymentRepository.findById(paymentId)
                .orElseThrow(() -> new ResourceNotFoundException("Payment", paymentId));
        if (!pay.getStudentId().equals(studentId)) {
            throw new IllegalArgumentException("Paiement invalide.");
        }
        if (pay.getStatus() == PaymentStatus.SUCCESS) {
            return Map.of("success", true, "message", "Déjà validé.");
        }
        if (!"1234".equals(otp)) {
            throw new IllegalArgumentException("Code OTP incorrect.");
        }
        pay.setStatus(PaymentStatus.SUCCESS);
        pay.setPaidAt(LocalDateTime.now());
        pay.setPaymentReference("MOCK-" + paymentId);
        paymentRepository.save(pay);

        SubscriptionPlan plan = planRepository.findById(pay.getPlanId()).orElseThrow();
        LocalDate start = LocalDate.now();
        LocalDate end = plan.getType() == SubscriptionPlanType.YEARLY
                ? start.plusYears(1) : start.plusMonths(1);
        StudentSubscription sub = new StudentSubscription();
        sub.setStudentId(studentId);
        sub.setPlanId(plan.getId());
        sub.setStartDate(start);
        sub.setEndDate(end);
        sub.setStatus(SubscriptionStatus.ACTIVE);
        sub.setCreatedAt(LocalDateTime.now());
        subscriptionRepository.save(sub);

        return Map.of("success", true, "endDate", end.toString(), "message", "Abonnement activé.");
    }

    @Transactional
    public Map<String, Object> getPaymentStatus(Long studentId, Long paymentId) {
        SubscriptionPayment pay = paymentRepository.findById(paymentId)
                .orElseThrow(() -> new ResourceNotFoundException("Payment", paymentId));
        log.info(
                "payment-status check start paymentId={} studentId={} reference={} localStatus={}",
                pay.getId(),
                studentId,
                pay.getPaymentReference(),
                pay.getStatus()
        );
        if (!pay.getStudentId().equals(studentId)) {
            log.warn(
                    "payment-status denied paymentId={} expectedStudentId={} requesterStudentId={}",
                    pay.getId(),
                    pay.getStudentId(),
                    studentId
            );
            throw new IllegalArgumentException("Paiement invalide.");
        }
        if (pay.getStatus() == PaymentStatus.SUCCESS) {
            log.info("payment-status resolved paymentId={} reference={} finalStatus=SUCCESS source=local", pay.getId(), pay.getPaymentReference());
            return Map.of("success", true, "status", "SUCCESS", "message", "Paiement deja confirme.");
        }
        if (pay.getStatus() == PaymentStatus.FAILED) {
            log.info("payment-status resolved paymentId={} reference={} finalStatus=FAILED source=local", pay.getId(), pay.getPaymentReference());
            return Map.of("success", false, "status", "FAILED", "message", "Paiement échoué ou refusé.");
        }
        // Tente une vérification active côté fournisseur pour éviter les PENDING bloqués.
        return recheckAndSyncPayment(pay);
    }

    @Transactional
    public Map<String, Object> recheckPaymentAsAdmin(Long paymentId, Long adminUserId) {
        SubscriptionPayment pay = paymentRepository.findById(paymentId)
                .orElseThrow(() -> new ResourceNotFoundException("Payment", paymentId));
        Map<String, Object> result = recheckAndSyncPayment(pay);
        logAdminAction(
                adminUserId,
                "PAYMENT_RECHECK",
                paymentId,
                "resultStatus=" + Objects.toString(result.get("status"), "")
        );
        return result;
    }

    public List<AdminSubscriptionPaymentResponse> getAllSubscriptionPaymentsForAdmin() {
        return paymentRepository.findAllByOrderByCreatedAtDesc().stream()
                .filter(p -> p.getStatus() != PaymentStatus.CREATED)
                .map(p -> {
                    AdminSubscriptionPaymentResponse dto = new AdminSubscriptionPaymentResponse();
                    dto.setId(p.getId());
                    dto.setStudentId(p.getStudentId());
                    userRepository.findById(p.getStudentId()).ifPresent(u -> fillStudentInfo(dto, u));
                    dto.setPlanId(p.getPlanId());
                    planRepository.findById(p.getPlanId()).ifPresent(plan -> dto.setPlanName(plan.getName()));
                    dto.setAmount(p.getAmount());
                    dto.setCurrency(p.getCurrency());
                    dto.setPaymentMethod(p.getPaymentMethod() != null ? p.getPaymentMethod().name() : null);
                    dto.setStatus(p.getStatus() != null ? p.getStatus().name() : null);
                    dto.setPaymentReference(p.getPaymentReference());
                    dto.setPaidAt(p.getPaidAt());
                    dto.setCreatedAt(p.getCreatedAt());
                    dto.setLastSyncedAt(p.getLastSyncedAt());
                    enrichSubscriptionState(dto, p.getStudentId());
                    return dto;
                })
                .collect(Collectors.toList());
    }

    public AdminPaymentAlertsResponse getAdminPaymentAlerts() {
        final int pendingThresholdMinutes = 30;
        final double highFailureRateThreshold = 0.30;
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime pendingThresholdDate = now.minusMinutes(pendingThresholdMinutes);
        LocalDateTime since24h = now.minusHours(24);

        List<SubscriptionPayment> all = paymentRepository.findAllByOrderByCreatedAtDesc();
        int pendingTooLong = (int) all.stream()
                .filter(p -> p.getStatus() == PaymentStatus.PENDING)
                .filter(p -> p.getCreatedAt() != null && p.getCreatedAt().isBefore(pendingThresholdDate))
                .count();

        List<SubscriptionPayment> last24h = all.stream()
                .filter(p -> p.getCreatedAt() != null && !p.getCreatedAt().isBefore(since24h))
                .filter(p -> p.getStatus() != PaymentStatus.CREATED)
                .toList();
        int total24h = last24h.size();
        int failed24h = (int) last24h.stream()
                .filter(p -> p.getStatus() == PaymentStatus.FAILED)
                .count();
        double rate = total24h == 0 ? 0.0 : ((double) failed24h / (double) total24h);
        boolean highFailureRate = total24h >= 5 && rate >= highFailureRateThreshold;
        int criticalAlertsCount = 0;
        if (pendingTooLong >= 5) criticalAlertsCount++;
        if (highFailureRate) criticalAlertsCount++;
        String severity = criticalAlertsCount > 0 ? "CRITICAL" : (pendingTooLong > 0 ? "WARNING" : "OK");

        AdminPaymentAlertsResponse res = new AdminPaymentAlertsResponse();
        res.setLongPendingThresholdMinutes(pendingThresholdMinutes);
        res.setPendingTooLongCount(pendingTooLong);
        res.setTotalLast24h(total24h);
        res.setFailedLast24h(failed24h);
        res.setFailureRate24h(rate);
        res.setHighFailureRate(highFailureRate);
        res.setHasAlerts(pendingTooLong > 0 || highFailureRate);
        res.setSeverity(severity);
        res.setCriticalAlertsCount(criticalAlertsCount);
        return res;
    }

    @Transactional
    public Map<String, Object> relaunchPaymentAsAdmin(Long paymentId, Long adminUserId) {
        SubscriptionPayment previous = paymentRepository.findById(paymentId)
                .orElseThrow(() -> new ResourceNotFoundException("Payment", paymentId));
        SubscriptionPlan plan = planRepository.findById(previous.getPlanId())
                .orElseThrow(() -> new ResourceNotFoundException("Plan", previous.getPlanId()));
        if (!Boolean.TRUE.equals(plan.getActive())) {
            throw new IllegalArgumentException("Ce plan n'est plus disponible.");
        }
        if (previous.getPaymentMethod() == null || previous.getPhoneNumber() == null || previous.getPhoneNumber().isBlank()) {
            throw new IllegalArgumentException("Impossible de relancer: moyen de paiement ou numero manquant.");
        }

        SubscriptionPayment pay = new SubscriptionPayment();
        pay.setStudentId(previous.getStudentId());
        pay.setPlanId(previous.getPlanId());
        pay.setAmount(plan.getEffectivePrice(LocalDate.now()));
        pay.setCurrency("FCFA");
        pay.setPaymentMethod(previous.getPaymentMethod());
        pay.setPhoneNumber(previous.getPhoneNumber());
        pay.setStatus(PaymentStatus.CREATED);
        pay.setCreatedAt(LocalDateTime.now());
        pay = paymentRepository.save(pay);

        if (!isYengapayConfigured()) {
            throw new IllegalStateException("Yengapay non configure. Renseigne yengapay.api-key, yengapay.group-id et yengapay.project-id.");
        }

        String transactionId = "CPASS-" + pay.getId() + "-" + System.currentTimeMillis();
        Map<String, Object> payload = new HashMap<>();
        payload.put("paymentAmount", Math.round(pay.getAmount()));
        payload.put("reference", transactionId);
        payload.put("articles", List.of(
                Map.of(
                        "title", "Abonnement Campus Pass",
                        "description", plan.getName(),
                        "price", Math.round(pay.getAmount())
                )
        ));

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.set("x-api-key", yengapayApiKey);

        String paymentIntentUrl = yengapayBaseUrl + "/groups/" + yengapayGroupId + "/payment-intent/" + yengapayProjectId;
        log.info("Yengapay payment-intent relaunch url={}", paymentIntentUrl);
        ResponseEntity<Map> initResp;
        try {
            initResp = restTemplate.postForEntity(paymentIntentUrl, new HttpEntity<>(payload, headers), Map.class);
        } catch (HttpStatusCodeException ex) {
            String body = ex.getResponseBodyAsString();
            log.error("Yengapay payment-intent relaunch failed status={} body={}", ex.getStatusCode(), body);
            throw ex;
        }

        Map<String, Object> providerBody = initResp.getBody() != null ? initResp.getBody() : Map.of();
        Map<String, Object> data = providerBody;
        Object nested = providerBody.get("data");
        if (nested instanceof Map<?, ?> m) {
            data = (Map<String, Object>) m;
        }

        String paymentUrl = null;
        String[] candidateKeys = new String[]{
                "payment_url",
                "paymentUrl",
                "checkout_url",
                "checkoutUrl",
                "redirect_url",
                "redirectUrl",
                "payment_intent_url",
                "paymentIntentUrl",
                "payment_page_url",
                "paymentPageUrl",
                "checkoutPageUrlWithPaymentToken"
        };
        for (String k : candidateKeys) {
            Object v = data.get(k);
            if (v != null) {
                String s = v.toString();
                if (!s.isBlank()) {
                    paymentUrl = s;
                    break;
                }
            }
        }
        if (paymentUrl == null || paymentUrl.isBlank()) {
            throw new IllegalStateException("Impossible d'initier le paiement Yengapay. Provider keys=" + data.keySet());
        }
        pay.setPaymentReference(transactionId);
        paymentRepository.save(pay);

        Map<String, Object> result = Map.of(
                "paymentId", pay.getId(),
                "paymentUrl", paymentUrl,
                "message", "Lien de paiement regenere."
        );
        logAdminAction(
                adminUserId,
                "PAYMENT_RELAUNCH",
                pay.getId(),
                "fromPaymentId=" + paymentId + ", studentId=" + pay.getStudentId()
        );
        return result;
    }

    @Transactional
    public int autoSyncRecentPayments() {
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime expireBefore = now.minusMinutes(paymentExpireAfterMinutes);
        List<SubscriptionPayment> stale = paymentRepository.findByStatusInAndCreatedAtBeforeOrderByCreatedAtDesc(
                List.of(PaymentStatus.CREATED, PaymentStatus.PENDING),
                expireBefore
        );
        int expired = 0;
        for (SubscriptionPayment pay : stale) {
            pay.setStatus(PaymentStatus.FAILED);
            paymentRepository.save(pay);
            expired++;
            log.info(
                    "payment-auto-expire paymentId={} reference={} createdAt={} finalStatus=FAILED reason=timeout_{}m",
                    pay.getId(),
                    pay.getPaymentReference(),
                    pay.getCreatedAt(),
                    paymentExpireAfterMinutes
            );
        }

        LocalDateTime since = now.minusHours(paymentSyncWindowHours);
        List<SubscriptionPayment> candidates = paymentRepository.findByStatusInAndCreatedAtAfterOrderByCreatedAtDesc(
                List.of(PaymentStatus.CREATED, PaymentStatus.PENDING),
                since
        );
        int synced = 0;
        for (SubscriptionPayment pay : candidates) {
            if (pay.getPaymentReference() == null || pay.getPaymentReference().isBlank()) {
                continue;
            }
            try {
                Map<String, Object> result = recheckAndSyncPayment(pay);
                String status = Objects.toString(result.get("status"), "");
                if ("SUCCESS".equals(status) || "FAILED".equals(status) || "PENDING".equals(status)) {
                    synced++;
                }
            } catch (Exception e) {
                log.warn(
                        "payment-auto-sync failed paymentId={} reference={} reason={}",
                        pay.getId(),
                        pay.getPaymentReference(),
                        e.getMessage()
                );
            }
        }
        log.info(
                "payment-auto-sync completed scanned={} synced={} expired={} windowHours={} expireAfterMinutes={}",
                candidates.size(),
                synced,
                expired,
                paymentSyncWindowHours,
                paymentExpireAfterMinutes
        );
        return synced + expired;
    }

    @Transactional
    public int autoSyncHotWindowPayments() {
        LocalDateTime since = LocalDateTime.now().minusMinutes(paymentHotSyncWindowMinutes);
        List<SubscriptionPayment> candidates = paymentRepository.findByStatusInAndCreatedAtAfterOrderByCreatedAtDesc(
                List.of(PaymentStatus.CREATED, PaymentStatus.PENDING),
                since
        );
        int synced = 0;
        for (SubscriptionPayment pay : candidates) {
            if (pay.getPaymentReference() == null || pay.getPaymentReference().isBlank()) continue;
            try {
                Map<String, Object> result = recheckAndSyncPayment(pay);
                String status = Objects.toString(result.get("status"), "");
                if ("SUCCESS".equals(status) || "FAILED".equals(status) || "PENDING".equals(status)) {
                    synced++;
                }
            } catch (Exception e) {
                log.warn(
                        "payment-hot-sync failed paymentId={} reference={} reason={}",
                        pay.getId(),
                        pay.getPaymentReference(),
                        e.getMessage()
                );
            }
        }
        log.info("payment-hot-sync completed scanned={} synced={} windowMinutes={}", candidates.size(), synced, paymentHotSyncWindowMinutes);
        return synced;
    }

    private Map<String, Object> recheckAndSyncPayment(SubscriptionPayment pay) {
        pay.setLastSyncedAt(LocalDateTime.now());
        paymentRepository.save(pay);
        // D'abord le statut local (webhook déjà traité).
        if (pay.getStatus() == PaymentStatus.SUCCESS) {
            log.info("payment-sync resolved paymentId={} reference={} finalStatus=SUCCESS source=local", pay.getId(), pay.getPaymentReference());
            return Map.of("success", true, "status", "SUCCESS", "message", "Abonnement active.");
        }
        if (pay.getStatus() == PaymentStatus.FAILED) {
            log.info("payment-sync resolved paymentId={} reference={} finalStatus=FAILED source=local", pay.getId(), pay.getPaymentReference());
            return Map.of("success", false, "status", "FAILED", "message", "Paiement refuse ou annule.");
        }

        // Sinon on interroge le provider via l'endpoint intent/{id} (id peut être la reference).
        Map<String, Object> providerData = checkPaymentAtProvider(pay.getPaymentReference());
        Object rawStatus = providerData.get("status");
        if (rawStatus == null) rawStatus = providerData.get("paymentStatus");
        if (rawStatus == null) rawStatus = providerData.get("transactionStatus");
        String status = Objects.toString(rawStatus, "PENDING").toUpperCase();
        log.info(
                "payment-sync provider paymentId={} reference={} localStatus={} providerStatus={}",
                pay.getId(),
                pay.getPaymentReference(),
                pay.getStatus(),
                status
        );

        if (isAcceptedAndValidAmount(pay, providerData)) {
            activateSubscriptionIfNeeded(pay);
            log.info("payment-sync resolved paymentId={} reference={} finalStatus=SUCCESS source=provider", pay.getId(), pay.getPaymentReference());
            return Map.of("success", true, "status", "SUCCESS", "message", "Abonnement active.");
        }
        if (isPendingStatus(status)) {
            if (pay.getStatus() != PaymentStatus.PENDING) {
                PaymentStatus previous = pay.getStatus();
                pay.setStatus(PaymentStatus.PENDING);
                paymentRepository.save(pay);
                log.info("payment-sync transition paymentId={} reference={} transition={}=>{}", pay.getId(), pay.getPaymentReference(), previous, PaymentStatus.PENDING);
            }
            log.info("payment-sync resolved paymentId={} reference={} finalStatus=PENDING source=provider", pay.getId(), pay.getPaymentReference());
            return Map.of("success", false, "status", "PENDING", "message", "Paiement en attente de confirmation.");
        }
        if (isFailureStatus(status)) {
            PaymentStatus previous = pay.getStatus();
            pay.setStatus(PaymentStatus.FAILED);
            paymentRepository.save(pay);
            log.info("payment-sync transition paymentId={} reference={} transition={}=>{}", pay.getId(), pay.getPaymentReference(), previous, PaymentStatus.FAILED);
            log.info("payment-sync resolved paymentId={} reference={} finalStatus=FAILED source=provider", pay.getId(), pay.getPaymentReference());
            return Map.of("success", false, "status", "FAILED", "message", "Paiement refuse ou annule.");
        }

        if (pay.getStatus() == PaymentStatus.CREATED) {
            log.info("payment-sync resolved paymentId={} reference={} finalStatus=CREATED source=provider_unknown", pay.getId(), pay.getPaymentReference());
            return Map.of("success", false, "status", "CREATED", "message", "Paiement non initie.");
        }
        log.info("payment-sync resolved paymentId={} reference={} finalStatus=PENDING source=fallback", pay.getId(), pay.getPaymentReference());
        return Map.of("success", false, "status", "PENDING", "message", "Paiement en attente de confirmation.");
    }

    @Transactional
    public Map<String, Object> handleYengapayWebhook(Map<String, Object> payload) {
        String transactionId = extractTransactionId(payload);
        if (transactionId == null || transactionId.isBlank()) {
            log.warn("Yengapay webhook: transaction id introuvable. Keys={} Payload={}", payload == null ? null : payload.keySet(), payload);
            return Map.of("ok", false, "message", "transaction_id manquant");
        }

        log.info("Yengapay webhook received reference={} payloadKeys={}", transactionId, payload == null ? null : payload.keySet());
        SubscriptionPayment pay = paymentRepository.findByPaymentReference(transactionId).orElse(null);

        if (pay == null) {
            log.warn("Yengapay webhook unresolved reference={} reason=payment_not_found", transactionId);
            return Map.of("ok", false, "message", "Paiement introuvable");
        }

        if (!isYengapayConfigured()) {
            return Map.of("ok", false, "message", "Yengapay non configure");
        }

        pay.setLastSyncedAt(LocalDateTime.now());
        paymentRepository.save(pay);

        // On fait confiance au webhook (sinon il faudrait un endpoint "check" qui n'est plus utilisé ici).
        Map<String, Object> providerData = payload;
        Object nested = payload.get("data");
        if (nested instanceof Map<?, ?> m) {
            providerData = (Map<String, Object>) m;
        }

        Object rawStatus = providerData.get("status");
        if (rawStatus == null) rawStatus = providerData.get("paymentStatus");
        if (rawStatus == null) rawStatus = providerData.get("transactionStatus");
        String status = Objects.toString(rawStatus, "").toUpperCase();
        log.info(
                "Yengapay webhook match paymentId={} reference={} localStatus={} providerStatus={}",
                pay.getId(),
                pay.getPaymentReference(),
                pay.getStatus(),
                status
        );
        // Validation stricte: on active uniquement si statut accepté + contrôle montant.
        if (isAcceptedAndValidAmount(pay, providerData)) {
            activateSubscriptionIfNeeded(pay);
            log.info("Yengapay webhook resolved paymentId={} reference={} finalStatus=SUCCESS", pay.getId(), pay.getPaymentReference());
            return Map.of("ok", true);
        }
        if (isFailureStatus(status)) {
            pay.setStatus(PaymentStatus.FAILED);
            paymentRepository.save(pay);
            log.info("Yengapay webhook resolved paymentId={} reference={} finalStatus=FAILED", pay.getId(), pay.getPaymentReference());
        }
        if (isPendingStatus(status) && pay.getStatus() == PaymentStatus.CREATED) {
            pay.setStatus(PaymentStatus.PENDING);
            paymentRepository.save(pay);
            log.info("Yengapay webhook transition paymentId={} reference={} transition={}=>{}", pay.getId(), pay.getPaymentReference(), PaymentStatus.CREATED, PaymentStatus.PENDING);
        }
        log.info("Yengapay webhook resolved paymentId={} reference={} finalStatus={}", pay.getId(), pay.getPaymentReference(), pay.getStatus());
        return Map.of("ok", true);
    }

    private String extractTransactionId(Map<String, Object> payload) {
        if (payload == null) return null;

        // Essayons plusieurs clés possibles selon le format du webhook YengaPay.
        String[] candidateKeys = new String[]{
                "transaction_id",
                "transactionId",
                "transactionID",
                "trans_id",
                "transId",
                "TransID",
                "reference",
                "ref"
        };

        for (String key : candidateKeys) {
            Object v = payload.get(key);
            if (v == null) continue;
            String s = v.toString();
            if (!s.isBlank()) return s;
        }

        // Si YengaPay envoie une structure du type { data: { ... } }
        Object data = payload.get("data");
        if (data instanceof Map<?, ?> m) {
            for (String key : candidateKeys) {
                Object v = m.get(key);
                if (v == null) continue;
                String s = v.toString();
                if (!s.isBlank()) return s;
            }
        }

        return null;
    }

    public List<Map<String, Object>> getPaymentHistory(Long studentId) {
        return paymentRepository.findByStudentIdOrderByCreatedAtDesc(studentId).stream()
                .map(p -> {
                    Map<String, Object> m = new HashMap<>();
                    m.put("id", p.getId());
                    m.put("planId", p.getPlanId());
                    m.put("amount", p.getAmount());
                    m.put("currency", p.getCurrency());
                    m.put("status", p.getStatus().name());
                    m.put("paidAt", p.getPaidAt());
                    m.put("createdAt", p.getCreatedAt());
                    planRepository.findById(p.getPlanId()).ifPresent(plan -> m.put("planName", plan.getName()));
                    return m;
                })
                .collect(Collectors.toList());
    }

    public Map<String, Object> getPaylink() {
        if (yengapayPaylinkUrl == null || yengapayPaylinkUrl.isBlank()) {
            return Map.of("paylinkUrl", "", "configured", false);
        }
        return Map.of("paylinkUrl", yengapayPaylinkUrl, "configured", true);
    }

    private boolean isYengapayConfigured() {
        return yengapayApiKey != null && !yengapayApiKey.isBlank()
                && yengapayGroupId != null && !yengapayGroupId.isBlank()
                && yengapayProjectId != null && !yengapayProjectId.isBlank();
    }

    private Map<String, Object> extractData(Map body) {
        if (body == null) return Map.of();
        Object data = body.get("data");
        if (data instanceof Map<?, ?> m) {
            return (Map<String, Object>) m;
        }
        return Map.of();
    }

    private Map<String, Object> checkPaymentAtProvider(String paymentReference) {
        if (!isYengapayConfigured() || paymentReference == null || paymentReference.isBlank()) {
            return Map.of("status", "UNKNOWN");
        }
        try {
            String url = yengapayBaseUrl + "/groups/" + yengapayGroupId
                    + "/payment-intent/project/" + yengapayProjectId
                    + "/intent/" + paymentReference;
            HttpHeaders headers = new HttpHeaders();
            headers.set("x-api-key", yengapayApiKey);
            HttpEntity<Void> entity = new HttpEntity<>(headers);
            ResponseEntity<Map> resp = restTemplate.exchange(
                    url,
                    org.springframework.http.HttpMethod.GET,
                    entity,
                    Map.class
            );
            Map<String, Object> body = resp.getBody() != null ? resp.getBody() : Map.of();
            return body;
        } catch (Exception e) {
            log.warn("Yengapay check intent failed for reference={}: {}", paymentReference, e.getMessage());
            return Map.of("status", "UNKNOWN");
        }
    }

    private boolean isAcceptedAndValidAmount(SubscriptionPayment pay, Map<String, Object> data) {
        Object rawStatus = data.get("status");
        if (rawStatus == null) rawStatus = data.get("paymentStatus");
        if (rawStatus == null) rawStatus = data.get("transactionStatus");
        String status = normalizeStatus(rawStatus);
        // Selon la version/flow YengaPay, le statut peut varier.
        if (!( "ACCEPTED".equals(status)
                || "DONE".equals(status)
                || "SUCCESS".equals(status)
                || "SUCCEEDED".equals(status)
                || "PAID".equals(status)
                || "COMPLETED".equals(status)
                || "COMPLETED_PAYMENT".equals(status))) {
            return false;
        }

        String currency = Objects.toString(
                data.containsKey("currency") ? data.get("currency") : data.getOrDefault("paymentCurrency", "XOF"),
                "XOF"
        ).toUpperCase();
        if (!"XOF".equals(currency) && !"FCFA".equals(currency)) return false;

        long expectedAmount = Math.round(pay.getAmount());
        Object amountValue = data.get("amount");
        if (amountValue == null) amountValue = data.get("paymentAmount");
        if (amountValue == null) amountValue = data.get("transactionAmount");
        if (amountValue == null) {
            // Certains webhooks ne renvoient pas toujours le montant: on se fie alors au statut + référence.
            return true;
        }
        long receivedAmount = parseLong(amountValue);
        if (expectedAmount == receivedAmount) return true;

        // Fallback: si totalAmount est présent, on l'accepte aussi.
        long totalAmount = parseLong(data.get("totalAmount"));
        return totalAmount > 0 && totalAmount == expectedAmount;
    }

    private boolean isFailureStatus(String status) {
        String s = normalizeStatus(status);
        return "REFUSED".equals(s)
                || "FAILED".equals(s)
                || "FAILURE".equals(s)
                || "ERROR".equals(s)
                || "EXPIRED".equals(s)
                || "CANCELED".equals(s)
                || "CANCELLED".equals(s);
    }

    private boolean isPendingStatus(String status) {
        String s = normalizeStatus(status);
        return "PENDING".equals(s)
                || "PROCESSING".equals(s)
                || "IN_PROGRESS".equals(s)
                || "WAITING".equals(s);
    }

    private long parseLong(Object value) {
        if (value == null) return -1L;
        if (value instanceof Number n) return n.longValue();
        try {
            return Long.parseLong(value.toString());
        } catch (NumberFormatException e) {
            return -1L;
        }
    }

    private String normalizeStatus(Object status) {
        if (status == null) return "";
        return status.toString().trim().toUpperCase().replace('-', '_').replace(' ', '_');
    }

    private void activateSubscriptionIfNeeded(SubscriptionPayment pay) {
        if (pay.getStatus() == PaymentStatus.SUCCESS) return;

        pay.setStatus(PaymentStatus.SUCCESS);
        pay.setPaidAt(LocalDateTime.now());
        paymentRepository.save(pay);

        SubscriptionPlan plan = planRepository.findById(pay.getPlanId()).orElseThrow();
        LocalDate today = LocalDate.now();

        // Si un abonnement actif existe déjà, on prolonge depuis sa date de fin,
        // sinon on démarre aujourd'hui.
        LocalDate baseDate = subscriptionRepository
                .findFirstByStudentIdAndStatusOrderByEndDateDesc(pay.getStudentId(), SubscriptionStatus.ACTIVE)
                .map(sub -> {
                    LocalDate end = sub.getEndDate();
                    if (end == null) return today;
                    return end.isAfter(today) ? end : today;
                })
                .orElse(today);

        LocalDate endDate = plan.getType() == SubscriptionPlanType.YEARLY
                ? baseDate.plusYears(1)
                : baseDate.plusMonths(1);

        StudentSubscription sub = new StudentSubscription();
        sub.setStudentId(pay.getStudentId());
        sub.setPlanId(plan.getId());
        sub.setStartDate(baseDate);
        sub.setEndDate(endDate);
        sub.setStatus(SubscriptionStatus.ACTIVE);
        sub.setCreatedAt(LocalDateTime.now());
        subscriptionRepository.save(sub);
    }

    private void fillStudentInfo(AdminSubscriptionPaymentResponse dto, User user) {
        String firstName = user.getFirstName() == null ? "" : user.getFirstName().trim();
        String lastName = user.getLastName() == null ? "" : user.getLastName().trim();
        String fullName = (firstName + " " + lastName).trim();
        dto.setStudentName(fullName.isEmpty() ? ("ID " + user.getId()) : fullName);
        dto.setStudentEmail(user.getEmail());
        dto.setStudentPhone(user.getPhoneNumber());
    }

    private void logAdminAction(Long adminUserId, String action, Long targetId, String details) {
        if (adminUserId == null) return;
        AdminAuditLog log = new AdminAuditLog();
        log.setAdminUserId(adminUserId);
        log.setAction(action);
        log.setTargetType("SUBSCRIPTION_PAYMENT");
        log.setTargetId(targetId);
        log.setDetails(details);
        log.setCreatedAt(LocalDateTime.now());
        adminAuditLogRepository.save(log);
    }

    private void enrichSubscriptionState(AdminSubscriptionPaymentResponse dto, Long studentId) {
        subscriptionRepository.findFirstByStudentIdAndStatusOrderByEndDateDesc(studentId, SubscriptionStatus.ACTIVE)
                .ifPresent(sub -> {
                    dto.setSubscriptionEndDate(sub.getEndDate());
                    boolean active = !LocalDate.now().isAfter(sub.getEndDate());
                    dto.setHasActiveSubscription(active);
                    if (active) {
                        dto.setRemainingDays((int) java.time.temporal.ChronoUnit.DAYS.between(LocalDate.now(), sub.getEndDate()));
                    } else {
                        dto.setRemainingDays(0);
                    }
                });
        if (dto.getHasActiveSubscription() == null) {
            dto.setHasActiveSubscription(false);
            dto.setRemainingDays(0);
        }
    }
}
