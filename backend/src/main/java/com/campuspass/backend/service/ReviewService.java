package com.campuspass.backend.service;

import com.campuspass.backend.dto.ReviewRequest;
import com.campuspass.backend.dto.ReviewResponse;
import com.campuspass.backend.exception.ResourceNotFoundException;
import com.campuspass.backend.model.Review;
import com.campuspass.backend.model.enums.ReviewStatus;
import com.campuspass.backend.repository.ReviewRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class ReviewService {

    private final ReviewRepository reviewRepository;

    public ReviewService(ReviewRepository reviewRepository) {
        this.reviewRepository = reviewRepository;
    }

    public List<ReviewResponse> findByMerchantId(Long merchantId) {
        return reviewRepository.findByMerchantIdOrderByCreatedAtDesc(merchantId).stream()
                .map(this::toResponse).collect(Collectors.toList());
    }

    public ReviewResponse getById(Long id) {
        Review r = reviewRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Review", id));
        return toResponse(r);
    }

    @Transactional
    public ReviewResponse create(Long userId, ReviewRequest req) {
        Review r = new Review();
        r.setUserId(userId);
        r.setMerchantId(req.getMerchantId());
        r.setRating(req.getRating());
        r.setComment(req.getComment());
        r.setStatus(ReviewStatus.VISIBLE);
        r.setCreatedAt(LocalDateTime.now());
        r = reviewRepository.save(r);
        return toResponse(r);
    }

    private ReviewResponse toResponse(Review r) {
        ReviewResponse res = new ReviewResponse();
        res.setId(r.getId());
        res.setUserId(r.getUserId());
        res.setMerchantId(r.getMerchantId());
        res.setRating(r.getRating());
        res.setComment(r.getComment());
        res.setStatus(r.getStatus());
        res.setCreatedAt(r.getCreatedAt());
        return res;
    }
}
