import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { DecimalPipe } from '@angular/common';
import { DashboardService, DashboardCharts, DashboardStats } from '../../services/dashboard.service';

@Component({
  selector: 'app-analytics-page',
  standalone: true,
  imports: [CommonModule, DecimalPipe],
  templateUrl: './analytics-page.component.html',
  styleUrl: './analytics-page.component.css'
})
export class AnalyticsPageComponent implements OnInit {
  stats: DashboardStats | null = null;
  charts: DashboardCharts | null = null;
  loading = true;
  chartsLoading = true;

  constructor(private dashboardService: DashboardService) {}

  ngOnInit(): void {
    this.dashboardService.getStats().subscribe({
      next: (data) => { this.stats = data; this.loading = false; },
      error: () => { this.loading = false; }
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
}
