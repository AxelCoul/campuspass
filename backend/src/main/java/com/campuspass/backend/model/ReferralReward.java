package com.campuspass.backend.model;

import jakarta.persistence.*;

import java.time.LocalDateTime;

@Entity
@Table(
        name = "referral_rewards",
        uniqueConstraints = {
                @UniqueConstraint(name = "uk_referral_reward_referrer_referred", columnNames = {"referrerId", "referredUserId"})
        }
)
public class ReferralReward {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private Long referrerId;

    @Column(nullable = false)
    private Long referredUserId;

    @Column(nullable = false)
    private Integer rewardYear;

    @Column(nullable = false)
    private Integer rewardMonth;

    @Column(nullable = false)
    private Integer amountFcfa;

    @Column(nullable = false)
    private LocalDateTime rewardedAt;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getReferrerId() { return referrerId; }
    public void setReferrerId(Long referrerId) { this.referrerId = referrerId; }
    public Long getReferredUserId() { return referredUserId; }
    public void setReferredUserId(Long referredUserId) { this.referredUserId = referredUserId; }
    public Integer getRewardYear() { return rewardYear; }
    public void setRewardYear(Integer rewardYear) { this.rewardYear = rewardYear; }
    public Integer getRewardMonth() { return rewardMonth; }
    public void setRewardMonth(Integer rewardMonth) { this.rewardMonth = rewardMonth; }
    public Integer getAmountFcfa() { return amountFcfa; }
    public void setAmountFcfa(Integer amountFcfa) { this.amountFcfa = amountFcfa; }
    public LocalDateTime getRewardedAt() { return rewardedAt; }
    public void setRewardedAt(LocalDateTime rewardedAt) { this.rewardedAt = rewardedAt; }
}
