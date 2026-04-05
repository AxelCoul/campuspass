package com.campuspass.backend.controller;

import com.campuspass.backend.dto.*;
import com.campuspass.backend.dto.SubscriptionPlanRequest;
import com.campuspass.backend.dto.SubscriptionPlanResponse;
import com.campuspass.backend.model.enums.UserStatus;
import com.campuspass.backend.model.enums.ReviewStatus;
import com.campuspass.backend.model.enums.OfferStatus;
import com.campuspass.backend.service.AdminService;
import com.campuspass.backend.service.LoyaltyConfigService;
import com.campuspass.backend.service.RewardService;
import com.campuspass.backend.service.SubscriptionService;
import com.campuspass.backend.service.SubscriptionPlanService;
import com.campuspass.backend.security.SecurityUser;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/admin")
public class AdminController {

    private final AdminService adminService;
    private final SubscriptionPlanService subscriptionPlanService;
    private final RewardService rewardService;
    private final LoyaltyConfigService loyaltyConfigService;
    private final SubscriptionService subscriptionService;

    public AdminController(AdminService adminService,
                           SubscriptionPlanService subscriptionPlanService,
                           RewardService rewardService,
                           LoyaltyConfigService loyaltyConfigService,
                           SubscriptionService subscriptionService) {
        this.adminService = adminService;
        this.subscriptionPlanService = subscriptionPlanService;
        this.rewardService = rewardService;
        this.loyaltyConfigService = loyaltyConfigService;
        this.subscriptionService = subscriptionService;
    }

    @GetMapping("/dashboard/stats")
    public ResponseEntity<DashboardStatsDto> getDashboardStats() {
        return ResponseEntity.ok(adminService.getDashboardStats());
    }

    @GetMapping("/dashboard/payments")
    public ResponseEntity<PaymentDashboardDto> getPaymentDashboardStats() {
        return ResponseEntity.ok(adminService.getPaymentDashboardStats());
    }

    @GetMapping("/users")
    public ResponseEntity<List<UserResponseDto>> getUsers() {
        return ResponseEntity.ok(adminService.getAllUsers());
    }

    @GetMapping("/users/{id}")
    public ResponseEntity<UserResponseDto> getUserById(@PathVariable Long id) {
        return ResponseEntity.ok(adminService.getUserById(id));
    }

    @GetMapping("/coupons")
    public ResponseEntity<List<CouponResponse>> getCoupons() {
        return ResponseEntity.ok(adminService.getAllCoupons());
    }

    @GetMapping("/transactions")
    public ResponseEntity<List<TransactionResponseDto>> getTransactions() {
        return ResponseEntity.ok(adminService.getAllTransactions());
    }

    @GetMapping("/payments")
    public ResponseEntity<List<PaymentResponseDto>> getPayments() {
        return ResponseEntity.ok(adminService.getAllPayments());
    }

    @GetMapping("/subscription-payments")
    public ResponseEntity<List<AdminSubscriptionPaymentResponse>> getSubscriptionPayments() {
        return ResponseEntity.ok(subscriptionService.getAllSubscriptionPaymentsForAdmin());
    }

    @GetMapping("/subscription-payments/alerts")
    public ResponseEntity<AdminPaymentAlertsResponse> getSubscriptionPaymentAlerts() {
        return ResponseEntity.ok(subscriptionService.getAdminPaymentAlerts());
    }

    @PostMapping("/subscription-payments/{id}/recheck")
    public ResponseEntity<Map<String, Object>> recheckSubscriptionPayment(@AuthenticationPrincipal SecurityUser user,
                                                                          @PathVariable Long id) {
        if (user == null || user.getId() == null) return ResponseEntity.status(401).build();
        adminService.requireSuperAdmin(user.getId());
        return ResponseEntity.ok(subscriptionService.recheckPaymentAsAdmin(id, user.getId()));
    }

    @PostMapping("/subscription-payments/{id}/relaunch")
    public ResponseEntity<Map<String, Object>> relaunchSubscriptionPayment(@AuthenticationPrincipal SecurityUser user,
                                                                           @PathVariable Long id) {
        if (user == null || user.getId() == null) return ResponseEntity.status(401).build();
        adminService.requireSuperAdmin(user.getId());
        return ResponseEntity.ok(subscriptionService.relaunchPaymentAsAdmin(id, user.getId()));
    }

    @GetMapping("/students")
    public ResponseEntity<List<StudentResponseDto>> getStudents() {
        return ResponseEntity.ok(adminService.getStudents());
    }

    @PatchMapping("/users/{id}/status")
    public ResponseEntity<Void> updateUserStatus(@PathVariable Long id, @RequestBody Map<String, String> body) {
        String statusStr = body.get("status");
        if (statusStr == null) return ResponseEntity.badRequest().build();
        UserStatus status = UserStatus.valueOf(statusStr.toUpperCase());
        adminService.updateUserStatus(id, status);
        return ResponseEntity.ok().build();
    }

    @PatchMapping("/students/{id}/validate-card")
    public ResponseEntity<Void> validateStudentCard(@PathVariable Long id) {
        adminService.validateStudentCard(id);
        return ResponseEntity.ok().build();
    }

    @PatchMapping("/students/{id}/reject-card")
    public ResponseEntity<Void> rejectStudentCard(@PathVariable Long id,
                                                  @Valid @RequestBody RejectStudentVerificationRequest body) {
        adminService.rejectStudentCard(id, body.getReason());
        return ResponseEntity.ok().build();
    }

    @GetMapping("/admins")
    public ResponseEntity<List<AdminResponseDto>> getAdmins() {
        return ResponseEntity.ok(adminService.getAdmins());
    }

    @PostMapping("/admins")
    public ResponseEntity<AdminResponseDto> createAdmin(@Valid @RequestBody CreateAdminRequest request) {
        return ResponseEntity.ok(adminService.createAdmin(request));
    }

    @PatchMapping("/admins/{id}/role")
    public ResponseEntity<Void> updateAdminRole(@PathVariable Long id, @RequestBody Map<String, String> body) {
        String adminLevel = body.get("adminLevel");
        adminService.updateAdminLevel(id, adminLevel != null ? adminLevel : "ADMIN");
        return ResponseEntity.ok().build();
    }

    @PatchMapping("/admins/{id}/disable")
    public ResponseEntity<Void> disableAdmin(@PathVariable Long id) {
        adminService.disableAdmin(id);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/dashboard/charts")
    public ResponseEntity<DashboardChartsDto> getDashboardCharts() {
        return ResponseEntity.ok(adminService.getDashboardCharts());
    }

    @GetMapping("/logs")
    public ResponseEntity<List<LogEntryDto>> getLogs(@RequestParam(defaultValue = "100") int limit) {
        return ResponseEntity.ok(adminService.getLogs(limit));
    }

    @GetMapping("/reviews")
    public ResponseEntity<List<ReviewResponse>> getReviews(@RequestParam(required = false) Long merchantId) {
        return ResponseEntity.ok(adminService.getAllReviews(merchantId));
    }

    @PatchMapping("/reviews/{id}/status")
    public ResponseEntity<Void> updateReviewStatus(@PathVariable Long id, @RequestBody Map<String, String> body) {
        String statusStr = body.get("status");
        if (statusStr == null) return ResponseEntity.badRequest().build();
        ReviewStatus status = ReviewStatus.valueOf(statusStr.toUpperCase());
        adminService.updateReviewStatus(id, status);
        return ResponseEntity.ok().build();
    }

    @PatchMapping("/offers/{id}/status")
    public ResponseEntity<Void> updateOfferStatus(@PathVariable Long id, @RequestBody Map<String, String> body) {
        String statusStr = body.get("status");
        if (statusStr == null) return ResponseEntity.badRequest().build();
        OfferStatus status = OfferStatus.valueOf(statusStr.toUpperCase());
        adminService.updateOfferStatus(id, status);
        return ResponseEntity.ok().build();
    }

    @PutMapping("/merchants/{id}/approve")
    public ResponseEntity<MerchantResponse> approveMerchant(@PathVariable Long id) {
        return ResponseEntity.ok(adminService.approveMerchant(id));
    }

    @PutMapping("/merchants/{id}/reject")
    public ResponseEntity<Void> rejectMerchant(@PathVariable Long id) {
        adminService.rejectMerchant(id);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/plans")
    public ResponseEntity<List<SubscriptionPlanResponse>> getAllPlans() {
        return ResponseEntity.ok(subscriptionPlanService.findAll());
    }

    @PostMapping("/plans")
    public ResponseEntity<SubscriptionPlanResponse> createPlan(@Valid @RequestBody SubscriptionPlanRequest request) {
        return ResponseEntity.ok(subscriptionPlanService.create(request));
    }

    @PutMapping("/plans/{id}")
    public ResponseEntity<SubscriptionPlanResponse> updatePlan(@PathVariable Long id, @Valid @RequestBody SubscriptionPlanRequest request) {
        return ResponseEntity.ok(subscriptionPlanService.update(id, request));
    }

    @DeleteMapping("/plans/{id}")
    public ResponseEntity<Void> deletePlan(@PathVariable Long id) {
        subscriptionPlanService.delete(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/rewards/catalog")
    public ResponseEntity<List<RewardCatalogItemResponse>> getRewardsCatalog() {
        return ResponseEntity.ok(rewardService.getCatalogForAdmin());
    }

    @PostMapping("/rewards/catalog")
    public ResponseEntity<RewardCatalogItemResponse> createRewardCatalogItem(
            @Valid @RequestBody RewardCatalogItemRequest request) {
        return ResponseEntity.ok(rewardService.createCatalogItem(request));
    }

    @PutMapping("/rewards/catalog/{id}")
    public ResponseEntity<RewardCatalogItemResponse> updateRewardCatalogItem(
            @PathVariable Long id,
            @Valid @RequestBody RewardCatalogItemRequest request) {
        return ResponseEntity.ok(rewardService.updateCatalogItem(id, request));
    }

    @PatchMapping("/rewards/catalog/{id}/active")
    public ResponseEntity<Void> setRewardCatalogItemActive(@PathVariable Long id, @RequestBody Map<String, Boolean> body) {
        Boolean active = body.get("active");
        if (active == null) return ResponseEntity.badRequest().build();
        rewardService.setCatalogItemActive(id, active);
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/rewards/catalog/{id}")
    public ResponseEntity<Void> deleteRewardCatalogItem(@PathVariable Long id) {
        rewardService.deleteCatalogItem(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/rewards/redemptions")
    public ResponseEntity<List<AdminRewardRedemptionResponse>> getAllRewardRedemptions() {
        return ResponseEntity.ok(rewardService.getAllRedemptionsForAdmin());
    }

    @GetMapping("/rewards/referrals-stats")
    public ResponseEntity<AdminReferralStatsResponse> getReferralStats() {
        return ResponseEntity.ok(rewardService.getReferralStatsForAdmin());
    }

    @GetMapping("/rewards/payout-requests")
    public ResponseEntity<List<AdminReferralPayoutRequestResponse>> getReferralPayoutRequests() {
        return ResponseEntity.ok(rewardService.getPayoutRequestsForAdmin());
    }

    @PatchMapping("/rewards/payout-requests/{id}/paid")
    public ResponseEntity<Void> markReferralPayoutPaid(@PathVariable Long id) {
        rewardService.markPayoutRequestPaid(id);
        return ResponseEntity.ok().build();
    }

    @PatchMapping("/rewards/payout-requests/{id}/reject")
    public ResponseEntity<Void> rejectReferralPayout(@PathVariable Long id) {
        rewardService.rejectPayoutRequest(id);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/rewards/referrers-stats")
    public ResponseEntity<List<AdminReferrerStatsRowResponse>> getReferrersStats(
            @RequestParam(required = false) java.time.LocalDate dateFrom,
            @RequestParam(required = false) java.time.LocalDate dateTo,
            @RequestParam(required = false) String university,
            @RequestParam(required = false) Integer top) {
        return ResponseEntity.ok(rewardService.getReferrersStatsForAdmin(dateFrom, dateTo, university, top));
    }

    @GetMapping("/rewards/config")
    public ResponseEntity<LoyaltyConfigResponse> getLoyaltyConfig() {
        LoyaltyConfigResponse response = new LoyaltyConfigResponse();
        response.setFcfaPerPoint(loyaltyConfigService.getFcfaPerPoint());
        return ResponseEntity.ok(response);
    }

    @PutMapping("/rewards/config")
    public ResponseEntity<LoyaltyConfigResponse> updateLoyaltyConfig(@Valid @RequestBody LoyaltyConfigUpdateRequest body) {
        int updated = loyaltyConfigService.setFcfaPerPoint(body.getFcfaPerPoint());
        LoyaltyConfigResponse response = new LoyaltyConfigResponse();
        response.setFcfaPerPoint(updated);
        return ResponseEntity.ok(response);
    }
}
