package com.campuspass.backend.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.Size;

public class StudentProfileUpdateRequest {
    @Size(min = 1, max = 100)
    private String firstName;

    @Email
    private String email;

    @Size(max = 20)
    private String phoneNumber;

    @Size(max = 120)
    private String city;

    public String getFirstName() { return firstName; }
    public void setFirstName(String firstName) { this.firstName = firstName; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getPhoneNumber() { return phoneNumber; }
    public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }
    public String getCity() { return city; }
    public void setCity(String city) { this.city = city; }
}
