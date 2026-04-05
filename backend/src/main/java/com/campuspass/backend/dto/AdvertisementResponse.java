package com.campuspass.backend.dto;

import com.campuspass.backend.model.enums.AdPosition;
import com.campuspass.backend.model.enums.AdStatus;
import java.time.LocalDate;
import java.time.LocalDateTime;

public class AdvertisementResponse {

    private Long id;
    private Long merchantId;
    private String title;
    private String description;
    private String ctaLabel;
    private String imageUrl;
    private String videoUrl;
    private String targetUrl;
    private String targetCity;
    private String targetCountry;
    private String targetUniversity;
    private String targetSegment;
    private AdPosition position;
    private LocalDate startDate;
    private LocalDate endDate;
    private Double budget;
    private Long offerId;
    private AdStatus status;
    private LocalDateTime createdAt;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getMerchantId() { return merchantId; }
    public void setMerchantId(Long merchantId) { this.merchantId = merchantId; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getCtaLabel() { return ctaLabel; }
    public void setCtaLabel(String ctaLabel) { this.ctaLabel = ctaLabel; }
    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }

    public String getVideoUrl() { return videoUrl; }
    public void setVideoUrl(String videoUrl) { this.videoUrl = videoUrl; }

    public String getTargetUrl() { return targetUrl; }
    public void setTargetUrl(String targetUrl) { this.targetUrl = targetUrl; }
    public String getTargetCity() { return targetCity; }
    public void setTargetCity(String targetCity) { this.targetCity = targetCity; }
    public String getTargetCountry() { return targetCountry; }
    public void setTargetCountry(String targetCountry) { this.targetCountry = targetCountry; }
    public String getTargetUniversity() { return targetUniversity; }
    public void setTargetUniversity(String targetUniversity) { this.targetUniversity = targetUniversity; }
    public String getTargetSegment() { return targetSegment; }
    public void setTargetSegment(String targetSegment) { this.targetSegment = targetSegment; }
    public AdPosition getPosition() { return position; }
    public void setPosition(AdPosition position) { this.position = position; }
    public LocalDate getStartDate() { return startDate; }
    public void setStartDate(LocalDate startDate) { this.startDate = startDate; }
    public LocalDate getEndDate() { return endDate; }
    public void setEndDate(LocalDate endDate) { this.endDate = endDate; }
    public AdStatus getStatus() { return status; }
    public void setStatus(AdStatus status) { this.status = status; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public Double getBudget() { return budget; }
    public void setBudget(Double budget) { this.budget = budget; }
    public Long getOfferId() { return offerId; }
    public void setOfferId(Long offerId) { this.offerId = offerId; }
}
