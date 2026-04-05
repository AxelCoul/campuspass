package com.campuspass.backend.dto;

import java.util.List;

public class RewardsSummaryResponse {
    private Integer totalPoints;
    private Integer spentPoints;
    private Integer availablePoints;
    private Integer fcfaPerPoint;
    private Integer referralsCount;
    private Integer pointsPerReferral;
    private Integer referralBonusPoints;
    private List<RewardCatalogItemResponse> catalog;

    public Integer getTotalPoints() { return totalPoints; }
    public void setTotalPoints(Integer totalPoints) { this.totalPoints = totalPoints; }
    public Integer getSpentPoints() { return spentPoints; }
    public void setSpentPoints(Integer spentPoints) { this.spentPoints = spentPoints; }
    public Integer getAvailablePoints() { return availablePoints; }
    public void setAvailablePoints(Integer availablePoints) { this.availablePoints = availablePoints; }
    public Integer getFcfaPerPoint() { return fcfaPerPoint; }
    public void setFcfaPerPoint(Integer fcfaPerPoint) { this.fcfaPerPoint = fcfaPerPoint; }
    public Integer getReferralsCount() { return referralsCount; }
    public void setReferralsCount(Integer referralsCount) { this.referralsCount = referralsCount; }
    public Integer getPointsPerReferral() { return pointsPerReferral; }
    public void setPointsPerReferral(Integer pointsPerReferral) { this.pointsPerReferral = pointsPerReferral; }
    public Integer getReferralBonusPoints() { return referralBonusPoints; }
    public void setReferralBonusPoints(Integer referralBonusPoints) { this.referralBonusPoints = referralBonusPoints; }
    public List<RewardCatalogItemResponse> getCatalog() { return catalog; }
    public void setCatalog(List<RewardCatalogItemResponse> catalog) { this.catalog = catalog; }
}
