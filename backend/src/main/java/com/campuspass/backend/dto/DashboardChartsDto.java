package com.campuspass.backend.dto;

import java.util.List;

public class DashboardChartsDto {
    private List<PointDto> transactionsPerDay;
    private List<PointDto> newUsersPerDay;
    private List<TopOfferDto> topOffers;

    public List<PointDto> getTransactionsPerDay() { return transactionsPerDay; }
    public void setTransactionsPerDay(List<PointDto> transactionsPerDay) { this.transactionsPerDay = transactionsPerDay; }
    public List<PointDto> getNewUsersPerDay() { return newUsersPerDay; }
    public void setNewUsersPerDay(List<PointDto> newUsersPerDay) { this.newUsersPerDay = newUsersPerDay; }
    public List<TopOfferDto> getTopOffers() { return topOffers; }
    public void setTopOffers(List<TopOfferDto> topOffers) { this.topOffers = topOffers; }
}
