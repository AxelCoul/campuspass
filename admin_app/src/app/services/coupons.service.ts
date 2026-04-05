import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';

export interface Coupon {
  id: number;
  userId: number;
  offerId: number;
  couponCode: string;
  status: string;
  generatedAt?: string;
  expiresAt?: string;
  usedAt?: string;
}

@Injectable({ providedIn: 'root' })
export class CouponsService {
  constructor(private http: HttpClient) {}

  getAll(): Observable<Coupon[]> {
    return this.http.get<Coupon[]>(`${environment.apiUrl}/admin/coupons`);
  }
}

