package com.campuspass.backend.repository;

import com.campuspass.backend.model.Review;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ReviewRepository extends JpaRepository<Review, Long> {

    List<Review> findByMerchantIdOrderByCreatedAtDesc(Long merchantId);

    List<Review> findByUserId(Long userId);
}
