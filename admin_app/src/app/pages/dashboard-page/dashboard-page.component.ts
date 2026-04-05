import { Component, OnInit } from '@angular/core';
import { RouterLink } from '@angular/router';
import { DecimalPipe } from '@angular/common';
import { DashboardService, DashboardCharts, PaymentDashboardStats, PaymentAlerts } from '../../services/dashboard.service';

@Component({
  selector: 'app-dashboard-page',
  standalone: true,
  imports: [RouterLink, DecimalPipe],
  templateUrl: './dashboard-page.component.html',
  styleUrl: './dashboard-page.component.css'
})
export class DashboardPageComponent implements OnInit {
  stats = {
    totalStudents: 0,
    totalMerchants: 0,
    activeOffers: 0,
    couponsUsedToday: 0,
    totalTransactions: 0,
    revenue: 0,
    totalDiscountsGenerated: 0,
    totalSubscriptions: 0
  };
  paymentStats: PaymentDashboardStats | null = null;
  paymentAlerts: PaymentAlerts | null = null;
  charts: DashboardCharts | null = null;
  loading = true;
  chartsLoading = true;

  constructor(private dashboardService: DashboardService) {}

  ngOnInit(): void {
    this.dashboardService.getStats().subscribe({
      next: (data) => {
        this.stats.totalStudents = data.totalStudents ?? 0;
        this.stats.totalMerchants = data.totalMerchants ?? 0;
        this.stats.activeOffers = data.activeOffers ?? 0;
        this.stats.couponsUsedToday = data.couponsUsedToday ?? 0;
        this.stats.totalTransactions = data.totalTransactions ?? 0;
        this.stats.revenue = data.revenue ?? 0;
        this.stats.totalDiscountsGenerated = data.totalDiscountsGenerated ?? 0;
        this.stats.totalSubscriptions = data.totalSubscriptions ?? 0;
        this.loading = false;
      },
      error: () => { this.loading = false; }
    });
    this.dashboardService.getPaymentDashboardStats().subscribe({
      next: (data) => this.paymentStats = data,
      error: () => {}
    });
    this.dashboardService.getPaymentAlerts().subscribe({
      next: (data) => this.paymentAlerts = data,
      error: () => {}
    });
    this.dashboardService.getCharts().subscribe({
      next: (data) => { this.charts = data; this.chartsLoading = false; },
      error: () => { this.chartsLoading = false; }
    });
  }

  maxTransactionsCount(): number {
    if (!this.charts?.transactionsPerDay?.length) return 1;
    return Math.max(1, ...this.charts.transactionsPerDay.map(p => p.count));
  }

  maxUsersCount(): number {
    if (!this.charts?.newUsersPerDay?.length) return 1;
    return Math.max(1, ...this.charts.newUsersPerDay.map(p => p.count));
  }

  get dashboardAlertClass(): string {
    const severity = this.paymentAlerts?.severity ?? 'OK';
    if (severity === 'CRITICAL') return 'alert-critical';
    if (severity === 'WARNING') return 'alert-warning';
    return 'alert-ok';
  }
}
