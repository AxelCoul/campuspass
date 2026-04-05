package com.campuspass.backend.controller;

import com.campuspass.backend.dto.ReviewRequest;
import com.campuspass.backend.dto.ReviewResponse;
import com.campuspass.backend.security.SecurityUser;
import com.campuspass.backend.service.ReviewService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/reviews")
public class ReviewController {

    private final ReviewService reviewService;

    public ReviewController(ReviewService reviewService) {
        this.reviewService = reviewService;
    }

    @GetMapping
    public ResponseEntity<List<ReviewResponse>> getByMerchant(@RequestParam Long merchantId) {
        return ResponseEntity.ok(reviewService.findByMerchantId(merchantId));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ReviewResponse> getById(@PathVariable Long id) {
        return ResponseEntity.ok(reviewService.getById(id));
    }

    @PostMapping
    public ResponseEntity<ReviewResponse> create(@AuthenticationPrincipal SecurityUser user,
                                                 @Valid @RequestBody ReviewRequest request) {
        return ResponseEntity.ok(reviewService.create(user.getId(), request));
    }
}
