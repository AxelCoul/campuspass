package com.campuspass.backend.dto;

import com.campuspass.backend.model.enums.UserStatus;

import java.time.LocalDateTime;

public class StudentResponseDto {
    private Long id;
    private String firstName;
    private String lastName;
    private String email;
    private String university;
    private String city;
    private Integer couponsUsed;
    private UserStatus status;
    private Boolean cardVerified;
    private String country;
    private String studentCardNumber;
    private String verificationDocumentType;
    private String studentCardImage;
    private LocalDateTime verificationDate;
    private String verificationStatus;
    private String verificationRejectionReason;
    private LocalDateTime createdAt;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getFirstName() { return firstName; }
    public void setFirstName(String firstName) { this.firstName = firstName; }
    public String getLastName() { return lastName; }
    public void setLastName(String lastName) { this.lastName = lastName; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getUniversity() { return university; }
    public void setUniversity(String university) { this.university = university; }
    public String getCity() { return city; }
    public void setCity(String city) { this.city = city; }
    public Integer getCouponsUsed() { return couponsUsed; }
    public void setCouponsUsed(Integer couponsUsed) { this.couponsUsed = couponsUsed; }
    public UserStatus getStatus() { return status; }
    public void setStatus(UserStatus status) { this.status = status; }
    public Boolean getCardVerified() { return cardVerified; }
    public void setCardVerified(Boolean cardVerified) { this.cardVerified = cardVerified; }
    public String getCountry() { return country; }
    public void setCountry(String country) { this.country = country; }
    public String getStudentCardNumber() { return studentCardNumber; }
    public void setStudentCardNumber(String studentCardNumber) { this.studentCardNumber = studentCardNumber; }
    public String getVerificationDocumentType() { return verificationDocumentType; }
    public void setVerificationDocumentType(String verificationDocumentType) { this.verificationDocumentType = verificationDocumentType; }
    public String getStudentCardImage() { return studentCardImage; }
    public void setStudentCardImage(String studentCardImage) { this.studentCardImage = studentCardImage; }
    public LocalDateTime getVerificationDate() { return verificationDate; }
    public void setVerificationDate(LocalDateTime verificationDate) { this.verificationDate = verificationDate; }
    public String getVerificationStatus() { return verificationStatus; }
    public void setVerificationStatus(String verificationStatus) { this.verificationStatus = verificationStatus; }
    public String getVerificationRejectionReason() { return verificationRejectionReason; }
    public void setVerificationRejectionReason(String verificationRejectionReason) { this.verificationRejectionReason = verificationRejectionReason; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
