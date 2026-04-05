package com.campuspass.backend.controller;

import com.campuspass.backend.dto.StudentMeResponse;
import com.campuspass.backend.dto.StudentSavingsResponse;
import com.campuspass.backend.dto.StudentAreaUpdateRequest;
import com.campuspass.backend.dto.StudentProfileUpdateRequest;
import com.campuspass.backend.dto.StudentPasswordUpdateRequest;
import com.campuspass.backend.dto.StudentVerificationRequest;
import com.campuspass.backend.dto.RedeemRewardRequest;
import com.campuspass.backend.dto.RewardRedemptionResponse;
import com.campuspass.backend.dto.RewardsSummaryResponse;
import com.campuspass.backend.dto.LinkReferralCodeRequest;
import com.campuspass.backend.dto.ReferralPayoutRequestResponse;
import com.campuspass.backend.service.RewardService;
import com.campuspass.backend.service.StudentService;
import com.campuspass.backend.security.SecurityUser;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/student")
public class StudentController {

    private static final Logger log = LoggerFactory.getLogger(StudentController.class);

    private final StudentService studentService;
    private final RewardService rewardService;

    public StudentController(StudentService studentService,
                             RewardService rewardService) {
        this.studentService = studentService;
        this.rewardService = rewardService;
    }

    @GetMapping("/me")
    public ResponseEntity<StudentMeResponse> getMe(@AuthenticationPrincipal SecurityUser user) {
        if (user == null || user.getId() == null)
            return ResponseEntity.status(401).build();
        try {
            return ResponseEntity.ok(studentService.getMe(user.getId()));
        } catch (Exception e) {
            log.error("Erreur /api/student/me pour userId={}", user.getId(), e);
            StudentMeResponse fallback = new StudentMeResponse();
            fallback.setId(user.getId());
            fallback.setHasActiveSubscription(false);
            fallback.setSubscriptionPlanName(null);
            fallback.setSubscriptionEndDate(null);
            fallback.setStudentVerified(false);
            fallback.setStudentVerificationStatus("NONE");
            fallback.setStudentVerificationRejectionReason(null);
            fallback.setTotalSavings(0.0);
            fallback.setLoyaltyPoints(0);
            fallback.setReferralCode(null);
            fallback.setReferralsCount(0);
            fallback.setReferralBalance(0);
            fallback.setFirstName(null);
            fallback.setLastName(null);
            fallback.setEmail(null);
            fallback.setPhoneNumber(null);
            fallback.setUniversity(null);
            fallback.setCity(null);
            fallback.setCountry(null);
            return ResponseEntity.ok(fallback);
        }
    }

    @GetMapping("/savings")
    public ResponseEntity<StudentSavingsResponse> getSavings(@AuthenticationPrincipal SecurityUser user) {
        if (user == null || user.getId() == null)
            return ResponseEntity.status(401).build();
        try {
            return ResponseEntity.ok(studentService.getSavings(user.getId()));
        } catch (Exception e) {
            log.error("Erreur /api/student/savings pour userId={}", user.getId(), e);
            StudentSavingsResponse fallback = new StudentSavingsResponse();
            fallback.setTotalSaved(0.0);
            fallback.setOffersUsedCount(0);
            fallback.setMerchantsVisitedCount(0);
            fallback.setHistory(java.util.List.of());
            return ResponseEntity.ok(fallback);
        }
    }

    @GetMapping("/rewards")
    public ResponseEntity<RewardsSummaryResponse> getRewardsSummary(@AuthenticationPrincipal SecurityUser user) {
        if (user == null || user.getId() == null)
            return ResponseEntity.status(401).build();
        return ResponseEntity.ok(rewardService.getSummary(user.getId()));
    }

    @GetMapping("/rewards/history")
    public ResponseEntity<List<RewardRedemptionResponse>> getRewardsHistory(@AuthenticationPrincipal SecurityUser user) {
        if (user == null || user.getId() == null)
            return ResponseEntity.status(401).build();
        return ResponseEntity.ok(rewardService.getHistory(user.getId()));
    }

    @PostMapping("/rewards/redeem")
    public ResponseEntity<RewardRedemptionResponse> redeemReward(@AuthenticationPrincipal SecurityUser user,
                                                                 @RequestBody RedeemRewardRequest body) {
        if (user == null || user.getId() == null)
            return ResponseEntity.status(401).build();
        return ResponseEntity.ok(rewardService.redeem(user.getId(), body.getRewardId()));
    }

    @PostMapping("/verification")
    public ResponseEntity<Void> submitVerification(@AuthenticationPrincipal SecurityUser user,
                                                   @Valid @RequestBody StudentVerificationRequest request) {
        if (user == null || user.getId() == null)
            return ResponseEntity.status(401).build();
        studentService.updateVerification(user.getId(), request);
        return ResponseEntity.ok().build();
    }

    @PatchMapping("/email")
    public ResponseEntity<Void> updateEmail(@AuthenticationPrincipal SecurityUser user,
                                            @RequestBody Map<String, String> body) {
        if (user == null || user.getId() == null)
            return ResponseEntity.status(401).build();
        String email = body.get("email");
        studentService.updateEmail(user.getId(), email);
        return ResponseEntity.ok().build();
    }

    @PatchMapping("/profile")
    public ResponseEntity<Void> updateProfile(@AuthenticationPrincipal SecurityUser user,
                                              @Valid @RequestBody StudentProfileUpdateRequest body) {
        if (user == null || user.getId() == null)
            return ResponseEntity.status(401).build();
        studentService.updateProfile(
                user.getId(),
                body.getFirstName(),
                body.getEmail(),
                body.getPhoneNumber(),
                body.getCity()
        );
        return ResponseEntity.ok().build();
    }

    @PatchMapping("/password")
    public ResponseEntity<Void> updatePassword(@AuthenticationPrincipal SecurityUser user,
                                               @Valid @RequestBody StudentPasswordUpdateRequest body) {
        if (user == null || user.getId() == null)
            return ResponseEntity.status(401).build();
        studentService.updatePassword(user.getId(), body.getCurrentPassword(), body.getNewPassword());
        return ResponseEntity.ok().build();
    }

    @PatchMapping("/area")
    public ResponseEntity<Void> updateArea(@AuthenticationPrincipal SecurityUser user,
                                           @RequestBody StudentAreaUpdateRequest body) {
        if (user == null || user.getId() == null)
            return ResponseEntity.status(401).build();
        studentService.updateArea(user.getId(), body.getCity(), body.getCountry());
        return ResponseEntity.ok().build();
    }

    @PatchMapping("/referral-code")
    public ResponseEntity<Void> linkReferralCode(@AuthenticationPrincipal SecurityUser user,
                                                 @RequestBody LinkReferralCodeRequest body) {
        if (user == null || user.getId() == null)
            return ResponseEntity.status(401).build();
        studentService.linkReferralCode(user.getId(), body.getReferralCode());
        return ResponseEntity.ok().build();
    }

    @PostMapping("/referral/payout-request")
    public ResponseEntity<ReferralPayoutRequestResponse> requestReferralPayout(@AuthenticationPrincipal SecurityUser user) {
        if (user == null || user.getId() == null)
            return ResponseEntity.status(401).build();
        return ResponseEntity.ok(studentService.requestReferralPayout(user.getId()));
    }
}
