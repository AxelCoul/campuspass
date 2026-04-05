package com.campuspass.backend.dto;

/**
 * Statistiques paiements pour le dashboard admin.
 */
public class PaymentDashboardDto {
    private double totalRevenue;
    private long paymentsToday;
    private long paymentsThisMonth;

    public double getTotalRevenue() { return totalRevenue; }
    public void setTotalRevenue(double totalRevenue) { this.totalRevenue = totalRevenue; }
    public long getPaymentsToday() { return paymentsToday; }
    public void setPaymentsToday(long paymentsToday) { this.paymentsToday = paymentsToday; }
    public long getPaymentsThisMonth() { return paymentsThisMonth; }
    public void setPaymentsThisMonth(long paymentsThisMonth) { this.paymentsThisMonth = paymentsThisMonth; }
}
