import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';

export interface Payment {
  id: number;
  studentId?: number;
  studentName?: string;
  studentEmail?: string;
  studentPhone?: string;
  planId?: number;
  planName?: string;
  amount?: number;
  currency?: string;
  paymentMethod?: string;
  status: string;
  paymentReference?: string;
  paidAt?: string;
  createdAt?: string;
  lastSyncedAt?: string;
  subscriptionEndDate?: string;
  hasActiveSubscription?: boolean;
  remainingDays?: number;
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

@Injectable({ providedIn: 'root' })
export class PaymentsService {
  constructor(private http: HttpClient) {}

  getAll(): Observable<Payment[]> {
    return this.http.get<Payment[]>(`${environment.apiUrl}/admin/subscription-payments`);
  }

  getAlerts(): Observable<PaymentAlerts> {
    return this.http.get<PaymentAlerts>(`${environment.apiUrl}/admin/subscription-payments/alerts`);
  }

  recheck(id: number): Observable<{ success?: boolean; status?: string; message?: string }> {
    return this.http.post<{ success?: boolean; status?: string; message?: string }>(
      `${environment.apiUrl}/admin/subscription-payments/${id}/recheck`,
      {}
    );
  }

  relaunch(id: number): Observable<{ paymentId?: number; paymentUrl?: string; message?: string }> {
    return this.http.post<{ paymentId?: number; paymentUrl?: string; message?: string }>(
      `${environment.apiUrl}/admin/subscription-payments/${id}/relaunch`,
      {}
    );
  }
}
