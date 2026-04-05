package com.campuspass.backend.service;

import com.campuspass.backend.dto.SavingsEntryDto;
import com.campuspass.backend.dto.StudentMeResponse;
import com.campuspass.backend.dto.StudentSavingsResponse;
import com.campuspass.backend.dto.StudentVerificationRequest;
import com.campuspass.backend.dto.ReferralPayoutRequestResponse;
import com.campuspass.backend.model.*;
import com.campuspass.backend.model.enums.StudentVerificationStatus;
import com.campuspass.backend.model.enums.ReferralPayoutStatus;
import com.campuspass.backend.model.enums.SubscriptionStatus;
import com.campuspass.backend.model.enums.TransactionStatus;
import com.campuspass.backend.repository.*;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class StudentService {
    private static final int POINTS_PER_REFERRAL = 5;
    private static final Logger log = LoggerFactory.getLogger(StudentService.class);

    private final StudentProfileRepository studentProfileRepository;
    private final StudentSubscriptionRepository subscriptionRepository;
    private final SubscriptionPlanRepository planRepository;
    private final TransactionRepository transactionRepository;
    private final MerchantRepository merchantRepository;
    private final OfferRepository offerRepository;
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final LoyaltyConfigService loyaltyConfigService;
    private final ReferralRewardRepository referralRewardRepository;
    private final ReferralPayoutRequestRepository referralPayoutRequestRepository;

    public StudentService(UserRepository userRepository,
                          StudentProfileRepository studentProfileRepository,
                          StudentSubscriptionRepository subscriptionRepository,
                          SubscriptionPlanRepository planRepository,
                          TransactionRepository transactionRepository,
                          MerchantRepository merchantRepository,
                          OfferRepository offerRepository,
                          LoyaltyConfigService loyaltyConfigService,
                          ReferralRewardRepository referralRewardRepository,
                          ReferralPayoutRequestRepository referralPayoutRequestRepository,
                          PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.studentProfileRepository = studentProfileRepository;
        this.subscriptionRepository = subscriptionRepository;
        this.planRepository = planRepository;
        this.transactionRepository = transactionRepository;
        this.merchantRepository = merchantRepository;
        this.offerRepository = offerRepository;
        this.loyaltyConfigService = loyaltyConfigService;
        this.referralRewardRepository = referralRewardRepository;
        this.referralPayoutRequestRepository = referralPayoutRequestRepository;
        this.passwordEncoder = passwordEncoder;
    }

    public StudentMeResponse getMe(Long studentId) {
        User user = userRepository.findById(studentId).orElseThrow();
        StudentMeResponse r = new StudentMeResponse();
        r.setId(user.getId());
        r.setFirstName(user.getFirstName());
        r.setLastName(user.getLastName());
        r.setEmail(user.getEmail());
        r.setPhoneNumber(user.getPhoneNumber());
        r.setStatus(user.getStatus());
        r.setCreatedAt(user.getCreatedAt());
        r.setReferralCode(user.getReferralCode());
        studentProfileRepository.findByUserId(studentId).ifPresent(sp -> {
            r.setUniversity(sp.getUniversity());
            r.setCity(sp.getCity());
            r.setCountry(sp.getCountry());
            r.setStudentVerified(Boolean.TRUE.equals(sp.getVerified()));
            r.setStudentVerificationStatus(
                    sp.getVerificationStatus() != null ? sp.getVerificationStatus().name() : StudentVerificationStatus.NONE.name()
            );
            r.setStudentVerificationRejectionReason(sp.getVerificationRejectionReason());
        });
        if (r.getStudentVerificationStatus() == null) {
            r.setStudentVerificationStatus(StudentVerificationStatus.NONE.name());
        }

        subscriptionRepository.findFirstByStudentIdAndStatusOrderByEndDateDesc(studentId, SubscriptionStatus.ACTIVE)
                .ifPresent(sub -> {
                    boolean active = !LocalDate.now().isAfter(sub.getEndDate());
                    r.setHasActiveSubscription(active);
                    r.setSubscriptionEndDate(sub.getEndDate());
                    planRepository.findById(sub.getPlanId()).ifPresent(p -> r.setSubscriptionPlanName(p.getName()));
                });
        if (r.getHasActiveSubscription() == null) r.setHasActiveSubscription(false);

        List<Transaction> txList = transactionRepository.findByUserIdOrderByTransactionDateDesc(studentId).stream()
                .filter(t -> t.getStatus() == TransactionStatus.SUCCESS)
                .toList();
        double totalSaved = txList.stream().mapToDouble(t -> t.getDiscountAmount() != null ? t.getDiscountAmount() : 0.0).sum();
        r.setTotalSavings(totalSaved);

        // Si le calcul (et/ou sync) des récompenses parrainage échoue,
        // on ne doit pas empêcher l'affichage du profil.
        try {
            syncReferralRewardsForReferrer(user);
            int fcfaPerPoint = loyaltyConfigService.getFcfaPerPoint();
            int savingsPoints = (int) (totalSaved / fcfaPerPoint);
            long referralsCount = countActiveSubscribedReferrals(r.getReferralCode());
            int referralPoints = (int) referralsCount * POINTS_PER_REFERRAL;
            r.setLoyaltyPoints(savingsPoints + referralPoints);
            int earnedFcfa = safeInt(referralRewardRepository.sumAmountByReferrerId(studentId));
            int alreadyRequested = safeInt(referralPayoutRequestRepository
                    .sumRequestedNonRejectedByReferrerId(studentId, ReferralPayoutStatus.REJECTED));
            r.setReferralBalance(Math.max(0, earnedFcfa - alreadyRequested));
            r.setReferralsCount((int) referralsCount);
        } catch (Exception e) {
            log.error("Erreur calcul profil (points/parrainage) pour userId={}", studentId, e);
            r.setLoyaltyPoints(0);
            r.setReferralBalance(0);
            r.setReferralsCount(0);
        }

        return r;
    }

    public void updateVerification(Long studentId, StudentVerificationRequest req) {
        StudentProfile sp = studentProfileRepository.findByUserId(studentId)
                .orElseGet(() -> {
                    StudentProfile p = new StudentProfile();
                    p.setUserId(studentId);
                    p.setVerified(false);
                    p.setVerificationStatus(StudentVerificationStatus.NONE);
                    return p;
                });
        if (req.getVerificationDocumentType() != null) {
            sp.setVerificationDocumentType(req.getVerificationDocumentType());
        }
        if (req.getUniversity() != null) sp.setUniversity(req.getUniversity());
        if (req.getStudentCardNumber() != null) sp.setStudentCardNumber(req.getStudentCardNumber());
        if (req.getStudentCardImage() != null) sp.setStudentCardImage(req.getStudentCardImage());
        if (req.getCity() != null) sp.setCity(req.getCity());
        if (req.getCountry() != null) sp.setCountry(req.getCountry());
        // Dès qu'une nouvelle vérification est soumise, on repasse en non vérifié jusqu'à action admin
        sp.setVerified(false);
        sp.setVerificationStatus(StudentVerificationStatus.PENDING);
        sp.setVerificationRejectionReason(null);
        sp.setVerificationDate(null);
        studentProfileRepository.save(sp);
    }

    public void updateEmail(Long studentId, String email) {
        if (email == null || email.isBlank()) {
            throw new IllegalArgumentException("Email requis.");
        }

        String normalized = email.trim().toLowerCase();
        User user = userRepository.findById(studentId).orElseThrow();

        // Si l'email demandé est déjà celui de l'utilisateur, ne rien faire
        if (user.getEmail() != null && user.getEmail().equalsIgnoreCase(normalized)) {
            return;
        }

        // Vérifie l'unicité uniquement pour les autres comptes
        if (userRepository.existsByEmailIgnoreCase(normalized)) {
            throw new IllegalArgumentException("Un compte existe déjà avec cet email.");
        }

        user.setEmail(normalized);
        user.setUpdatedAt(LocalDate.now().atStartOfDay());
        userRepository.save(user);
    }

    public void updateArea(Long studentId, String city, String country) {
        StudentProfile sp = studentProfileRepository.findByUserId(studentId)
                .orElseGet(() -> {
                    StudentProfile p = new StudentProfile();
                    p.setUserId(studentId);
                    p.setVerified(false);
                    return p;
                });
        sp.setCity(normalizeNullable(city));
        sp.setCountry(normalizeNullable(country));
        studentProfileRepository.save(sp);
    }

    public void updateProfile(Long studentId, String firstName, String email, String phoneNumber, String city) {
        User user = userRepository.findById(studentId).orElseThrow();
        String normalizedFirstName = normalizeNullable(firstName);
        if (normalizedFirstName == null) {
            throw new IllegalArgumentException("Le prenom est requis.");
        }

        user.setFirstName(normalizedFirstName);
        user.setPhoneNumber(normalizeNullable(phoneNumber));

        String normalizedEmail = normalizeNullable(email);
        if (normalizedEmail == null) {
            throw new IllegalArgumentException("Email requis.");
        }
        normalizedEmail = normalizedEmail.toLowerCase();
        if (user.getEmail() == null || !user.getEmail().equalsIgnoreCase(normalizedEmail)) {
            if (userRepository.existsByEmailIgnoreCase(normalizedEmail)) {
                throw new IllegalArgumentException("Un compte existe deja avec cet email.");
            }
            user.setEmail(normalizedEmail);
        }

        user.setUpdatedAt(java.time.LocalDateTime.now());
        userRepository.save(user);

        StudentProfile sp = studentProfileRepository.findByUserId(studentId)
                .orElseGet(() -> {
                    StudentProfile p = new StudentProfile();
                    p.setUserId(studentId);
                    p.setVerified(false);
                    return p;
                });
        sp.setCity(normalizeNullable(city));
        studentProfileRepository.save(sp);
    }

    public void updatePassword(Long studentId, String currentPassword, String newPassword) {
        if (currentPassword == null || currentPassword.isBlank()) {
            throw new IllegalArgumentException("Mot de passe actuel requis.");
        }
        if (newPassword == null || newPassword.isBlank() || newPassword.trim().length() < 6) {
            throw new IllegalArgumentException("Nouveau mot de passe invalide (minimum 6 caracteres).");
        }

        User user = userRepository.findById(studentId).orElseThrow();
        if (!passwordEncoder.matches(currentPassword, user.getPassword())) {
            throw new IllegalArgumentException("Mot de passe actuel incorrect.");
        }
        user.setPassword(passwordEncoder.encode(newPassword.trim()));
        user.setUpdatedAt(java.time.LocalDateTime.now());
        userRepository.save(user);
    }

    public void linkReferralCode(Long studentId, String referralCodeInput) {
        if (referralCodeInput == null || referralCodeInput.isBlank()) {
            throw new IllegalArgumentException("Code de parrainage requis.");
        }
        User user = userRepository.findById(studentId).orElseThrow();
        if (user.getReferredByCode() != null && !user.getReferredByCode().isBlank()) {
            throw new IllegalArgumentException("Le code de parrainage est déjà lié à ce compte.");
        }

        String normalizedCode = referralCodeInput.trim().toUpperCase();
        User inviter = userRepository.findByReferralCodeIgnoreCase(normalizedCode)
                .orElseThrow(() -> new IllegalArgumentException("Code de parrainage invalide."));
        if (inviter.getId().equals(user.getId())) {
            throw new IllegalArgumentException("Tu ne peux pas utiliser ton propre code.");
        }

        user.setReferredByCode(inviter.getReferralCode());
        user.setReferredByLinkedAt(java.time.LocalDateTime.now());
        user.setUpdatedAt(java.time.LocalDateTime.now());
        userRepository.save(user);
    }

    public ReferralPayoutRequestResponse requestReferralPayout(Long studentId) {
        User user = userRepository.findById(studentId).orElseThrow();
        syncReferralRewardsForReferrer(user);
        var now = java.time.LocalDateTime.now();
        int year = now.getYear();
        int month = now.getMonthValue();
        long requestsThisMonth = referralPayoutRequestRepository
                .countByReferrerIdAndRequestYearAndRequestMonth(studentId, year, month);
        if (requestsThisMonth >= 2) {
            throw new IllegalArgumentException("Maximum 2 demandes de retrait par mois.");
        }

        int earnedFcfa = safeInt(referralRewardRepository.sumAmountByReferrerId(studentId));
        int alreadyRequested = safeInt(referralPayoutRequestRepository
                .sumRequestedNonRejectedByReferrerId(studentId, ReferralPayoutStatus.REJECTED));
        int available = Math.max(0, earnedFcfa - alreadyRequested);
        if (available <= 0) {
            throw new IllegalArgumentException("Aucun solde de parrainage disponible.");
        }

        ReferralPayoutRequest req = new ReferralPayoutRequest();
        req.setReferrerId(studentId);
        req.setRequestYear(year);
        req.setRequestMonth(month);
        req.setAmountFcfa(available);
        req.setStatus(ReferralPayoutStatus.PENDING);
        req.setRequestedAt(now);
        req = referralPayoutRequestRepository.save(req);

        ReferralPayoutRequestResponse res = new ReferralPayoutRequestResponse();
        res.setId(req.getId());
        res.setAmountFcfa(req.getAmountFcfa());
        res.setStatus(req.getStatus().name());
        res.setRequestedAt(req.getRequestedAt());
        return res;
    }

    public StudentSavingsResponse getSavings(Long studentId) {
        try {
            List<Transaction> txList = transactionRepository.findByUserIdOrderByTransactionDateDesc(studentId).stream()
                    .filter(t -> t.getStatus() == TransactionStatus.SUCCESS && t.getDiscountAmount() != null && t.getDiscountAmount() > 0)
                    .toList();
            double totalSaved = txList.stream().mapToDouble(t -> t.getDiscountAmount()).sum();
            long merchantsCount = txList.stream().map(Transaction::getMerchantId).distinct().count();
            List<SavingsEntryDto> history = txList.stream().map(t -> {
                SavingsEntryDto e = new SavingsEntryDto();
                e.setTransactionId(t.getId());
                e.setDiscountAmount(t.getDiscountAmount());
                e.setSavedAmount(t.getDiscountAmount());
                e.setOriginalAmount(t.getOriginalAmount());
                e.setDate(t.getTransactionDate());
                merchantRepository.findById(t.getMerchantId()).ifPresent(m -> e.setMerchantName(m.getName()));
                offerRepository.findById(t.getOfferId()).ifPresent(o -> e.setOfferTitle(o.getTitle()));
                return e;
            }).collect(Collectors.toList());
            StudentSavingsResponse resp = new StudentSavingsResponse();
            resp.setTotalSaved(totalSaved);
            resp.setOffersUsedCount(txList.size());
            resp.setMerchantsVisitedCount(merchantsCount);
            resp.setHistory(history);
            return resp;
        } catch (Exception e) {
            log.error("Erreur getSavings pour userId={}", studentId, e);
            StudentSavingsResponse resp = new StudentSavingsResponse();
            resp.setTotalSaved(0);
            resp.setOffersUsedCount(0);
            resp.setMerchantsVisitedCount(0);
            resp.setHistory(List.of());
            return resp;
        }
    }

    private String normalizeNullable(String value) {
        if (value == null) {
            return null;
        }
        String v = value.trim();
        return v.isEmpty() ? null : v;
    }

    private long countActiveSubscribedReferrals(String referralCode) {
        if (referralCode == null || referralCode.isBlank()) {
            return 0;
        }
        return userRepository.findByReferredByCodeIgnoreCase(referralCode).stream()
                .filter(this::isReferralEligibleForPoints)
                .count();
    }

    private boolean isReferralEligibleForPoints(User referred) {
        var linkedAt = referred.getReferredByLinkedAt() != null
                ? referred.getReferredByLinkedAt()
                : referred.getCreatedAt();
        if (linkedAt == null) return false;

        // Règle: le code doit être lié avant AU MOINS un abonnement du filleul.
        // Donc même si le code a été ajouté après le 1er abonnement, un abonnement
        // suivant peut quand même rendre le parrainage éligible.
        return subscriptionRepository.findByStudentIdOrderByEndDateDesc(referred.getId()).stream()
                .anyMatch(sub -> !linkedAt.toLocalDate().isAfter(sub.getStartDate()));
    }

    private void syncReferralRewardsForReferrer(User referrer) {
        String referralCode = referrer.getReferralCode();
        if (referralCode == null || referralCode.isBlank()) return;

        userRepository.findByReferredByCodeIgnoreCase(referralCode).forEach(referred -> {
            if (referralRewardRepository.existsByReferrerIdAndReferredUserId(referrer.getId(), referred.getId())) {
                return;
            }

            var linkedAt = referred.getReferredByLinkedAt() != null ? referred.getReferredByLinkedAt() : referred.getCreatedAt();
            if (linkedAt == null) return;

            var firstEligibleSub = subscriptionRepository.findByStudentIdOrderByStartDateAsc(referred.getId()).stream()
                    .filter(sub -> !linkedAt.toLocalDate().isAfter(sub.getStartDate()))
                    .findFirst();
            if (firstEligibleSub.isEmpty()) return;

            var sub = firstEligibleSub.get();
            int year = sub.getStartDate().getYear();
            int month = sub.getStartDate().getMonthValue();
            long alreadyInMonth = referralRewardRepository.countByReferrerAndYearMonth(referrer.getId(), year, month);
            int amount = alreadyInMonth < 20 ? 500 : 200;

            ReferralReward reward = new ReferralReward();
            reward.setReferrerId(referrer.getId());
            reward.setReferredUserId(referred.getId());
            reward.setRewardYear(year);
            reward.setRewardMonth(month);
            reward.setAmountFcfa(amount);
            reward.setRewardedAt(java.time.LocalDateTime.now());
            referralRewardRepository.save(reward);
        });
    }

    private int safeInt(Integer v) {
        return v == null ? 0 : v;
    }
}
