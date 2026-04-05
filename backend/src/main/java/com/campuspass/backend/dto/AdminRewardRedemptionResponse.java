package com.campuspass.backend.dto;

import java.time.LocalDateTime;

public class AdminRewardRedemptionResponse {
    private Long id;
    private Long userId;
    private String studentName;
    private String studentEmail;
    private Long rewardId;
    private String rewardTitle;
    private Integer pointsCost;
    private LocalDateTime redeemedAt;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }
    public String getStudentName() { return studentName; }
    public void setStudentName(String studentName) { this.studentName = studentName; }
    public String getStudentEmail() { return studentEmail; }
    public void setStudentEmail(String studentEmail) { this.studentEmail = studentEmail; }
    public Long getRewardId() { return rewardId; }
    public void setRewardId(Long rewardId) { this.rewardId = rewardId; }
    public String getRewardTitle() { return rewardTitle; }
    public void setRewardTitle(String rewardTitle) { this.rewardTitle = rewardTitle; }
    public Integer getPointsCost() { return pointsCost; }
    public void setPointsCost(Integer pointsCost) { this.pointsCost = pointsCost; }
    public LocalDateTime getRedeemedAt() { return redeemedAt; }
    public void setRedeemedAt(LocalDateTime redeemedAt) { this.redeemedAt = redeemedAt; }
}
