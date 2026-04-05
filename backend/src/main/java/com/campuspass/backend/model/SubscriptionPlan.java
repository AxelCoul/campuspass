package com.campuspass.backend.model;

import com.campuspass.backend.model.enums.SubscriptionPlanType;
import jakarta.persistence.*;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "subscription_plans")
public class SubscriptionPlan {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    @Column(nullable = false)
    private String name;
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private SubscriptionPlanType type = SubscriptionPlanType.MONTHLY;
    @Column(nullable = false)
    private Double price;
    private Double promoPrice;
    private LocalDate startPromoDate;
    private LocalDate endPromoDate;
    @Column(nullable = false)
    private Boolean active = true;
    private LocalDateTime createdAt;

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

    public Double getEffectivePrice(LocalDate today) {
        if (promoPrice != null && startPromoDate != null && endPromoDate != null
                && !today.isBefore(startPromoDate) && !today.isAfter(endPromoDate))
            return promoPrice;
        return price;
    }
    public boolean isPromoActive(LocalDate today) {
        return promoPrice != null && startPromoDate != null && endPromoDate != null
                && !today.isBefore(startPromoDate) && !today.isAfter(endPromoDate);
    }
}
