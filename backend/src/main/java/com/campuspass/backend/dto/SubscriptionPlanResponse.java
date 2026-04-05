package com.campuspass.backend.dto;

import com.campuspass.backend.model.enums.SubscriptionPlanType;
import java.time.LocalDate;
import java.time.LocalDateTime;

public class SubscriptionPlanResponse {
    private Long id;
    private String name;
    private SubscriptionPlanType type;
    private Double price;
    private Double promoPrice;
    private LocalDate startPromoDate;
    private LocalDate endPromoDate;
    private Boolean active;
    private LocalDateTime createdAt;
    private Double effectivePrice;
    private Boolean promoActive;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public SubscriptionPlanType getType() { return type; }
    public void setType(SubscriptionPlanType type) { this.type = type; }
    public Double getPrice() { return price; }
    public void setPrice(Double price) { this.price = price; }
    public Double getPromoPrice() { return promoPrice; }
    public void setPromoPrice(Double promoPrice) { this.promoPrice = promoPrice; }
    public LocalDate getStartPromoDate() { return startPromoDate; }
    public void setStartPromoDate(LocalDate d) { this.startPromoDate = d; }
    public LocalDate getEndPromoDate() { return endPromoDate; }
    public void setEndPromoDate(LocalDate d) { this.endPromoDate = d; }
    public Boolean getActive() { return active; }
    public void setActive(Boolean active) { this.active = active; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public Double getEffectivePrice() { return effectivePrice; }
    public void setEffectivePrice(Double effectivePrice) { this.effectivePrice = effectivePrice; }
    public Boolean getPromoActive() { return promoActive; }
    public void setPromoActive(Boolean promoActive) { this.promoActive = promoActive; }
}
