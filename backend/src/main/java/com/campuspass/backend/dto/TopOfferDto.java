package com.campuspass.backend.dto;

public class TopOfferDto {
    private Long offerId;
    private String title;
    private long usageCount;

    public Long getOfferId() { return offerId; }
    public void setOfferId(Long offerId) { this.offerId = offerId; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public long getUsageCount() { return usageCount; }
    public void setUsageCount(long usageCount) { this.usageCount = usageCount; }
}
