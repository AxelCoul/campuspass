package com.campuspass.backend.dto;

public class AdminPaymentAlertsResponse {
    private int pendingTooLongCount;
    private int longPendingThresholdMinutes;
    private int failedLast24h;
    private int totalLast24h;
    private double failureRate24h;
    private boolean highFailureRate;
    private boolean hasAlerts;
    private String severity;
    private int criticalAlertsCount;

    public int getPendingTooLongCount() { return pendingTooLongCount; }
    public void setPendingTooLongCount(int pendingTooLongCount) { this.pendingTooLongCount = pendingTooLongCount; }
    public int getLongPendingThresholdMinutes() { return longPendingThresholdMinutes; }
    public void setLongPendingThresholdMinutes(int longPendingThresholdMinutes) { this.longPendingThresholdMinutes = longPendingThresholdMinutes; }
    public int getFailedLast24h() { return failedLast24h; }
    public void setFailedLast24h(int failedLast24h) { this.failedLast24h = failedLast24h; }
    public int getTotalLast24h() { return totalLast24h; }
    public void setTotalLast24h(int totalLast24h) { this.totalLast24h = totalLast24h; }
    public double getFailureRate24h() { return failureRate24h; }
    public void setFailureRate24h(double failureRate24h) { this.failureRate24h = failureRate24h; }
    public boolean isHighFailureRate() { return highFailureRate; }
    public void setHighFailureRate(boolean highFailureRate) { this.highFailureRate = highFailureRate; }
    public boolean isHasAlerts() { return hasAlerts; }
    public void setHasAlerts(boolean hasAlerts) { this.hasAlerts = hasAlerts; }
    public String getSeverity() { return severity; }
    public void setSeverity(String severity) { this.severity = severity; }
    public int getCriticalAlertsCount() { return criticalAlertsCount; }
    public void setCriticalAlertsCount(int criticalAlertsCount) { this.criticalAlertsCount = criticalAlertsCount; }
}
