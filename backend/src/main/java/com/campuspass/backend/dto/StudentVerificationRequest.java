package com.campuspass.backend.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public class StudentVerificationRequest {

    /**
     * Type de document fourni par l'étudiant.
     * Exemple : "STUDENT_CARD" ou "ENROLLMENT_CERTIFICATE".
     */
    @Size(max = 50)
    private String verificationDocumentType;

    /**
     * Numéro de matricule / carte étudiant.
     * Devient obligatoire pour toute demande de vérification.
     */
    @NotBlank
    @Size(max = 200)
    private String studentCardNumber;

    /**
     * URL du document uploadé (carte ou attestation).
     */
    @NotBlank
    @Size(max = 500)
    private String studentCardImage;

    @Size(max = 200)
    private String university;

    @Size(max = 100)
    private String city;

    @Size(max = 100)
    private String country;

    public String getVerificationDocumentType() {
        return verificationDocumentType;
    }

    public void setVerificationDocumentType(String verificationDocumentType) {
        this.verificationDocumentType = verificationDocumentType;
    }

    public String getStudentCardNumber() { return studentCardNumber; }
    public void setStudentCardNumber(String studentCardNumber) { this.studentCardNumber = studentCardNumber; }

    public String getStudentCardImage() { return studentCardImage; }
    public void setStudentCardImage(String studentCardImage) { this.studentCardImage = studentCardImage; }

    public String getUniversity() { return university; }
    public void setUniversity(String university) { this.university = university; }

    public String getCity() { return city; }
    public void setCity(String city) { this.city = city; }

    public String getCountry() { return country; }
    public void setCountry(String country) { this.country = country; }
}

