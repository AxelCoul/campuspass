package com.campuspass.backend.dto;

import com.campuspass.backend.model.enums.OfferStatus;
import java.util.List;
import java.time.LocalDate;
import java.time.LocalDateTime;

public class OfferResponse {

    private Long id;
    private Long merchantId;
    private Long categoryId;
    private String title;
    private String description;
    private String termsConditions;
    private Double originalPrice;
    private Double discountPercentage;
    private Double discountAmount;
    private Double finalPrice;
    private String imageUrl;
    private List<String> imageUrls;
    private Integer maxCoupons;
    private Integer usedCoupons;
    /** Nombre maximum de passages par jour pour un étudiant (null = illimité). */
    private Integer maxPassesPerDayPerUser;
    /** Nombre maximum de plats / unités par passage (null = illimité). */
    private Integer maxQuantityPerPass;
    /** Liste d'universités ciblées (CSV). */
    private String targetUniversities;
    /** Passages restants aujourd'hui pour l'utilisateur courant (null si non connecté ou non calculé). */
    private Integer remainingPassesTodayForCurrentUser;
    private LocalDate startDate;
    private LocalDate endDate;
    private OfferStatus status;
    private LocalDateTime createdAt;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getMerchantId() { return merchantId; }
    public void setMerchantId(Long merchantId) { this.merchantId = merchantId; }
    public Long getCategoryId() { return categoryId; }
    public void setCategoryId(Long categoryId) { this.categoryId = categoryId; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getTermsConditions() { return termsConditions; }
    public void setTermsConditions(String termsConditions) { this.termsConditions = termsConditions; }
    public Double getOriginalPrice() { return originalPrice; }
    public void setOriginalPrice(Double originalPrice) { this.originalPrice = originalPrice; }
    public Double getDiscountPercentage() { return discountPercentage; }
    public void setDiscountPercentage(Double discountPercentage) { this.discountPercentage = discountPercentage; }
    public Double getDiscountAmount() { return discountAmount; }
    public void setDiscountAmount(Double discountAmount) { this.discountAmount = discountAmount; }
    public Double getFinalPrice() { return finalPrice; }
    public void setFinalPrice(Double finalPrice) { this.finalPrice = finalPrice; }
    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }
    public List<String> getImageUrls() { return imageUrls; }
    public void setImageUrls(List<String> imageUrls) { this.imageUrls = imageUrls; }
    public Integer getMaxCoupons() { return maxCoupons; }
    public void setMaxCoupons(Integer maxCoupons) { this.maxCoupons = maxCoupons; }
    public Integer getUsedCoupons() { return usedCoupons; }
    public void setUsedCoupons(Integer usedCoupons) { this.usedCoupons = usedCoupons; }
    public Integer getMaxPassesPerDayPerUser() { return maxPassesPerDayPerUser; }
    public void setMaxPassesPerDayPerUser(Integer maxPassesPerDayPerUser) { this.maxPassesPerDayPerUser = maxPassesPerDayPerUser; }
    public Integer getMaxQuantityPerPass() { return maxQuantityPerPass; }
    public void setMaxQuantityPerPass(Integer maxQuantityPerPass) { this.maxQuantityPerPass = maxQuantityPerPass; }
    public String getTargetUniversities() { return targetUniversities; }
    public void setTargetUniversities(String targetUniversities) { this.targetUniversities = targetUniversities; }
    public Integer getRemainingPassesTodayForCurrentUser() { return remainingPassesTodayForCurrentUser; }
    public void setRemainingPassesTodayForCurrentUser(Integer remainingPassesTodayForCurrentUser) { this.remainingPassesTodayForCurrentUser = remainingPassesTodayForCurrentUser; }
    public LocalDate getStartDate() { return startDate; }
    public void setStartDate(LocalDate startDate) { this.startDate = startDate; }
    public LocalDate getEndDate() { return endDate; }
    public void setEndDate(LocalDate endDate) { this.endDate = endDate; }
    public OfferStatus getStatus() { return status; }
    public void setStatus(OfferStatus status) { this.status = status; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
