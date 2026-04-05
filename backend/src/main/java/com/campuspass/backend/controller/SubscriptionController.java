package com.campuspass.backend.controller;

import com.campuspass.backend.dto.SubscribeRequest;
import com.campuspass.backend.service.SubscriptionService;
import com.campuspass.backend.security.SecurityUser;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/subscription")
public class SubscriptionController {
    private final SubscriptionService subscriptionService;

    public SubscriptionController(SubscriptionService subscriptionService) {
        this.subscriptionService = subscriptionService;
    }

    @PostMapping("/subscribe")
    public ResponseEntity<Map<String, Object>> subscribe(@AuthenticationPrincipal SecurityUser user, @Valid @RequestBody SubscribeRequest request) {
        if (user == null || user.getId() == null) return ResponseEntity.status(401).build();
        return ResponseEntity.ok(subscriptionService.subscribe(user.getId(), request));
    }

    @PostMapping("/confirm-otp")
    public ResponseEntity<Map<String, Object>> confirmOtp(@AuthenticationPrincipal SecurityUser user, @RequestBody Map<String, Object> body) {
        if (user == null || user.getId() == null) return ResponseEntity.status(401).build();
        Long paymentId = body.get("paymentId") instanceof Number ? ((Number) body.get("paymentId")).longValue() : null;
        String otp = (String) body.get("otp");
        if (paymentId == null || otp == null) return ResponseEntity.badRequest().build();
        return ResponseEntity.ok(subscriptionService.confirmOtp(user.getId(), paymentId, otp));
    }

    @GetMapping("/payment-status/{paymentId}")
    public ResponseEntity<Map<String, Object>> paymentStatus(@AuthenticationPrincipal SecurityUser user, @PathVariable Long paymentId) {
        if (user == null || user.getId() == null) return ResponseEntity.status(401).build();
        return ResponseEntity.ok(subscriptionService.getPaymentStatus(user.getId(), paymentId));
    }

    @PostMapping("/yengapay/webhook")
    public ResponseEntity<Map<String, Object>> yengapayWebhook(@RequestBody Map<String, Object> body) {
        return ResponseEntity.ok(subscriptionService.handleYengapayWebhook(body));
    }

    @GetMapping("/yengapay/return")
    public ResponseEntity<Map<String, Object>> yengapayReturn() {
        return ResponseEntity.ok(Map.of("ok", true, "message", "Paiement recu. Retourne dans l'application."));
    }

    @GetMapping("/payments")
    public ResponseEntity<List<Map<String, Object>>> getPaymentHistory(@AuthenticationPrincipal SecurityUser user) {
        if (user == null || user.getId() == null) return ResponseEntity.status(401).build();
        return ResponseEntity.ok(subscriptionService.getPaymentHistory(user.getId()));
    }

    @GetMapping("/paylink")
    public ResponseEntity<Map<String, Object>> getPaylink(@AuthenticationPrincipal SecurityUser user) {
        if (user == null || user.getId() == null) return ResponseEntity.status(401).build();
        return ResponseEntity.ok(subscriptionService.getPaylink());
    }
}
