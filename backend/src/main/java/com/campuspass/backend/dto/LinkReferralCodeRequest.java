package com.campuspass.backend.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public class LinkReferralCodeRequest {
    @NotBlank
    @Size(max = 100)
    private String referralCode;

    public String getReferralCode() { return referralCode; }
    public void setReferralCode(String referralCode) { this.referralCode = referralCode; }
}
