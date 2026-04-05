package com.campuspass.backend.dto;

import java.time.LocalDateTime;

public class RewardRedemptionResponse {
    private Long id;
    private Long rewardId;
    private String rewardTitle;
    private Integer pointsCost;
    private LocalDateTime redeemedAt;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getRewardId() { return rewardId; }
    public void setRewardId(Long rewardId) { this.rewardId = rewardId; }
    public String getRewardTitle() { return rewardTitle; }
    public void setRewardTitle(String rewardTitle) { this.rewardTitle = rewardTitle; }
    public Integer getPointsCost() { return pointsCost; }
    public void setPointsCost(Integer pointsCost) { this.pointsCost = pointsCost; }
    public LocalDateTime getRedeemedAt() { return redeemedAt; }
    public void setRedeemedAt(LocalDateTime redeemedAt) { this.redeemedAt = redeemedAt; }
}
