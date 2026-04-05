package com.campuspass.backend.model;

import com.campuspass.backend.model.enums.OfferStatus;
import jakarta.persistence.*;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "offers")
public class Offer {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private Long merchantId;
    private Long categoryId;

    @Column(nullable = false)
    private String title;
    private String description;
    private String termsConditions;

    private Double originalPrice;
    private Double discountPercentage;
    private Double discountAmount;
    private Double finalPrice;

    private String imageUrl;
    private Integer maxCoupons = 0;
    private Integer usedCoupons = 0;

    /** Nombre maximum de passages par jour pour un même étudiant (null = illimité). */
    private Integer maxPassesPerDayPerUser;

    /** Nombre maximum de plats / unités utilisables par passage (null = illimité). */
    private Integer maxQuantityPerPass;

    /**
     * Universités ciblées pour cette offre (CSV, ex: "AUBE, UJKZ").
     * null/vide = visible pour tous.
     */
    private String targetUniversitiesCsv;

    private LocalDate startDate;
    private LocalDate endDate;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private OfferStatus status = OfferStatus.PENDING;

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "merchantId", insertable = false, updatable = false)
    private Merchant merchant;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "categoryId", insertable = false, updatable = false)
    private Category category;

    public Offer() {}

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
    public Integer getMaxCoupons() { return maxCoupons; }
    public void setMaxCoupons(Integer maxCoupons) { this.maxCoupons = maxCoupons; }
    public Integer getUsedCoupons() { return usedCoupons; }
    public void setUsedCoupons(Integer usedCoupons) { this.usedCoupons = usedCoupons; }
    public Integer getMaxPassesPerDayPerUser() { return maxPassesPerDayPerUser; }
    public void setMaxPassesPerDayPerUser(Integer maxPassesPerDayPerUser) { this.maxPassesPerDayPerUser = maxPassesPerDayPerUser; }
    public Integer getMaxQuantityPerPass() { return maxQuantityPerPass; }
    public void setMaxQuantityPerPass(Integer maxQuantityPerPass) { this.maxQuantityPerPass = maxQuantityPerPass; }
    public String getTargetUniversitiesCsv() { return targetUniversitiesCsv; }
    public void setTargetUniversitiesCsv(String targetUniversitiesCsv) { this.targetUniversitiesCsv = targetUniversitiesCsv; }
    public LocalDate getStartDate() { return startDate; }
    public void setStartDate(LocalDate startDate) { this.startDate = startDate; }
    public LocalDate getEndDate() { return endDate; }
    public void setEndDate(LocalDate endDate) { this.endDate = endDate; }
    public OfferStatus getStatus() { return status; }
    public void setStatus(OfferStatus status) { this.status = status; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}
