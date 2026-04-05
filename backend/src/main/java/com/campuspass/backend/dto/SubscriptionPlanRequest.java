package com.campuspass.backend.dto;

import com.campuspass.backend.model.enums.SubscriptionPlanType;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import java.time.LocalDate;

public class SubscriptionPlanRequest {
    @NotNull
    private String name;
    @NotNull
    private SubscriptionPlanType type;
    @NotNull @Positive
    private Double price;
    private Double promoPrice;
    private LocalDate startPromoDate;
    private LocalDate endPromoDate;
    private Boolean active = true;

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
}
