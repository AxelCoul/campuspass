package com.campuspass.backend.repository;

import com.campuspass.backend.model.RewardRedemption;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;

public interface RewardRedemptionRepository extends JpaRepository<RewardRedemption, Long> {
    List<RewardRedemption> findByUserIdOrderByRedeemedAtDesc(Long userId);
    List<RewardRedemption> findAllByOrderByRedeemedAtDesc();

    @Query("select coalesce(sum(r.pointsCost), 0) from RewardRedemption r where r.userId = :userId")
    Integer totalSpentByUserId(Long userId);
}
