package com.campuspass.backend.dto;

/**
 * Statistiques dashboard pour un commerce.
 */
public class MerchantStatsDto {
    private long couponsUsedToday;
    private double revenueToday;
    private int activeOffersCount;
    /** Total des ventes générées via l'app (toutes les transactions). */
    private double totalSalesViaApp;
    /** Total des réductions accordées (somme des montants de réduction). */
    private double totalDiscountsGiven;
    /** Nombre de clients étudiants uniques ayant utilisé un coupon chez ce marchand. */
    private int uniqueClientsCount;
    /** Titre de l'offre la plus utilisée (optionnel). */
    private String topOfferTitle;
    /** Nombre d'utilisations de l'offre top (0 si aucune). */
    private long topOfferUsageCount;

    public long getCouponsUsedToday() { return couponsUsedToday; }
    public void setCouponsUsedToday(long couponsUsedToday) { this.couponsUsedToday = couponsUsedToday; }
    public double getRevenueToday() { return revenueToday; }
    public void setRevenueToday(double revenueToday) { this.revenueToday = revenueToday; }
    public int getActiveOffersCount() { return activeOffersCount; }
    public void setActiveOffersCount(int activeOffersCount) { this.activeOffersCount = activeOffersCount; }
    public double getTotalSalesViaApp() { return totalSalesViaApp; }
    public void setTotalSalesViaApp(double totalSalesViaApp) { this.totalSalesViaApp = totalSalesViaApp; }
    public double getTotalDiscountsGiven() { return totalDiscountsGiven; }
    public void setTotalDiscountsGiven(double totalDiscountsGiven) { this.totalDiscountsGiven = totalDiscountsGiven; }
    public int getUniqueClientsCount() { return uniqueClientsCount; }
    public void setUniqueClientsCount(int uniqueClientsCount) { this.uniqueClientsCount = uniqueClientsCount; }
    public String getTopOfferTitle() { return topOfferTitle; }
    public void setTopOfferTitle(String topOfferTitle) { this.topOfferTitle = topOfferTitle; }
    public long getTopOfferUsageCount() { return topOfferUsageCount; }
    public void setTopOfferUsageCount(long topOfferUsageCount) { this.topOfferUsageCount = topOfferUsageCount; }
}
