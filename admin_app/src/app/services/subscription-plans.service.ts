import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';

export type SubscriptionPlanType = 'MONTHLY' | 'YEARLY';

export interface SubscriptionPlan {
  id: number;
  name: string;
  type: SubscriptionPlanType;
  price: number;
  promoPrice?: number | null;
  startPromoDate?: string | null;
  endPromoDate?: string | null;
  active: boolean;
  effectivePrice?: number;
  promoActive?: boolean;
  createdAt?: string;
}

export interface SubscriptionPlanRequest {
  name: string;
  type: SubscriptionPlanType;
  price: number;
  promoPrice?: number | null;
  startPromoDate?: string | null;
  endPromoDate?: string | null;
  active: boolean;
}

@Injectable({ providedIn: 'root' })
export class SubscriptionPlansService {
  constructor(private http: HttpClient) {}

  getAll(): Observable<SubscriptionPlan[]> {
    return this.http.get<SubscriptionPlan[]>(`${environment.apiUrl}/admin/plans`);
  }

  create(body: SubscriptionPlanRequest): Observable<SubscriptionPlan> {
    return this.http.post<SubscriptionPlan>(`${environment.apiUrl}/admin/plans`, body);
  }

  update(id: number, body: Partial<SubscriptionPlanRequest>): Observable<SubscriptionPlan> {
    return this.http.put<SubscriptionPlan>(`${environment.apiUrl}/admin/plans/${id}`, body);
  }

  delete(id: number): Observable<void> {
    return this.http.delete<void>(`${environment.apiUrl}/admin/plans/${id}`);
  }
}

