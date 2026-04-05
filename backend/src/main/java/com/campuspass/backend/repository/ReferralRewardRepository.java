package com.campuspass.backend.repository;

import com.campuspass.backend.model.ReferralReward;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.Optional;

public interface ReferralRewardRepository extends JpaRepository<ReferralReward, Long> {
    boolean existsByReferrerIdAndReferredUserId(Long referrerId, Long referredUserId);

    @Query("select count(r) from ReferralReward r where r.referrerId = :referrerId and r.rewardYear = :year and r.rewardMonth = :month")
    long countByReferrerAndYearMonth(Long referrerId, int year, int month);

    @Query("select coalesce(sum(r.amountFcfa), 0) from ReferralReward r where r.referrerId = :referrerId")
    Integer sumAmountByReferrerId(Long referrerId);
}
