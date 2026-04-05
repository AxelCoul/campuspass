package com.campuspass.backend.model;

import com.campuspass.backend.model.enums.StudentVerificationStatus;
import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(
    name = "student_profiles",
    uniqueConstraints = {
        @UniqueConstraint(name = "uk_student_univ_matricule", columnNames = {"university", "studentCardNumber"})
    }
)
public class StudentProfile {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private Long userId;

    /**
     * Type de document fourni par l'étudiant pour la vérification
     * (ex: STUDENT_CARD, ENROLLMENT_CERTIFICATE).
     */
    private String verificationDocumentType;

    private String university;
    private String studentCardNumber;
    private String studentCardImage;
    private String city;
    private String country;
    private Boolean verified = false;
    @Enumerated(EnumType.STRING)
    // La DB peut contenir des anciennes lignes sans cette colonne.
    // On la rend nullable pour que Hibernate puisse ajouter la colonne sans échec de migration.
    @Column(nullable = true)
    private StudentVerificationStatus verificationStatus = StudentVerificationStatus.NONE;
    @Column(length = 500)
    private String verificationRejectionReason;
    private LocalDateTime verificationDate;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "userId", insertable = false, updatable = false)
    private User user;

    public StudentProfile() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }
    public String getVerificationDocumentType() { return verificationDocumentType; }
    public void setVerificationDocumentType(String verificationDocumentType) { this.verificationDocumentType = verificationDocumentType; }
    public String getUniversity() { return university; }
    public void setUniversity(String university) { this.university = university; }
    public String getStudentCardNumber() { return studentCardNumber; }
    public void setStudentCardNumber(String studentCardNumber) { this.studentCardNumber = studentCardNumber; }
    public String getStudentCardImage() { return studentCardImage; }
    public void setStudentCardImage(String studentCardImage) { this.studentCardImage = studentCardImage; }
    public String getCity() { return city; }
    public void setCity(String city) { this.city = city; }
    public String getCountry() { return country; }
    public void setCountry(String country) { this.country = country; }
    public Boolean getVerified() { return verified; }
    public void setVerified(Boolean verified) { this.verified = verified; }
    public StudentVerificationStatus getVerificationStatus() { return verificationStatus; }
    public void setVerificationStatus(StudentVerificationStatus verificationStatus) { this.verificationStatus = verificationStatus; }
    public String getVerificationRejectionReason() { return verificationRejectionReason; }
    public void setVerificationRejectionReason(String verificationRejectionReason) { this.verificationRejectionReason = verificationRejectionReason; }
    public LocalDateTime getVerificationDate() { return verificationDate; }
    public void setVerificationDate(LocalDateTime verificationDate) { this.verificationDate = verificationDate; }
}
