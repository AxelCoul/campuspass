package com.campuspass.backend.dto;

import com.campuspass.backend.model.enums.UserStatus;
import java.time.LocalDate;
import java.time.LocalDateTime;

public class StudentMeResponse {
    private Long id;
    private String firstName;
    private String lastName;
    private String email;
    private String phoneNumber;
    private String university;
    private String city;
    private String country;
    private Boolean studentVerified;
    private String studentVerificationStatus;
    private String studentVerificationRejectionReason;
    private UserStatus status;
    private LocalDateTime createdAt;
    private Boolean hasActiveSubscription;
    private LocalDate subscriptionEndDate;
    private String subscriptionPlanName;
    private Double totalSavings;
    private Integer loyaltyPoints;
    private String referralCode;
    private Integer referralsCount;
    private Integer referralBalance;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getFirstName() { return firstName; }
    public void setFirstName(String firstName) { this.firstName = firstName; }
    public String getLastName() { return lastName; }
    public void setLastName(String lastName) { this.lastName = lastName; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getPhoneNumber() { return phoneNumber; }
    public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }
    public String getUniversity() { return university; }
    public void setUniversity(String university) { this.university = university; }
    public String getCity() { return city; }
    public void setCity(String city) { this.city = city; }
    public String getCountry() { return country; }
    public void setCountry(String country) { this.country = country; }
    public Boolean getStudentVerified() { return studentVerified; }
    public void setStudentVerified(Boolean studentVerified) { this.studentVerified = studentVerified; }
    public String getStudentVerificationStatus() { return studentVerificationStatus; }
    public void setStudentVerificationStatus(String studentVerificationStatus) { this.studentVerificationStatus = studentVerificationStatus; }
    public String getStudentVerificationRejectionReason() { return studentVerificationRejectionReason; }
    public void setStudentVerificationRejectionReason(String studentVerificationRejectionReason) { this.studentVerificationRejectionReason = studentVerificationRejectionReason; }
    public UserStatus getStatus() { return status; }
    public void setStatus(UserStatus status) { this.status = status; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public Boolean getHasActiveSubscription() { return hasActiveSubscription; }
    public void setHasActiveSubscription(Boolean hasActiveSubscription) { this.hasActiveSubscription = hasActiveSubscription; }
    public LocalDate getSubscriptionEndDate() { return subscriptionEndDate; }
    public void setSubscriptionEndDate(LocalDate subscriptionEndDate) { this.subscriptionEndDate = subscriptionEndDate; }
    public String getSubscriptionPlanName() { return subscriptionPlanName; }
    public void setSubscriptionPlanName(String subscriptionPlanName) { this.subscriptionPlanName = subscriptionPlanName; }
    public Double getTotalSavings() { return totalSavings; }
    public void setTotalSavings(Double totalSavings) { this.totalSavings = totalSavings; }
    public Integer getLoyaltyPoints() { return loyaltyPoints; }
    public void setLoyaltyPoints(Integer loyaltyPoints) { this.loyaltyPoints = loyaltyPoints; }
    public String getReferralCode() { return referralCode; }
    public void setReferralCode(String referralCode) { this.referralCode = referralCode; }
    public Integer getReferralsCount() { return referralsCount; }
    public void setReferralsCount(Integer referralsCount) { this.referralsCount = referralsCount; }
    public Integer getReferralBalance() { return referralBalance; }
    public void setReferralBalance(Integer referralBalance) { this.referralBalance = referralBalance; }
}
