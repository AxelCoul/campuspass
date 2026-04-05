package com.campuspass.backend.dto;

import com.campuspass.backend.model.enums.SubscriptionPaymentMethod;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public class SubscribeRequest {
    @NotNull
    private Long planId;
    @NotNull
    private SubscriptionPaymentMethod paymentMethod;
    @NotBlank
    private String phoneNumber;

    public Long getPlanId() { return planId; }
    public void setPlanId(Long planId) { this.planId = planId; }
    public SubscriptionPaymentMethod getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(SubscriptionPaymentMethod paymentMethod) { this.paymentMethod = paymentMethod; }
    public String getPhoneNumber() { return phoneNumber; }
    public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }
}
