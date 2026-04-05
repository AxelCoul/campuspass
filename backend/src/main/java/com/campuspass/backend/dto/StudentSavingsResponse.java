package com.campuspass.backend.dto;

import java.util.List;

public class StudentSavingsResponse {
    private double totalSaved;
    private long offersUsedCount;
    private long merchantsVisitedCount;
    private List<SavingsEntryDto> history;

    public double getTotalSaved() { return totalSaved; }
    public void setTotalSaved(double totalSaved) { this.totalSaved = totalSaved; }
    public long getOffersUsedCount() { return offersUsedCount; }
    public void setOffersUsedCount(long offersUsedCount) { this.offersUsedCount = offersUsedCount; }
    public long getMerchantsVisitedCount() { return merchantsVisitedCount; }
    public void setMerchantsVisitedCount(long merchantsVisitedCount) { this.merchantsVisitedCount = merchantsVisitedCount; }
    public List<SavingsEntryDto> getHistory() { return history; }
    public void setHistory(List<SavingsEntryDto> history) { this.history = history; }
}
