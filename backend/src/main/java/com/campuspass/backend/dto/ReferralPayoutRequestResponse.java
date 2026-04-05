package com.campuspass.backend.dto;

import java.time.LocalDateTime;

public class ReferralPayoutRequestResponse {
    private Long id;
    private Integer amountFcfa;
    private String status;
    private LocalDateTime requestedAt;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Integer getAmountFcfa() { return amountFcfa; }
    public void setAmountFcfa(Integer amountFcfa) { this.amountFcfa = amountFcfa; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public LocalDateTime getRequestedAt() { return requestedAt; }
    public void setRequestedAt(LocalDateTime requestedAt) { this.requestedAt = requestedAt; }
}
