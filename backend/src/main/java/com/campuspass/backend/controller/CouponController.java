package com.campuspass.backend.controller;

import com.campuspass.backend.dto.CouponResponse;
import com.campuspass.backend.security.SecurityUser;
import com.campuspass.backend.service.CouponService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/coupons")
public class CouponController {

    private final CouponService couponService;

    public CouponController(CouponService couponService) {
        this.couponService = couponService;
    }

    @GetMapping
    public ResponseEntity<List<CouponResponse>> getMyCoupons(@AuthenticationPrincipal SecurityUser user) {
        return ResponseEntity.ok(couponService.findByUserId(user.getId()));
    }

    @GetMapping("/{id}")
    public ResponseEntity<CouponResponse> getById(@PathVariable Long id, @AuthenticationPrincipal SecurityUser user) {
        return ResponseEntity.ok(couponService.getById(id));
    }

    @PostMapping("/generate")
    public ResponseEntity<CouponResponse> generate(@AuthenticationPrincipal SecurityUser user,
                                                    @RequestBody Map<String, Long> body) {
        Long offerId = body.get("offerId");
        if (offerId == null) {
            throw new IllegalArgumentException("offerId requis");
        }
        return ResponseEntity.ok(couponService.generate(user.getId(), offerId));
    }

    @PostMapping("/validate")
    public ResponseEntity<CouponResponse> validate(@RequestBody Map<String, String> body,
                                                    @RequestParam Long merchantId) {
        String code = body.get("couponCode");
        if (code == null || code.isBlank()) {
            throw new IllegalArgumentException("couponCode requis");
        }
        return ResponseEntity.ok(couponService.validate(code, merchantId));
    }
}
