package com.campuspass.backend.service;

import com.campuspass.backend.dto.MerchantRequest;
import com.campuspass.backend.dto.MerchantResponse;
import com.campuspass.backend.dto.MerchantStatsDto;
import com.campuspass.backend.dto.TransactionResponseDto;
import com.campuspass.backend.dto.MerchantStaffRequest;
import com.campuspass.backend.dto.UserResponseDto;
import com.campuspass.backend.exception.ResourceNotFoundException;
import com.campuspass.backend.model.Merchant;
import com.campuspass.backend.model.Transaction;
import com.campuspass.backend.model.User;
import com.campuspass.backend.model.enums.MerchantRole;
import com.campuspass.backend.model.enums.UserRole;
import com.campuspass.backend.model.enums.UserStatus;
import com.campuspass.backend.model.enums.OfferStatus;
import com.campuspass.backend.model.enums.TransactionStatus;
import com.campuspass.backend.repository.MerchantRepository;
import com.campuspass.backend.repository.OfferRepository;
import com.campuspass.backend.repository.TransactionRepository;
import com.campuspass.backend.repository.UserRepository;
import com.campuspass.backend.repository.ReviewRepository;
import com.campuspass.backend.util.MerchantRatingUtils;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class MerchantService {

    private final MerchantRepository merchantRepository;
    private final TransactionRepository transactionRepository;
    private final OfferRepository offerRepository;
    private final UserRepository userRepository;
    private final ReviewRepository reviewRepository;

    public MerchantService(MerchantRepository merchantRepository,
                           TransactionRepository transactionRepository,
                           OfferRepository offerRepository,
                           UserRepository userRepository,
                           ReviewRepository reviewRepository) {
        this.merchantRepository = merchantRepository;
        this.transactionRepository = transactionRepository;
        this.offerRepository = offerRepository;
        this.userRepository = userRepository;
        this.reviewRepository = reviewRepository;
    }

    public List<MerchantResponse> findAll() {
        return merchantRepository.findAll().stream().map(this::toResponse).collect(Collectors.toList());
    }

    public List<MerchantResponse> findByOwnerId(Long ownerId) {
        return merchantRepository.findByOwnerId(ownerId).stream().map(this::toResponse).collect(Collectors.toList());
    }

    public MerchantResponse getById(Long id) {
        Merchant m = merchantRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Merchant", id));
        return toResponse(m);
    }

    @Transactional
    public MerchantResponse create(Long ownerId, MerchantRequest req) {
        Merchant m = new Merchant();
        m.setOwnerId(ownerId);
        mapRequestToEntity(req, m);
        m.setCreatedAt(LocalDateTime.now());
        m.setUpdatedAt(LocalDateTime.now());
        m = merchantRepository.save(m);
        return toResponse(m);
    }

    @Transactional
    public MerchantResponse update(Long id, MerchantRequest req) {
        Merchant m = merchantRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Merchant", id));
        mapRequestToEntity(req, m);
        m.setUpdatedAt(LocalDateTime.now());
        m = merchantRepository.save(m);
        return toResponse(m);
    }

    public List<TransactionResponseDto> getTransactionsByMerchantId(Long merchantId) {
        return transactionRepository.findByMerchantIdOrderByTransactionDateDesc(merchantId).stream()
                .map(this::toTransactionDto).collect(Collectors.toList());
    }

    public MerchantStatsDto getStatsByMerchantId(Long merchantId) {
        MerchantStatsDto dto = new MerchantStatsDto();
        LocalDate today = LocalDate.now();
        List<Transaction> all = transactionRepository.findByMerchantIdOrderByTransactionDateDesc(merchantId);
        List<Transaction> success = all.stream()
                .filter(t -> t.getStatus() == TransactionStatus.SUCCESS)
                .toList();
        long countToday = success.stream()
                .filter(t -> t.getTransactionDate() != null && t.getTransactionDate().toLocalDate().equals(today))
                .count();
        double revenueToday = success.stream()
                .filter(t -> t.getTransactionDate() != null && t.getTransactionDate().toLocalDate().equals(today))
                .mapToDouble(t -> t.getFinalAmount() != null ? t.getFinalAmount() : 0.0)
                .sum();
        int activeOffers = (int) offerRepository.findByMerchantIdOrderByCreatedAtDesc(merchantId).stream()
                .filter(o -> o.getStatus() == OfferStatus.ACTIVE).count();
        double totalSalesViaApp = success.stream()
                .mapToDouble(t -> t.getFinalAmount() != null ? t.getFinalAmount() : 0.0)
                .sum();
        double totalDiscountsGiven = success.stream()
                .mapToDouble(t -> t.getDiscountAmount() != null ? t.getDiscountAmount() : 0.0)
                .sum();
        long uniqueClients = success.stream().map(Transaction::getUserId).distinct().count();
        var offers = offerRepository.findByMerchantIdOrderByCreatedAtDesc(merchantId);
        var topOffer = offers.stream()
                .filter(o -> o.getUsedCoupons() != null && o.getUsedCoupons() > 0)
                .max(java.util.Comparator.comparingInt(o -> o.getUsedCoupons() != null ? o.getUsedCoupons() : 0))
                .orElse(null);
        dto.setCouponsUsedToday(countToday);
        dto.setRevenueToday(revenueToday);
        dto.setActiveOffersCount(activeOffers);
        dto.setTotalSalesViaApp(totalSalesViaApp);
        dto.setTotalDiscountsGiven(totalDiscountsGiven);
        dto.setUniqueClientsCount((int) uniqueClients);
        if (topOffer != null) {
            dto.setTopOfferTitle(topOffer.getTitle());
            dto.setTopOfferUsageCount(topOffer.getUsedCoupons() != null ? topOffer.getUsedCoupons() : 0L);
        } else {
            dto.setTopOfferUsageCount(0L);
        }
        return dto;
    }

    public List<UserResponseDto> getTeamForMerchant(Long merchantId, Long requesterUserId) {
        Merchant m = merchantRepository.findById(merchantId)
                .orElseThrow(() -> new ResourceNotFoundException("Merchant", merchantId));
        // Seul le propriétaire peut voir / gérer son équipe
        if (!m.getOwnerId().equals(requesterUserId)) {
            throw new IllegalArgumentException("Accès refusé pour ce commerce.");
        }
        return userRepository.findByMerchantId(merchantId).stream()
                .map(this::toUserDto)
                .toList();
    }

    @Transactional
    public UserResponseDto createStaffForMerchant(Long merchantId, Long requesterUserId, MerchantStaffRequest req) {
        Merchant m = merchantRepository.findById(merchantId)
                .orElseThrow(() -> new ResourceNotFoundException("Merchant", merchantId));
        if (!m.getOwnerId().equals(requesterUserId)) {
            throw new IllegalArgumentException("Accès refusé pour ce commerce.");
        }
        if (req.getEmail() != null && !req.getEmail().isBlank() &&
                userRepository.existsByEmailIgnoreCase(req.getEmail().trim().toLowerCase())) {
            throw new IllegalArgumentException("Un compte existe déjà avec cet email.");
        }
        User u = new User();
        u.setFirstName(req.getFirstName());
        u.setLastName(req.getLastName());
        if (req.getEmail() != null && !req.getEmail().isBlank()) {
            u.setEmail(req.getEmail().trim().toLowerCase());
        }
        // Le mot de passe doit déjà être encodé côté appelant (pour simplifier, on laisse AuthService gérer
        // la création de comptes si besoin). Ici, on initialise un compte inactif.
        u.setPassword(""); // à mettre à jour via un flux "définir mon mot de passe"
        u.setPhoneNumber(req.getPhoneNumber());
        u.setRole(UserRole.MERCHANT);
        u.setMerchantRole(req.getMerchantRole() != null ? req.getMerchantRole() : MerchantRole.STAFF);
        u.setStatus(UserStatus.ACTIVE);
        u.setCreatedAt(LocalDateTime.now());
        u.setUpdatedAt(LocalDateTime.now());
        u.setMerchantId(merchantId);
        u = userRepository.save(u);
        return toUserDto(u);
    }

    private UserResponseDto toUserDto(User u) {
        UserResponseDto dto = new UserResponseDto();
        dto.setId(u.getId());
        dto.setFirstName(u.getFirstName());
        dto.setLastName(u.getLastName());
        dto.setEmail(u.getEmail());
        dto.setPhoneNumber(u.getPhoneNumber());
        dto.setRole(u.getRole());
        dto.setMerchantRole(u.getMerchantRole());
        dto.setStatus(u.getStatus());
        dto.setCreatedAt(u.getCreatedAt());
        return dto;
    }

    private TransactionResponseDto toTransactionDto(Transaction t) {
        TransactionResponseDto dto = new TransactionResponseDto();
        dto.setId(t.getId());
        dto.setCouponId(t.getCouponId());
        dto.setUserId(t.getUserId());
        dto.setMerchantId(t.getMerchantId());
        dto.setOfferId(t.getOfferId());
        dto.setOriginalAmount(t.getOriginalAmount());
        dto.setDiscountAmount(t.getDiscountAmount());
        dto.setFinalAmount(t.getFinalAmount());
        dto.setStatus(t.getStatus());
        dto.setTransactionDate(t.getTransactionDate());
        return dto;
    }

    private void mapRequestToEntity(MerchantRequest req, Merchant m) {
        if (req.getName() != null) m.setName(req.getName());
        m.setDescription(req.getDescription());
        m.setEmail(req.getEmail());
        m.setPhone(req.getPhone());
        m.setWebsite(req.getWebsite());
        m.setLogoUrl(req.getLogoUrl());
        m.setCoverImage(req.getCoverImage());
        m.setCategoryId(req.getCategoryId());
        m.setAddress(req.getAddress());
        m.setCity(req.getCity());
        m.setNeighborhood(req.getNeighborhood());
        m.setCountry(req.getCountry());
        m.setLatitude(req.getLatitude());
        m.setLongitude(req.getLongitude());
        m.setOpeningHours(req.getOpeningHours());
    }

    private MerchantResponse toResponse(Merchant m) {
        MerchantResponse r = new MerchantResponse();
        r.setId(m.getId());
        r.setOwnerId(m.getOwnerId());
        r.setName(m.getName());
        r.setDescription(m.getDescription());
        r.setEmail(m.getEmail());
        r.setPhone(m.getPhone());
        r.setWebsite(m.getWebsite());
        r.setLogoUrl(m.getLogoUrl());
        r.setCoverImage(m.getCoverImage());
        r.setCategoryId(m.getCategoryId());
        r.setAddress(m.getAddress());
        r.setCity(m.getCity());
        r.setNeighborhood(m.getNeighborhood());
        r.setCountry(m.getCountry());
        r.setLatitude(m.getLatitude());
        r.setLongitude(m.getLongitude());
        r.setOpeningHours(m.getOpeningHours());
        r.setVerified(m.getVerified());
        r.setStatus(m.getStatus());
        r.setCreatedAt(m.getCreatedAt());

        var reviews = reviewRepository.findByMerchantIdOrderByCreatedAtDesc(m.getId());
        MerchantRatingUtils.applyAggregatedRating(r, reviews);
        return r;
    }
}
