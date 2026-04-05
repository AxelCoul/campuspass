import { Injectable } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';

export interface RewardCatalogItem {
  id: number;
  title: string;
  description: string;
  pointsCost: number;
  active: boolean;
}

export interface RewardCatalogItemRequest {
  title: string;
  description: string;
  pointsCost: number;
  active: boolean;
}

export interface AdminRewardRedemption {
  id: number;
  userId: number;
  studentName?: string;
  studentEmail?: string;
  rewardId: number;
  rewardTitle: string;
  pointsCost: number;
  redeemedAt: string;
}

export interface LoyaltyConfig {
  fcfaPerPoint: number;
}

export interface AdminReferralStats {
  registeredReferrals: number;
  activeSubscribedReferrals: number;
}

export interface AdminReferrerStatsRow {
  userId: number;
  studentName: string;
  studentEmail?: string;
  referralCode: string;
  registeredReferrals: number;
  activeSubscribedReferrals: number;
  pointsPerReferral: number;
  pointsEarned: number;
}

export interface AdminReferralPayoutRequest {
  id: number;
  referrerId: number;
  studentName?: string;
  studentEmail?: string;
  requestYear: number;
  requestMonth: number;
  amountFcfa: number;
  status: 'PENDING' | 'PAID' | 'REJECTED';
  requestedAt: string;
}

@Injectable({ providedIn: 'root' })
export class RewardsAdminService {
  constructor(private http: HttpClient) {}

  getCatalog(): Observable<RewardCatalogItem[]> {
    return this.http.get<RewardCatalogItem[]>(`${environment.apiUrl}/admin/rewards/catalog`);
  }

  create(body: RewardCatalogItemRequest): Observable<RewardCatalogItem> {
    return this.http.post<RewardCatalogItem>(`${environment.apiUrl}/admin/rewards/catalog`, body);
  }

  update(id: number, body: RewardCatalogItemRequest): Observable<RewardCatalogItem> {
    return this.http.put<RewardCatalogItem>(`${environment.apiUrl}/admin/rewards/catalog/${id}`, body);
  }

  setActive(id: number, active: boolean): Observable<void> {
    return this.http.patch<void>(`${environment.apiUrl}/admin/rewards/catalog/${id}/active`, { active });
  }

  delete(id: number): Observable<void> {
    return this.http.delete<void>(`${environment.apiUrl}/admin/rewards/catalog/${id}`);
  }

  getRedemptions(): Observable<AdminRewardRedemption[]> {
    return this.http.get<AdminRewardRedemption[]>(`${environment.apiUrl}/admin/rewards/redemptions`);
  }

  getLoyaltyConfig(): Observable<LoyaltyConfig> {
    return this.http.get<LoyaltyConfig>(`${environment.apiUrl}/admin/rewards/config`);
  }

  updateLoyaltyConfig(fcfaPerPoint: number): Observable<LoyaltyConfig> {
    return this.http.put<LoyaltyConfig>(`${environment.apiUrl}/admin/rewards/config`, { fcfaPerPoint });
  }

  getReferralStats(): Observable<AdminReferralStats> {
    return this.http.get<AdminReferralStats>(`${environment.apiUrl}/admin/rewards/referrals-stats`);
  }

  getReferrersStats(filters?: {
    dateFrom?: string;
    dateTo?: string;
    university?: string;
    top?: number;
  }): Observable<AdminReferrerStatsRow[]> {
    let params = new HttpParams();
    if (filters?.dateFrom) params = params.set('dateFrom', filters.dateFrom);
    if (filters?.dateTo) params = params.set('dateTo', filters.dateTo);
    if (filters?.university) params = params.set('university', filters.university);
    if (filters?.top != null && filters.top > 0) params = params.set('top', String(filters.top));
    return this.http.get<AdminReferrerStatsRow[]>(
      `${environment.apiUrl}/admin/rewards/referrers-stats`,
      { params }
    );
  }

  getPayoutRequests(): Observable<AdminReferralPayoutRequest[]> {
    return this.http.get<AdminReferralPayoutRequest[]>(`${environment.apiUrl}/admin/rewards/payout-requests`);
  }

  markPayoutPaid(id: number): Observable<void> {
    return this.http.patch<void>(`${environment.apiUrl}/admin/rewards/payout-requests/${id}/paid`, {});
  }

  rejectPayout(id: number): Observable<void> {
    return this.http.patch<void>(`${environment.apiUrl}/admin/rewards/payout-requests/${id}/reject`, {});
  }
}
