package com.campuspass.backend.repository;

import com.campuspass.backend.model.Coupon;
import com.campuspass.backend.model.enums.CouponStatus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

public interface CouponRepository extends JpaRepository<Coupon, Long> {

    Optional<Coupon> findByCouponCode(String couponCode);

    List<Coupon> findByUserIdOrderByGeneratedAtDesc(Long userId);

    List<Coupon> findByOfferId(Long offerId);

    long countByUserIdAndOfferIdAndStatusAndGeneratedAtBetween(Long userId,
                                                               Long offerId,
                                                               CouponStatus status,
                                                               LocalDateTime start,
                                                               LocalDateTime end);
}
