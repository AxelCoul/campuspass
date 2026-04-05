package com.campuspass.backend.dto;

import java.time.LocalDateTime;

public class AdminReferralPayoutRequestResponse {
    private Long id;
    private Long referrerId;
    private String studentName;
    private String studentEmail;
    private Integer requestYear;
    private Integer requestMonth;
    private Integer amountFcfa;
    private String status;
    private LocalDateTime requestedAt;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getReferrerId() { return referrerId; }
    public void setReferrerId(Long referrerId) { this.referrerId = referrerId; }
    public String getStudentName() { return studentName; }
    public void setStudentName(String studentName) { this.studentName = studentName; }
    public String getStudentEmail() { return studentEmail; }
    public void setStudentEmail(String studentEmail) { this.studentEmail = studentEmail; }
    public Integer getRequestYear() { return requestYear; }
    public void setRequestYear(Integer requestYear) { this.requestYear = requestYear; }
    public Integer getRequestMonth() { return requestMonth; }
    public void setRequestMonth(Integer requestMonth) { this.requestMonth = requestMonth; }
    public Integer getAmountFcfa() { return amountFcfa; }
    public void setAmountFcfa(Integer amountFcfa) { this.amountFcfa = amountFcfa; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public LocalDateTime getRequestedAt() { return requestedAt; }
    public void setRequestedAt(LocalDateTime requestedAt) { this.requestedAt = requestedAt; }
}
