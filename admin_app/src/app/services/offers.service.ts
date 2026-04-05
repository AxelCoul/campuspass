import { Injectable } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';

export interface Offer {
  id: number;
  merchantId: number;
  categoryId?: number;
  title: string;
  description?: string;
  originalPrice?: number;
  discountPercentage?: number;
  discountAmount?: number;
  finalPrice?: number;
  imageUrl?: string;
  imageUrls?: string[];
  maxCoupons?: number;
  usedCoupons?: number;
  maxPassesPerDayPerUser?: number;
  maxQuantityPerPass?: number;
  targetUniversities?: string;
  startDate?: string;
  endDate?: string;
  status: string;
  createdAt?: string;
}

export interface OfferRequest {
  merchantId: number;
  categoryId?: number;
  title: string;
  description?: string;
  /** `null` pour effacer les prix en base (mode pourcentage seul). */
  originalPrice?: number | null;
  discountPercentage?: number;
  discountAmount?: number;
  finalPrice?: number | null;
  imageUrl?: string;
  /** Jusqu’à 3 URLs (uploadées) pour l’aperçu multi-images côté mobile. */
  imageUrls?: string[];
  maxCoupons?: number;
   /** Nombre max de passages par jour (null/0 = illimité) */
  maxPassesPerDayPerUser?: number;
   /** Quantité max par passage (null/0 = illimité) */
  maxQuantityPerPass?: number;
  targetUniversities?: string;
  startDate?: string;
  endDate?: string;
}

@Injectable({ providedIn: 'root' })
export class OffersService {
  constructor(private http: HttpClient) {}

  getAll(params?: { merchantId?: number }): Observable<Offer[]> {
    let p = new HttpParams();
    if (params?.merchantId != null) p = p.set('merchantId', params.merchantId);
    return this.http.get<Offer[]>(`${environment.apiUrl}/offers`, { params: p });
  }

  getById(id: number): Observable<Offer> {
    return this.http.get<Offer>(`${environment.apiUrl}/offers/${id}`);
  }

  create(body: OfferRequest): Observable<Offer> {
    return this.http.post<Offer>(`${environment.apiUrl}/offers`, body);
  }

  update(id: number, body: Partial<OfferRequest>): Observable<Offer> {
    return this.http.put<Offer>(`${environment.apiUrl}/offers/${id}`, body);
  }

  delete(id: number): Observable<void> {
    return this.http.delete<void>(`${environment.apiUrl}/offers/${id}`);
  }

  updateStatus(id: number, status: string): Observable<void> {
    return this.http.patch<void>(`${environment.apiUrl}/admin/offers/${id}/status`, { status });
  }
}
