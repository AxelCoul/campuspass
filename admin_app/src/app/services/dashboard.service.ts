import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';

export interface DashboardStats {
  totalStudents: number;
  totalMerchants: number;
  activeOffers: number;
  couponsUsedToday: number;
  totalTransactions: number;
  revenue?: number;
  totalDiscountsGenerated?: number;
  totalSubscriptions?: number;
}

export interface PaymentDashboardStats {
  totalRevenue: number;
  paymentsToday: number;
  paymentsThisMonth: number;
}

export interface PaymentAlerts {
  pendingTooLongCount: number;
  longPendingThresholdMinutes: number;
  failedLast24h: number;
  totalLast24h: number;
  failureRate24h: number;
  highFailureRate: boolean;
  hasAlerts: boolean;
  severity: 'OK' | 'WARNING' | 'CRITICAL';
  criticalAlertsCount: number;
}

export interface PointDto {
  date: string;
  count: number;
}

export interface TopOfferDto {
  offerId: number;
  title?: string;
  usageCount: number;
}

export interface DashboardCharts {
  transactionsPerDay: PointDto[];
  newUsersPerDay: PointDto[];
  topOffers: TopOfferDto[];
}

@Injectable({ providedIn: 'root' })
export class DashboardService {
  constructor(private http: HttpClient) {}

  getStats(): Observable<DashboardStats> {
    return this.http.get<DashboardStats>(`${environment.apiUrl}/admin/dashboard/stats`);
  }

  getCharts(): Observable<DashboardCharts> {
    return this.http.get<DashboardCharts>(`${environment.apiUrl}/admin/dashboard/charts`);
  }

  getPaymentDashboardStats(): Observable<PaymentDashboardStats> {
    return this.http.get<PaymentDashboardStats>(`${environment.apiUrl}/admin/dashboard/payments`);
  }

  getPaymentAlerts(): Observable<PaymentAlerts> {
    return this.http.get<PaymentAlerts>(`${environment.apiUrl}/admin/subscription-payments/alerts`);
  }
}
