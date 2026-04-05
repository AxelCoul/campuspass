package com.campuspass.backend.dto;

public class DashboardStatsDto {
    private long totalStudents;
    private long totalMerchants;
    private long activeOffers;
    private long couponsUsedToday;
    private long totalTransactions;
    private double revenue;
    /** Réductions totales générées (somme des montants de réduction sur toutes les transactions). */
    private double totalDiscountsGenerated;
    /** Nombre total d'abonnements (paiements réussis). */
    private long totalSubscriptions;

    public long getTotalStudents() { return totalStudents; }
    public void setTotalStudents(long totalStudents) { this.totalStudents = totalStudents; }
    public long getTotalMerchants() { return totalMerchants; }
    public void setTotalMerchants(long totalMerchants) { this.totalMerchants = totalMerchants; }
    public long getActiveOffers() { return activeOffers; }
    public void setActiveOffers(long activeOffers) { this.activeOffers = activeOffers; }
    public long getCouponsUsedToday() { return couponsUsedToday; }
    public void setCouponsUsedToday(long couponsUsedToday) { this.couponsUsedToday = couponsUsedToday; }
    public long getTotalTransactions() { return totalTransactions; }
    public void setTotalTransactions(long totalTransactions) { this.totalTransactions = totalTransactions; }
    public double getRevenue() { return revenue; }
    public void setRevenue(double revenue) { this.revenue = revenue; }
    public double getTotalDiscountsGenerated() { return totalDiscountsGenerated; }
    public void setTotalDiscountsGenerated(double totalDiscountsGenerated) { this.totalDiscountsGenerated = totalDiscountsGenerated; }
    public long getTotalSubscriptions() { return totalSubscriptions; }
    public void setTotalSubscriptions(long totalSubscriptions) { this.totalSubscriptions = totalSubscriptions; }
}
