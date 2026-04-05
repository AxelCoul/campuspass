package com.campuspass.backend.service;

import com.campuspass.backend.dto.OfferRequest;
import com.campuspass.backend.dto.OfferResponse;
import com.campuspass.backend.exception.ResourceNotFoundException;
import com.campuspass.backend.model.Offer;
import com.campuspass.backend.model.OfferImage;
import com.campuspass.backend.model.Merchant;
import com.campuspass.backend.model.enums.OfferStatus;
import com.campuspass.backend.model.enums.CouponStatus;
import com.campuspass.backend.repository.OfferRepository;
import com.campuspass.backend.repository.OfferImageRepository;
import com.campuspass.backend.repository.MerchantRepository;
import com.campuspass.backend.repository.CouponRepository;
import com.campuspass.backend.security.SecurityUser;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class OfferService {

    private final OfferRepository offerRepository;
    private final MerchantRepository merchantRepository;
    private final CouponRepository couponRepository;
    private final OfferImageRepository offerImageRepository;
    @Value("${feature.merchant-offer-management.enabled:false}")
    private boolean merchantOfferManagementEnabled;

    public OfferService(OfferRepository offerRepository,
                        MerchantRepository merchantRepository,
                        CouponRepository couponRepository,
                        OfferImageRepository offerImageRepository) {
        this.offerRepository = offerRepository;
        this.merchantRepository = merchantRepository;
        this.couponRepository = couponRepository;
        this.offerImageRepository = offerImageRepository;
    }

    public List<OfferResponse> findAll() {
        return offerRepository.findAll().stream().map(this::toResponse).collect(Collectors.toList());
    }

    public List<OfferResponse> findByMerchantId(Long merchantId) {
        return offerRepository.findByMerchantIdOrderByCreatedAtDesc(merchantId).stream()
                .map(this::toResponse).collect(Collectors.toList());
    }

    /** Filtre pour le commerce : active, scheduled, expired, history */
    public List<OfferResponse> findByMerchantIdAndFilter(Long merchantId, String filter) {
        java.time.LocalDate today = java.time.LocalDate.now();
        List<Offer> all = offerRepository.findByMerchantIdOrderByCreatedAtDesc(merchantId);
        List<Offer> filtered = all.stream()
                .filter(o -> matchFilter(o, filter, today))
                .collect(Collectors.toList());
        if ("history".equalsIgnoreCase(filter) || "expired".equalsIgnoreCase(filter)) {
            filtered = filtered.stream()
                    .sorted((a, b) -> {
                        java.time.LocalDate ea = a.getEndDate() != null ? a.getEndDate() : java.time.LocalDate.MIN;
                        java.time.LocalDate eb = b.getEndDate() != null ? b.getEndDate() : java.time.LocalDate.MIN;
                        return eb.compareTo(ea);
                    })
                    .collect(Collectors.toList());
        }
        return filtered.stream().map(this::toResponse).collect(Collectors.toList());
    }

    private boolean matchFilter(Offer o, String filter, java.time.LocalDate today) {
        if (filter == null || filter.isBlank()) return true;
        switch (filter.toLowerCase()) {
            case "active":
                return o.getStatus() == OfferStatus.ACTIVE
                        && (o.getStartDate() == null || !o.getStartDate().isAfter(today))
                        && (o.getEndDate() == null || !o.getEndDate().isBefore(today));
            case "proposed":
            case "pending_validation":
                return o.getStatus() == OfferStatus.PROPOSED || o.getStatus() == OfferStatus.PENDING;
            case "scheduled":
                return o.getStatus() == OfferStatus.ACTIVE
                        && o.getStartDate() != null
                        && o.getStartDate().isAfter(today);
            case "expired":
            case "history":
                return o.getEndDate() != null && o.getEndDate().isBefore(today)
                        || o.getStatus() == OfferStatus.EXPIRED
                        || o.getStatus() == OfferStatus.INACTIVE;
            default:
                return true;
        }
    }

    public List<OfferResponse> findActive() {
        return findActive(null);
    }

    public List<OfferResponse> findActive(String university) {
        return offerRepository.findByStatus(OfferStatus.ACTIVE).stream()
                .map(this::toResponse).collect(Collectors.toList());
    }

    /** Offres actives proches d'une position.
     *  Si radiusKm <= 0, ne filtre pas par distance et renvoie toutes les offres actives triées par distance croissante.
     */
    public List<OfferResponse> findNearby(double latitude, double longitude, double radiusKm) {
        List<Offer> activeOffers = offerRepository.findByStatus(OfferStatus.ACTIVE);
        Map<Long, Merchant> merchantById = merchantRepository.findAll().stream()
                .filter(m -> m.getLatitude() != null && m.getLongitude() != null)
                .collect(Collectors.toMap(Merchant::getId, m -> m));
        return activeOffers.stream()
                .map(o -> {
                    Merchant m = merchantById.get(o.getMerchantId());
                    if (m == null || m.getLatitude() == null || m.getLongitude() == null) return null;
                    double d = haversineKm(latitude, longitude, m.getLatitude(), m.getLongitude());
                    return Map.entry(o, d);
                })
                .filter(e -> e != null && (radiusKm <= 0 || e.getValue() <= radiusKm))
                .sorted(java.util.Comparator.comparingDouble(Map.Entry::getValue))
                .map(e -> toResponse(e.getKey()))
                .collect(Collectors.toList());
    }

    public OfferResponse getById(Long id) {
        Offer offer = offerRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Offer", id));
        return toResponse(offer);
    }

    @Transactional
    public OfferResponse create(OfferRequest req) {
        ensureMerchantOfferManagementAllowed();
        ensureMerchantCreatesForOwnShopOnly(req.getMerchantId());
        Offer offer = new Offer();
        mapRequestToEntity(req, offer);
        offer.setUsedCoupons(0);
        if (isCurrentUserAdmin()) {
            offer.setStatus(OfferStatus.ACTIVE);
        } else {
            // Commerçant : proposition soumise à validation admin (non visible côté étudiant).
            offer.setStatus(OfferStatus.PROPOSED);
        }
        offer.setCreatedAt(LocalDateTime.now());
        offer.setUpdatedAt(LocalDateTime.now());
        offer = offerRepository.save(offer);
        syncOfferImages(offer, req);
        return toResponse(offer);
    }

    @Transactional
    public OfferResponse update(Long id, OfferRequest req) {
        ensureMerchantOfferManagementAllowed();
        Offer offer = offerRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Offer", id));
        ensureMerchantOwnsOfferOrAdmin(offer);
        ensureMerchantMayEditOffer(offer);
        ensureMerchantCreatesForOwnShopOnly(req.getMerchantId());
        mapRequestToEntity(req, offer);
        offer.setUpdatedAt(LocalDateTime.now());
        offer = offerRepository.save(offer);
        syncOfferImages(offer, req);
        return toResponse(offer);
    }

    private boolean isCurrentUserAdmin() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null) return false;
        for (GrantedAuthority authority : auth.getAuthorities()) {
            if ("ROLE_ADMIN".equals(authority.getAuthority())) {
                return true;
            }
        }
        return false;
    }

    private boolean isCurrentUserMerchant() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null) return false;
        for (GrantedAuthority authority : auth.getAuthorities()) {
            if ("ROLE_MERCHANT".equals(authority.getAuthority())) {
                return true;
            }
        }
        return false;
    }

    @Transactional
    public void delete(Long id) {
        ensureMerchantOfferManagementAllowed();
        Offer offer = offerRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Offer", id));
        ensureMerchantOwnsOfferOrAdmin(offer);
        ensureMerchantMayDeleteOffer(offer);
        offerRepository.deleteById(id);
    }

    private void ensureMerchantOfferManagementAllowed() {
        if (isCurrentUserMerchant() && !merchantOfferManagementEnabled) {
            throw new ResponseStatusException(
                    HttpStatus.FORBIDDEN,
                    "La gestion des offres par commerce est desactivee. Utilise le back-office admin."
            );
        }
    }

    private SecurityUser requireSecurityUser() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth != null && auth.getPrincipal() instanceof SecurityUser su) {
            return su;
        }
        throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Authentification requise.");
    }

    private void ensureMerchantCreatesForOwnShopOnly(Long merchantIdInRequest) {
        if (!isCurrentUserMerchant()) return;
        SecurityUser su = requireSecurityUser();
        Long my = su.getMerchantId();
        if (my == null || merchantIdInRequest == null || !my.equals(merchantIdInRequest)) {
            throw new ResponseStatusException(
                    HttpStatus.FORBIDDEN,
                    "Tu ne peux gerer que les offres de ton commerce."
            );
        }
    }

    private void ensureMerchantOwnsOfferOrAdmin(Offer offer) {
        if (isCurrentUserAdmin()) return;
        if (!isCurrentUserMerchant()) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Acces refuse.");
        }
        SecurityUser su = requireSecurityUser();
        Long my = su.getMerchantId();
        if (my == null || offer.getMerchantId() == null || !my.equals(offer.getMerchantId())) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Tu ne peux gerer que les offres de ton commerce.");
        }
    }

    /** Le commerçant ne modifie que les propositions non encore validées. */
    private void ensureMerchantMayEditOffer(Offer offer) {
        if (isCurrentUserAdmin()) return;
        if (offer.getStatus() != OfferStatus.PROPOSED && offer.getStatus() != OfferStatus.PENDING) {
            throw new ResponseStatusException(
                    HttpStatus.FORBIDDEN,
                    "Seules les offres en attente de validation peuvent etre modifiees par le commerce."
            );
        }
    }

    private void ensureMerchantMayDeleteOffer(Offer offer) {
        if (isCurrentUserAdmin()) return;
        if (offer.getStatus() != OfferStatus.PROPOSED && offer.getStatus() != OfferStatus.PENDING) {
            throw new ResponseStatusException(
                    HttpStatus.FORBIDDEN,
                    "Seules les offres en attente de validation peuvent etre supprimees par le commerce."
            );
        }
    }

    private void mapRequestToEntity(OfferRequest req, Offer offer) {
        offer.setMerchantId(req.getMerchantId());
        offer.setCategoryId(req.getCategoryId());
        offer.setTitle(req.getTitle());
        offer.setDescription(req.getDescription());
        offer.setTermsConditions(req.getTermsConditions());
        offer.setOriginalPrice(req.getOriginalPrice());
        offer.setDiscountPercentage(req.getDiscountPercentage());
        offer.setDiscountAmount(req.getDiscountAmount());
        offer.setFinalPrice(req.getFinalPrice());
        final List<String> normalizedImages = normalizeImageUrls(req);
        offer.setImageUrl(normalizedImages.isEmpty() ? req.getImageUrl() : normalizedImages.get(0));
        if (req.getMaxCoupons() != null) offer.setMaxCoupons(req.getMaxCoupons());
        offer.setMaxPassesPerDayPerUser(req.getMaxPassesPerDayPerUser());
        offer.setMaxQuantityPerPass(req.getMaxQuantityPerPass());
        offer.setTargetUniversitiesCsv(normalizeCsv(req.getTargetUniversities()));
        offer.setStartDate(req.getStartDate());
        offer.setEndDate(req.getEndDate());
    }

    private List<String> normalizeImageUrls(OfferRequest req) {
        List<String> list = req.getImageUrls();
        if (list != null && !list.isEmpty()) {
            return list.stream()
                    .filter(s -> s != null && !s.isBlank())
                    .map(String::trim)
                    .limit(3)
                    .collect(Collectors.toList());
        }
        final String single = req.getImageUrl();
        if (single != null && !single.isBlank()) {
            return List.of(single.trim());
        }
        return List.of();
    }

    private void syncOfferImages(Offer offer, OfferRequest req) {
        final Long offerId = offer.getId();
        if (offerId == null) return;

        final List<String> urls = normalizeImageUrls(req);

        offerImageRepository.deleteByOfferId(offerId);
        if (urls.isEmpty()) return;

        int pos = 0;
        for (String url : urls) {
            OfferImage img = new OfferImage();
            img.setOfferId(offerId);
            img.setImageUrl(url);
            img.setPosition(pos++);
            img.setCreatedAt(LocalDateTime.now());
            offerImageRepository.save(img);
        }
    }

    private OfferResponse toResponse(Offer o) {
        OfferResponse r = new OfferResponse();
        r.setId(o.getId());
        r.setMerchantId(o.getMerchantId());
        r.setCategoryId(o.getCategoryId());
        r.setTitle(o.getTitle());
        r.setDescription(o.getDescription());
        r.setTermsConditions(o.getTermsConditions());
        r.setOriginalPrice(o.getOriginalPrice());
        r.setDiscountPercentage(o.getDiscountPercentage());
        r.setDiscountAmount(o.getDiscountAmount());
        r.setFinalPrice(o.getFinalPrice());
        r.setImageUrl(o.getImageUrl());
        final List<String> imageUrls = offerImageRepository
                .findByOfferIdOrderByPositionAsc(o.getId())
                .stream()
                .map(im -> im.getImageUrl())
                .filter(s -> s != null && !s.isBlank())
                .collect(Collectors.toList());
        if (imageUrls.isEmpty() && o.getImageUrl() != null && !o.getImageUrl().isBlank()) {
            r.setImageUrls(List.of(o.getImageUrl()));
        } else {
            r.setImageUrls(imageUrls);
        }
        r.setMaxCoupons(o.getMaxCoupons());
        r.setUsedCoupons(o.getUsedCoupons());
        r.setMaxPassesPerDayPerUser(o.getMaxPassesPerDayPerUser());
        r.setMaxQuantityPerPass(o.getMaxQuantityPerPass());
        r.setTargetUniversities(o.getTargetUniversitiesCsv());
        r.setStartDate(o.getStartDate());
        r.setEndDate(o.getEndDate());
        r.setStatus(o.getStatus());
        r.setCreatedAt(o.getCreatedAt());
        // Calcul des passages restants aujourd'hui pour l'utilisateur courant
        // -> on ne compte que les coupons réellement utilisés (status = USED)
        if (o.getMaxPassesPerDayPerUser() != null && o.getMaxPassesPerDayPerUser() > 0) {
            Authentication auth = SecurityContextHolder.getContext().getAuthentication();
            if (auth != null && auth.getPrincipal() instanceof SecurityUser su) {
                Long userId = su.getId();
                java.time.LocalDate today = java.time.LocalDate.now();
                java.time.LocalDateTime startOfDay = today.atStartOfDay();
                java.time.LocalDateTime endOfDay = today.plusDays(1).atStartOfDay();
                long usedToday = couponRepository
                        .countByUserIdAndOfferIdAndStatusAndGeneratedAtBetween(
                                userId, o.getId(), CouponStatus.USED, startOfDay, endOfDay);
                int remaining = (int) Math.max(0, o.getMaxPassesPerDayPerUser() - usedToday);
                r.setRemainingPassesTodayForCurrentUser(remaining);
            }
        }
        return r;
    }

    /** Distance Haversine en kilomètres entre deux points (lat/lng en degrés). */
    private double haversineKm(double lat1, double lon1, double lat2, double lon2) {
        final double R = 6371.0; // rayon Terre en km
        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lon2 - lon1);
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(dLon / 2) * Math.sin(dLon / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return R * c;
    }

    private String normalizeCsv(String csv) {
        if (csv == null || csv.isBlank()) {
            return null;
        }
        String normalized = java.util.Arrays.stream(csv.split(","))
                .map(String::trim)
                .filter(s -> !s.isEmpty())
                .distinct()
                .collect(Collectors.joining(", "));
        return normalized.isBlank() ? null : normalized;
    }
}
