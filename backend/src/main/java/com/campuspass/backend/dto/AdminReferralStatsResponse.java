package com.campuspass.backend.dto;

public class AdminReferralStatsResponse {
    private Long registeredReferrals;
    private Long activeSubscribedReferrals;

    public Long getRegisteredReferrals() { return registeredReferrals; }
    public void setRegisteredReferrals(Long registeredReferrals) { this.registeredReferrals = registeredReferrals; }
    public Long getActiveSubscribedReferrals() { return activeSubscribedReferrals; }
    public void setActiveSubscribedReferrals(Long activeSubscribedReferrals) { this.activeSubscribedReferrals = activeSubscribedReferrals; }
}
