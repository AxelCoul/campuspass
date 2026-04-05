package com.campuspass.backend.dto;

public class AdminReferrerStatsRowResponse {
    private Long userId;
    private String studentName;
    private String studentEmail;
    private String referralCode;
    private Long registeredReferrals;
    private Long activeSubscribedReferrals;
    private Integer pointsPerReferral;
    private Long pointsEarned;

    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }
    public String getStudentName() { return studentName; }
    public void setStudentName(String studentName) { this.studentName = studentName; }
    public String getStudentEmail() { return studentEmail; }
    public void setStudentEmail(String studentEmail) { this.studentEmail = studentEmail; }
    public String getReferralCode() { return referralCode; }
    public void setReferralCode(String referralCode) { this.referralCode = referralCode; }
    public Long getRegisteredReferrals() { return registeredReferrals; }
    public void setRegisteredReferrals(Long registeredReferrals) { this.registeredReferrals = registeredReferrals; }
    public Long getActiveSubscribedReferrals() { return activeSubscribedReferrals; }
    public void setActiveSubscribedReferrals(Long activeSubscribedReferrals) { this.activeSubscribedReferrals = activeSubscribedReferrals; }
    public Integer getPointsPerReferral() { return pointsPerReferral; }
    public void setPointsPerReferral(Integer pointsPerReferral) { this.pointsPerReferral = pointsPerReferral; }
    public Long getPointsEarned() { return pointsEarned; }
    public void setPointsEarned(Long pointsEarned) { this.pointsEarned = pointsEarned; }
}
