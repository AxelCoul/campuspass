package com.campuspass.backend.dto;

import jakarta.validation.constraints.*;

public class MerchantRequest {

    @NotBlank
    @Size(max = 200)
    private String name;
    @Size(max = 2000)
    private String description;
    @Email
    @Size(max = 100)
    private String email;
    @Size(max = 30)
    private String phone;
    @Size(max = 500)
    private String website;
    @Size(max = 500)
    private String logoUrl;
    @Size(max = 500)
    private String coverImage;
    private Long categoryId;
    @Size(max = 500)
    private String address;
    @Size(max = 100)
    private String city;
    @Size(max = 100)
    private String neighborhood;
    @Size(max = 100)
    private String country;
    private Double latitude;
    private Double longitude;
    @Size(max = 500)
    private String openingHours;

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
    public String getWebsite() { return website; }
    public void setWebsite(String website) { this.website = website; }
    public String getLogoUrl() { return logoUrl; }
    public void setLogoUrl(String logoUrl) { this.logoUrl = logoUrl; }
    public String getCoverImage() { return coverImage; }
    public void setCoverImage(String coverImage) { this.coverImage = coverImage; }
    public Long getCategoryId() { return categoryId; }
    public void setCategoryId(Long categoryId) { this.categoryId = categoryId; }
    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }
    public String getCity() { return city; }
    public void setCity(String city) { this.city = city; }
    public String getNeighborhood() { return neighborhood; }
    public void setNeighborhood(String neighborhood) { this.neighborhood = neighborhood; }
    public String getCountry() { return country; }
    public void setCountry(String country) { this.country = country; }
    public Double getLatitude() { return latitude; }
    public void setLatitude(Double latitude) { this.latitude = latitude; }
    public Double getLongitude() { return longitude; }
    public void setLongitude(Double longitude) { this.longitude = longitude; }
    public String getOpeningHours() { return openingHours; }
    public void setOpeningHours(String openingHours) { this.openingHours = openingHours; }
}
