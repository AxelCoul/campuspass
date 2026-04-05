import { Injectable } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';

export type AdPosition = 'HOME_BANNER' | 'HOME_TOP' | 'SPONSORED_OFFER' | 'OFFERS_PAGE' | 'SEARCH_PAGE' | 'NOTIFICATION';

export interface Advertisement {
  id: number;
  merchantId: number;
  title?: string;
  description?: string;
  /** Texte du bouton (bandeau HOME_TOP, etc.) */
  ctaLabel?: string;
  imageUrl?: string;
  videoUrl?: string;
  targetUrl?: string;
  targetCity?: string;
  targetCountry?: string;
  targetUniversity?: string;
  targetSegment?: string;
  position?: AdPosition;
  startDate?: string;
  endDate?: string;
  budget?: number;
  offerId?: number;
  status: string;
  createdAt?: string;
}

export interface AdvertisementRequest {
  merchantId: number;
  title?: string;
  description?: string;
  ctaLabel?: string;
  imageUrl?: string;
  videoUrl?: string;
  targetUrl?: string;
  targetCity?: string;
  targetCountry?: string;
  targetUniversity?: string;
  targetSegment?: string;
  position?: AdPosition;
  startDate?: string;
  endDate?: string;
  budget?: number;
  offerId?: number;
}

@Injectable({ providedIn: 'root' })
export class AdvertisementsService {
  constructor(private http: HttpClient) {}

  getAll(params?: { position?: AdPosition; merchantId?: number }): Observable<Advertisement[]> {
    let p = new HttpParams();
    if (params?.position) p = p.set('position', params.position);
    if (params?.merchantId != null) p = p.set('merchantId', params.merchantId);
    return this.http.get<Advertisement[]>(`${environment.apiUrl}/advertisements`, { params: p });
  }

  getById(id: number): Observable<Advertisement> {
    return this.http.get<Advertisement>(`${environment.apiUrl}/advertisements/${id}`);
  }

  create(req: AdvertisementRequest): Observable<Advertisement> {
    return this.http.post<Advertisement>(`${environment.apiUrl}/advertisements`, req);
  }

  update(id: number, req: AdvertisementRequest): Observable<Advertisement> {
    return this.http.put<Advertisement>(`${environment.apiUrl}/advertisements/${id}`, req);
  }

  delete(id: number): Observable<void> {
    return this.http.delete<void>(`${environment.apiUrl}/advertisements/${id}`);
  }
}
