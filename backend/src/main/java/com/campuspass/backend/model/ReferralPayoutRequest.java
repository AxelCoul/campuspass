package com.campuspass.backend.model;

import com.campuspass.backend.model.enums.ReferralPayoutStatus;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.time.LocalDateTime;

@Entity
@Table(name = "referral_payout_requests")
public class ReferralPayoutRequest {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private Long referrerId;

    @Column(nullable = false)
    private Integer requestYear;

    @Column(nullable = false)
    private Integer requestMonth;

    @Column(nullable = false)
    private Integer amountFcfa;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ReferralPayoutStatus status = ReferralPayoutStatus.PENDING;

    @Column(nullable = false)
    private LocalDateTime requestedAt;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getReferrerId() { return referrerId; }
    public void setReferrerId(Long referrerId) { this.referrerId = referrerId; }
    public Integer getRequestYear() { return requestYear; }
    public void setRequestYear(Integer requestYear) { this.requestYear = requestYear; }
    public Integer getRequestMonth() { return requestMonth; }
    public void setRequestMonth(Integer requestMonth) { this.requestMonth = requestMonth; }
    public Integer getAmountFcfa() { return amountFcfa; }
    public void setAmountFcfa(Integer amountFcfa) { this.amountFcfa = amountFcfa; }
    public ReferralPayoutStatus getStatus() { return status; }
    public void setStatus(ReferralPayoutStatus status) { this.status = status; }
    public LocalDateTime getRequestedAt() { return requestedAt; }
    public void setRequestedAt(LocalDateTime requestedAt) { this.requestedAt = requestedAt; }
}
