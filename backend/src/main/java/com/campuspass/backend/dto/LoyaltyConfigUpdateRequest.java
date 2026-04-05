package com.campuspass.backend.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

public class LoyaltyConfigUpdateRequest {
    @NotNull
    @Min(1)
    private Integer fcfaPerPoint;

    public Integer getFcfaPerPoint() { return fcfaPerPoint; }
    public void setFcfaPerPoint(Integer fcfaPerPoint) { this.fcfaPerPoint = fcfaPerPoint; }
}
