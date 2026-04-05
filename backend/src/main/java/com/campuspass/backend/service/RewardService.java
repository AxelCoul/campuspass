package com.campuspass.backend.service;

import com.campuspass.backend.dto.RewardCatalogItemResponse;
import com.campuspass.backend.dto.RewardCatalogItemRequest;
import com.campuspass.backend.dto.RewardRedemptionResponse;
import com.campuspass.backend.dto.RewardsSummaryResponse;
import com.campuspass.backend.dto.AdminRewardRedemptionResponse;
import com.campuspass.backend.dto.AdminReferralStatsResponse;
import com.campuspass.backend.dto.AdminReferrerStatsRowResponse;
import com.campuspass.backend.dto.AdminReferralPayoutRequestResponse;
import com.campuspass.backend.model.RewardCatalogItem;
import com.campuspass.backend.model.RewardRedemption;
import com.campuspass.backend.model.User;
import com.campuspass.backend.model.enums.ReferralPayoutStatus;
import com.campuspass.backend.model.enums.SubscriptionStatus;
import com.campuspass.backend.model.enums.TransactionStatus;
import com.campuspass.backend.exception.ResourceNotFoundException;
import com.campuspass.backend.repository.RewardCatalogItemRepository;
import com.campuspass.backend.repository.RewardRedemptionRepository;
import com.campuspass.backend.repository.ReferralPayoutRequestRepository;
import com.campuspass.backend.repository.StudentProfileRepository;
import com.campuspass.backend.repository.StudentSubscriptionRepository;
import com.campuspass.backend.repository.TransactionRepository;
import com.campuspass.backend.repository.UserRepository;
import jakarta.annotation.PostConstruct;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class RewardService {
    private static final int POINTS_PER_REFERRAL = 5;

    private final RewardCatalogItemRepository rewardCatalogItemRepository;
    private final RewardRedemptionRepository rewardRedemptionRepository;
    private final ReferralPayoutRequestRepository referralPayoutRequestRepository;
    private final TransactionRepository transactionRepository;
    private final StudentProfileRepository studentProfileRepository;
    private final StudentSubscriptionRepository subscriptionRepository;
    private final UserRepository userRepository;
    private final LoyaltyConfigService loyaltyConfigService;

    public RewardService(RewardCatalogItemRepository rewardCatalogItemRepository,
                         RewardRedemptionRepository rewardRedemptionRepository,
                         ReferralPayoutRequestRepository referralPayoutRequestRepository,
                         TransactionRepository transactionRepository,
                         StudentProfileRepository studentProfileRepository,
                         StudentSubscriptionRepository subscriptionRepository,
                         UserRepository userRepository,
                         LoyaltyConfigService loyaltyConfigService) {
        this.rewardCatalogItemRepository = rewardCatalogItemRepository;
        this.rewardRedemptionRepository = rewardRedemptionRepository;
        this.referralPayoutRequestRepository = referralPayoutRequestRepository;
        this.transactionRepository = transactionRepository;
        this.studentProfileRepository = studentProfileRepository;
        this.subscriptionRepository = subscriptionRepository;
        this.userRepository = userRepository;
        this.loyaltyConfigService = loyaltyConfigService;
    }

    @PostConstruct
    @Transactional
    public void seedCatalogIfEmpty() {
        if (rewardCatalogItemRepository.count() > 0) return;

        createCatalogItem("Boisson offerte", "1 boisson gratuite chez les partenaires participants.", 120);
        createCatalogItem("Dessert offert", "Un dessert offert sur une commande eligibile.", 200);
        createCatalogItem("Reduction 2 000 FCFA", "Bon de reduction valable sur une prochaine commande.", 300);
        createCatalogItem("Reduction 5 000 FCFA", "Bon de reduction premium valable chez nos partenaires.", 650);
    }

    @Transactional(readOnly = true)
    public RewardsSummaryResponse getSummary(Long userId) {
        User user = userRepository.findById(userId).orElseThrow();
        int fcfaPerPoint = loyaltyConfigService.getFcfaPerPoint();
        int totalPoints = computeTotalPoints(userId);
        int spentPoints = safeInt(rewardRedemptionRepository.totalSpentByUserId(userId));
        int availablePoints = Math.max(0, totalPoints - spentPoints);
        int referralsCount = (int) countActiveSubscribedReferrals(user.getReferralCode());
        int referralBonusPoints = referralsCount * POINTS_PER_REFERRAL;

        List<RewardCatalogItemResponse> catalog = rewardCatalogItemRepository
                .findByActiveTrueOrderByPointsCostAsc()
                .stream()
                .map(this::toCatalogResponse)
                .toList();

        RewardsSummaryResponse response = new RewardsSummaryResponse();
        response.setTotalPoints(totalPoints);
        response.setSpentPoints(spentPoints);
        response.setAvailablePoints(availablePoints);
        response.setFcfaPerPoint(fcfaPerPoint);
        response.setReferralsCount(referralsCount);
        response.setPointsPerReferral(POINTS_PER_REFERRAL);
        response.setReferralBonusPoints(referralBonusPoints);
        response.setCatalog(catalog);
        return response;
    }

    @Transactional(readOnly = true)
    public List<RewardRedemptionResponse> getHistory(Long userId) {
        return rewardRedemptionRepository.findByUserIdOrderByRedeemedAtDesc(userId)
                .stream()
                .map(this::toRedemptionResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public List<AdminRewardRedemptionResponse> getAllRedemptionsForAdmin() {
        return rewardRedemptionRepository.findAllByOrderByRedeemedAtDesc()
                .stream()
                .map(redemption -> {
                    AdminRewardRedemptionResponse response = new AdminRewardRedemptionResponse();
                    response.setId(redemption.getId());
                    response.setUserId(redemption.getUserId());
                    response.setRewardId(redemption.getRewardId());
                    response.setRewardTitle(redemption.getRewardTitle());
                    response.setPointsCost(redemption.getPointsCost());
                    response.setRedeemedAt(redemption.getRedeemedAt());

                    userRepository.findById(redemption.getUserId()).ifPresent(user -> {
                        String fullName = ((user.getFirstName() != null ? user.getFirstName() : "") + " " +
                                (user.getLastName() != null ? user.getLastName() : "")).trim();
                        response.setStudentName(fullName.isEmpty() ? "Étudiant" : fullName);
                        response.setStudentEmail(user.getEmail());
                    });
                    return response;
                })
                .toList();
    }

    @Transactional(readOnly = true)
    public List<AdminReferralPayoutRequestResponse> getPayoutRequestsForAdmin() {
        return referralPayoutRequestRepository.findAllByOrderByRequestedAtDesc().stream()
                .map(req -> {
                    AdminReferralPayoutRequestResponse dto = new AdminReferralPayoutRequestResponse();
                    dto.setId(req.getId());
                    dto.setReferrerId(req.getReferrerId());
                    dto.setRequestYear(req.getRequestYear());
                    dto.setRequestMonth(req.getRequestMonth());
                    dto.setAmountFcfa(req.getAmountFcfa());
                    dto.setStatus(req.getStatus().name());
                    dto.setRequestedAt(req.getRequestedAt());
                    userRepository.findById(req.getReferrerId()).ifPresent(u -> {
                        dto.setStudentName(((u.getFirstName() != null ? u.getFirstName() : "") + " " +
                                (u.getLastName() != null ? u.getLastName() : "")).trim());
                        dto.setStudentEmail(u.getEmail());
                    });
                    return dto;
                })
                .toList();
    }

    @Transactional
    public void markPayoutRequestPaid(Long requestId) {
        var req = referralPayoutRequestRepository.findById(requestId)
                .orElseThrow(() -> new ResourceNotFoundException("ReferralPayoutRequest", requestId));
        req.setStatus(ReferralPayoutStatus.PAID);
        referralPayoutRequestRepository.save(req);
    }

    @Transactional
    public void rejectPayoutRequest(Long requestId) {
        var req = referralPayoutRequestRepository.findById(requestId)
                .orElseThrow(() -> new ResourceNotFoundException("ReferralPayoutRequest", requestId));
        req.setStatus(ReferralPayoutStatus.REJECTED);
        referralPayoutRequestRepository.save(req);
    }

    @Transactional(readOnly = true)
    public AdminReferralStatsResponse getReferralStatsForAdmin() {
        long registered = userRepository.findAll().stream()
                .filter(u -> u.getReferredByCode() != null && !u.getReferredByCode().isBlank())
                .count();

        long activeSubscribed = userRepository.findAll().stream()
                .filter(u -> u.getReferredByCode() != null && !u.getReferredByCode().isBlank())
                .filter(u -> subscriptionRepository
                        .findFirstByStudentIdAndStatusOrderByEndDateDesc(u.getId(), SubscriptionStatus.ACTIVE)
                        .map(sub -> !java.time.LocalDate.now().isAfter(sub.getEndDate()))
                        .orElse(false))
                .count();

        AdminReferralStatsResponse response = new AdminReferralStatsResponse();
        response.setRegisteredReferrals(registered);
        response.setActiveSubscribedReferrals(activeSubscribed);
        return response;
    }

    @Transactional(readOnly = true)
    public List<AdminReferrerStatsRowResponse> getReferrersStatsForAdmin(
            java.time.LocalDate dateFrom,
            java.time.LocalDate dateTo,
            String university,
            Integer top) {
        String universityFilter = university == null ? null : university.trim().toLowerCase();

        return userRepository.findAll().stream()
                .filter(u -> u.getReferralCode() != null && !u.getReferralCode().isBlank())
                .map(referrer -> {
                    var referredUsers = userRepository.findByReferredByCodeIgnoreCase(referrer.getReferralCode());
                    var filteredReferredUsers = referredUsers.stream()
                            .filter(u -> matchDateRange(u, dateFrom, dateTo))
                            .filter(u -> matchUniversity(u, universityFilter))
                            .toList();
                    long registeredReferrals = filteredReferredUsers.size();
                    long activeSubscribedReferrals = filteredReferredUsers.stream()
                            .filter(u -> subscriptionRepository
                                    .findFirstByStudentIdAndStatusOrderByEndDateDesc(u.getId(), SubscriptionStatus.ACTIVE)
                                    .map(sub -> !java.time.LocalDate.now().isAfter(sub.getEndDate()))
                                    .orElse(false))
                            .count();

                    AdminReferrerStatsRowResponse row = new AdminReferrerStatsRowResponse();
                    row.setUserId(referrer.getId());
                    row.setStudentName(((referrer.getFirstName() != null ? referrer.getFirstName() : "") + " " +
                            (referrer.getLastName() != null ? referrer.getLastName() : "")).trim());
                    row.setStudentEmail(referrer.getEmail());
                    row.setReferralCode(referrer.getReferralCode());
                    row.setRegisteredReferrals(registeredReferrals);
                    row.setActiveSubscribedReferrals(activeSubscribedReferrals);
                    row.setPointsPerReferral(POINTS_PER_REFERRAL);
                    row.setPointsEarned(activeSubscribedReferrals * POINTS_PER_REFERRAL);
                    return row;
                })
                .filter(row -> row.getRegisteredReferrals() > 0 || row.getActiveSubscribedReferrals() > 0)
                .sorted((a, b) -> Long.compare(b.getPointsEarned(), a.getPointsEarned()))
                .limit(top != null && top > 0 ? top : Long.MAX_VALUE)
                .toList();
    }

    private boolean matchDateRange(User referredUser, java.time.LocalDate dateFrom, java.time.LocalDate dateTo) {
        if (referredUser.getCreatedAt() == null) return false;
        java.time.LocalDate d = referredUser.getCreatedAt().toLocalDate();
        if (dateFrom != null && d.isBefore(dateFrom)) return false;
        if (dateTo != null && d.isAfter(dateTo)) return false;
        return true;
    }

    private boolean matchUniversity(User referredUser, String universityFilter) {
        if (universityFilter == null || universityFilter.isBlank()) return true;
        return studentProfileRepository.findByUserId(referredUser.getId())
                .map(sp -> sp.getUniversity() != null && sp.getUniversity().trim().toLowerCase().contains(universityFilter))
                .orElse(false);
    }

    @Transactional(readOnly = true)
    public List<RewardCatalogItemResponse> getCatalogForAdmin() {
        return rewardCatalogItemRepository.findAll().stream()
                .sorted((a, b) -> {
                    int activeCompare = Boolean.compare(Boolean.TRUE.equals(b.getActive()), Boolean.TRUE.equals(a.getActive()));
                    if (activeCompare != 0) return activeCompare;
                    return Integer.compare(a.getPointsCost(), b.getPointsCost());
                })
                .map(this::toCatalogResponse)
                .toList();
    }

    @Transactional
    public RewardCatalogItemResponse createCatalogItem(RewardCatalogItemRequest request) {
        RewardCatalogItem item = new RewardCatalogItem();
        item.setTitle(request.getTitle().trim());
        item.setDescription(request.getDescription().trim());
        item.setPointsCost(request.getPointsCost());
        item.setActive(Boolean.TRUE.equals(request.getActive()));
        item.setCreatedAt(LocalDateTime.now());
        item.setUpdatedAt(LocalDateTime.now());
        return toCatalogResponse(rewardCatalogItemRepository.save(item));
    }

    @Transactional
    public RewardCatalogItemResponse updateCatalogItem(Long id, RewardCatalogItemRequest request) {
        RewardCatalogItem item = rewardCatalogItemRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("RewardCatalogItem", id));
        item.setTitle(request.getTitle().trim());
        item.setDescription(request.getDescription().trim());
        item.setPointsCost(request.getPointsCost());
        item.setActive(Boolean.TRUE.equals(request.getActive()));
        item.setUpdatedAt(LocalDateTime.now());
        return toCatalogResponse(rewardCatalogItemRepository.save(item));
    }

    @Transactional
    public void deleteCatalogItem(Long id) {
        if (!rewardCatalogItemRepository.existsById(id)) {
            throw new ResourceNotFoundException("RewardCatalogItem", id);
        }
        rewardCatalogItemRepository.deleteById(id);
    }

    @Transactional
    public void setCatalogItemActive(Long id, boolean active) {
        RewardCatalogItem item = rewardCatalogItemRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("RewardCatalogItem", id));
        item.setActive(active);
        item.setUpdatedAt(LocalDateTime.now());
        rewardCatalogItemRepository.save(item);
    }

    @Transactional
    public RewardRedemptionResponse redeem(Long userId, Long rewardId) {
        if (rewardId == null) {
            throw new IllegalArgumentException("rewardId requis");
        }

        RewardCatalogItem reward = rewardCatalogItemRepository.findById(rewardId)
                .orElseThrow(() -> new IllegalArgumentException("Cadeau introuvable"));
        if (!Boolean.TRUE.equals(reward.getActive())) {
            throw new IllegalArgumentException("Ce cadeau est indisponible");
        }

        int totalPoints = computeTotalPoints(userId);
        int spentPoints = safeInt(rewardRedemptionRepository.totalSpentByUserId(userId));
        int availablePoints = Math.max(0, totalPoints - spentPoints);

        if (availablePoints < reward.getPointsCost()) {
            throw new IllegalArgumentException("Points insuffisants");
        }

        RewardRedemption redemption = new RewardRedemption();
        redemption.setUserId(userId);
        redemption.setRewardId(reward.getId());
        redemption.setRewardTitle(reward.getTitle());
        redemption.setPointsCost(reward.getPointsCost());
        redemption.setRedeemedAt(LocalDateTime.now());

        RewardRedemption saved = rewardRedemptionRepository.save(redemption);
        return toRedemptionResponse(saved);
    }

    private RewardCatalogItemResponse toCatalogResponse(RewardCatalogItem item) {
        RewardCatalogItemResponse response = new RewardCatalogItemResponse();
        response.setId(item.getId());
        response.setTitle(item.getTitle());
        response.setDescription(item.getDescription());
        response.setPointsCost(item.getPointsCost());
        response.setActive(item.getActive());
        return response;
    }

    private RewardRedemptionResponse toRedemptionResponse(RewardRedemption redemption) {
        RewardRedemptionResponse response = new RewardRedemptionResponse();
        response.setId(redemption.getId());
        response.setRewardId(redemption.getRewardId());
        response.setRewardTitle(redemption.getRewardTitle());
        response.setPointsCost(redemption.getPointsCost());
        response.setRedeemedAt(redemption.getRedeemedAt());
        return response;
    }

    private int computeTotalPoints(Long userId) {
        User user = userRepository.findById(userId).orElseThrow();

        double totalSaved = transactionRepository.findByUserIdOrderByTransactionDateDesc(userId).stream()
                .filter(t -> t.getStatus() == TransactionStatus.SUCCESS)
                .mapToDouble(t -> t.getDiscountAmount() != null ? t.getDiscountAmount() : 0.0)
                .sum();
        int fcfaPerPoint = loyaltyConfigService.getFcfaPerPoint();
        int savingsPoints = (int) (totalSaved / fcfaPerPoint);
        long referralsCount = countActiveSubscribedReferrals(user.getReferralCode());
        int referralPoints = (int) referralsCount * POINTS_PER_REFERRAL;
        return savingsPoints + referralPoints;
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
        return subscriptionRepository.findByStudentIdOrderByEndDateDesc(referred.getId()).stream()
                .anyMatch(sub -> !linkedAt.toLocalDate().isAfter(sub.getStartDate()));
    }

    private int safeInt(Integer value) {
        return value == null ? 0 : value;
    }

    private void createCatalogItem(String title, String description, int pointsCost) {
        RewardCatalogItem item = new RewardCatalogItem();
        item.setTitle(title);
        item.setDescription(description);
        item.setPointsCost(pointsCost);
        item.setActive(true);
        item.setCreatedAt(LocalDateTime.now());
        item.setUpdatedAt(LocalDateTime.now());
        rewardCatalogItemRepository.save(item);
    }
}
