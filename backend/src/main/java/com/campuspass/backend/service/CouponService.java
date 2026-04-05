package com.campuspass.backend.service;

import com.campuspass.backend.dto.CouponResponse;
import com.campuspass.backend.exception.ResourceNotFoundException;
import com.campuspass.backend.model.Coupon;
import com.campuspass.backend.model.Offer;
import com.campuspass.backend.model.StudentProfile;
import com.campuspass.backend.model.StudentSubscription;
import com.campuspass.backend.model.enums.CouponStatus;
import com.campuspass.backend.model.enums.SubscriptionStatus;
import com.campuspass.backend.repository.CouponRepository;
import com.campuspass.backend.repository.OfferRepository;
import com.campuspass.backend.repository.StudentProfileRepository;
import com.campuspass.backend.repository.StudentSubscriptionRepository;
import com.campuspass.backend.util.QrCodeGenerator;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class CouponService {

    private static final int COUPON_VALIDITY_HOURS = 24;

    private final CouponRepository couponRepository;
    private final OfferRepository offerRepository;
    private final StudentProfileRepository studentProfileRepository;
    private final StudentSubscriptionRepository subscriptionRepository;
    private final NotificationService notificationService;

    public CouponService(CouponRepository couponRepository, OfferRepository offerRepository,
                         StudentProfileRepository studentProfileRepository,
                         StudentSubscriptionRepository subscriptionRepository,
                         NotificationService notificationService) {
        this.couponRepository = couponRepository;
        this.offerRepository = offerRepository;
        this.studentProfileRepository = studentProfileRepository;
        this.subscriptionRepository = subscriptionRepository;
        this.notificationService = notificationService;
    }

    public List<CouponResponse> findByUserId(Long userId) {
        return couponRepository.findByUserIdOrderByGeneratedAtDesc(userId).stream()
                .map(this::toResponse).collect(Collectors.toList());
    }

    public CouponResponse getById(Long id) {
        Coupon c = couponRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Coupon", id));
        return toResponse(c);
    }

    public Coupon getByCode(String code) {
        return couponRepository.findByCouponCode(code)
                .orElseThrow(() -> new ResourceNotFoundException("Coupon avec code: " + code));
    }

    @Transactional
    public CouponResponse generate(Long userId, Long offerId) {
        Offer offer = offerRepository.findById(offerId)
                .orElseThrow(() -> new ResourceNotFoundException("Offer", offerId));
        enforceOfferEligibility(userId, offer);
        if (offer.getMaxCoupons() != null && offer.getMaxCoupons() > 0
                && offer.getUsedCoupons() >= offer.getMaxCoupons()) {
            throw new IllegalArgumentException("Plus de coupons disponibles pour cette offre.");
        }

        // Limite de passages par jour pour cet utilisateur et cette offre
        // -> on ne compte QUE les coupons réellement utilisés (status = USED)
        if (offer.getMaxPassesPerDayPerUser() != null
                && offer.getMaxPassesPerDayPerUser() > 0) {
            LocalDate today = LocalDate.now();
            LocalDateTime startOfDay = today.atStartOfDay();
            LocalDateTime endOfDay = today.plusDays(1).atStartOfDay();
            long usedToday = couponRepository
                    .countByUserIdAndOfferIdAndStatusAndGeneratedAtBetween(
                            userId, offerId, CouponStatus.USED, startOfDay, endOfDay);
            if (usedToday >= offer.getMaxPassesPerDayPerUser()) {
                throw new IllegalArgumentException("Tu as déjà utilisé cette offre aujourd'hui.");
            }
        }

        String code = QrCodeGenerator.generateCouponCode();
        String qrData = QrCodeGenerator.toBase64(code);
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime expiresAt = now.plusHours(COUPON_VALIDITY_HOURS);

        Coupon coupon = new Coupon();
        coupon.setUserId(userId);
        coupon.setOfferId(offerId);
        coupon.setCouponCode(code);
        coupon.setQrCodeData(qrData);
        coupon.setStatus(CouponStatus.GENERATED);
        coupon.setGeneratedAt(now);
        coupon.setExpiresAt(expiresAt);
        coupon = couponRepository.save(coupon);

        notificationService.create(userId, "Coupon généré", "Votre coupon " + code + " est prêt.", com.campuspass.backend.model.enums.NotificationType.TRANSACTION);
        return toResponse(coupon);
    }

    @Transactional
    public CouponResponse validate(String couponCode, Long merchantId) {
        Coupon coupon = getByCode(couponCode);
        if (coupon.getStatus() == CouponStatus.USED) {
            throw new IllegalArgumentException("Ce coupon a déjà été utilisé.");
        }
        if (coupon.getStatus() == CouponStatus.EXPIRED || (coupon.getExpiresAt() != null && coupon.getExpiresAt().isBefore(LocalDateTime.now()))) {
            coupon.setStatus(CouponStatus.EXPIRED);
            couponRepository.save(coupon);
            throw new IllegalArgumentException("Ce coupon a expiré.");
        }
        Offer offer = offerRepository.findById(coupon.getOfferId()).orElse(null);
        if (offer == null || !offer.getMerchantId().equals(merchantId)) {
            throw new IllegalArgumentException("Ce coupon n'est pas valable pour ce commerce.");
        }
        enforceOfferEligibility(coupon.getUserId(), offer);
        // Vérifie à nouveau la limite de passages par jour au moment de la validation,
        // pour éviter l'utilisation de vieux screenshots une fois le quota atteint.
        if (offer.getMaxPassesPerDayPerUser() != null
                && offer.getMaxPassesPerDayPerUser() > 0) {
            LocalDate today = LocalDate.now();
            LocalDateTime startOfDay = today.atStartOfDay();
            LocalDateTime endOfDay = today.plusDays(1).atStartOfDay();
            long usedToday = couponRepository
                    .countByUserIdAndOfferIdAndStatusAndGeneratedAtBetween(
                            coupon.getUserId(), offer.getId(),
                            CouponStatus.USED, startOfDay, endOfDay);
            if (usedToday >= offer.getMaxPassesPerDayPerUser()) {
                throw new IllegalArgumentException("Limite de passages journalière déjà atteinte pour cet étudiant.");
            }
        }

        coupon.setStatus(CouponStatus.USED);
        coupon.setUsedAt(LocalDateTime.now());
        coupon = couponRepository.save(coupon);

        offer.setUsedCoupons(offer.getUsedCoupons() == null ? 1 : offer.getUsedCoupons() + 1);
        offerRepository.save(offer);

        notificationService.create(coupon.getUserId(), "Coupon utilisé", "Votre coupon " + couponCode + " a été utilisé.", com.campuspass.backend.model.enums.NotificationType.TRANSACTION);
        return toResponse(coupon);
    }

    @Transactional
    public void expireOldCoupons() {
        List<Coupon> list = couponRepository.findAll().stream()
                .filter(c -> c.getStatus() == CouponStatus.GENERATED && c.getExpiresAt() != null && c.getExpiresAt().isBefore(LocalDateTime.now()))
                .collect(Collectors.toList());
        for (Coupon c : list) {
            c.setStatus(CouponStatus.EXPIRED);
            couponRepository.save(c);
        }
    }

    private CouponResponse toResponse(Coupon c) {
        CouponResponse r = new CouponResponse();
        r.setId(c.getId());
        r.setUserId(c.getUserId());
        r.setOfferId(c.getOfferId());
        r.setCouponCode(c.getCouponCode());
        r.setQrCodeData(c.getQrCodeData());
        r.setStatus(c.getStatus());
        r.setGeneratedAt(c.getGeneratedAt());
        r.setExpiresAt(c.getExpiresAt());
        r.setUsedAt(c.getUsedAt());
        return r;
    }

    private void enforceOfferEligibility(Long userId, Offer offer) {
        String csv = offer.getTargetUniversitiesCsv();
        if (csv == null || csv.isBlank()) {
            return;
        }

        StudentSubscription activeSub = subscriptionRepository
                .findFirstByStudentIdAndStatusOrderByEndDateDesc(userId, SubscriptionStatus.ACTIVE)
                .orElse(null);
        boolean hasActiveSub = activeSub != null
                && activeSub.getEndDate() != null
                && !LocalDate.now().isAfter(activeSub.getEndDate());
        if (!hasActiveSub) {
            throw new IllegalArgumentException(
                    "Cette offre est reservee aux abonnes de certaines universites.");
        }

        StudentProfile profile = studentProfileRepository.findByUserId(userId).orElse(null);
        String userUniversity = profile != null ? profile.getUniversity() : null;
        if (userUniversity == null || userUniversity.isBlank()) {
            throw new IllegalArgumentException(
                    "Renseigne ton universite pour utiliser cette offre reservee.");
        }

        String normalizedUserUniversity = userUniversity.trim().toLowerCase();
        boolean universityAllowed = java.util.Arrays.stream(csv.split(","))
                .map(String::trim)
                .filter(s -> !s.isEmpty())
                .map(String::toLowerCase)
                .anyMatch(normalizedUserUniversity::equals);
        if (!universityAllowed) {
            throw new IllegalArgumentException(
                    "Cette offre est reservee a une ou plusieurs universites specifiees.");
        }
    }
}
