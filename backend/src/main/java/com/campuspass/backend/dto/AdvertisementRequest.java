package com.campuspass.backend.dto;

import com.campuspass.backend.model.enums.AdPosition;
import jakarta.validation.constraints.NotNull;
import java.time.LocalDate;

public class AdvertisementRequest {

    @NotNull
    private Long merchantId;
    private String title;
    private String description;
    /** Texte du bouton (bandeau HOME_TOP, etc.). */
    private String ctaLabel;
    private String imageUrl;
    private String videoUrl;
    private String targetUrl;
    /** Ciblage simple : ville (ex: Ouagadougou). */
    private String targetCity;
    /** Ciblage simple : pays (ex: Burkina Faso). */
    private String targetCountry;
    /** Ciblage simple : université (nom ou code). */
    private String targetUniversity;
    /** Segment utilisateur ciblé (ALL, SUBSCRIBED, NON_SUBSCRIBED, etc.). */
    private String targetSegment;
    private AdPosition position;
    private LocalDate startDate;
    private LocalDate endDate;
    private Double budget;
    private Long offerId;

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
    public Double getBudget() { return budget; }
    public void setBudget(Double budget) { this.budget = budget; }
    public Long getOfferId() { return offerId; }
    public void setOfferId(Long offerId) { this.offerId = offerId; }
}
