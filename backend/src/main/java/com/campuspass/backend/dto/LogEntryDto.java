package com.campuspass.backend.dto;

import java.time.LocalDateTime;

public class LogEntryDto {
    private Long id;
    private Long userId;
    private String email;
    private LocalDateTime loginAt;
    private String ipAddress;
    private String device;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public LocalDateTime getLoginAt() { return loginAt; }
    public void setLoginAt(LocalDateTime loginAt) { this.loginAt = loginAt; }
    public String getIpAddress() { return ipAddress; }
    public void setIpAddress(String ipAddress) { this.ipAddress = ipAddress; }
    public String getDevice() { return device; }
    public void setDevice(String device) { this.device = device; }
}
