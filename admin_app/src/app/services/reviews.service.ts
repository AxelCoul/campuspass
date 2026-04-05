import { Injectable } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';

export interface Review {
  id: number;
  userId: number;
  merchantId: number;
  rating?: number;
  comment?: string;
  status?: string;
  createdAt?: string;
}

@Injectable({ providedIn: 'root' })
export class ReviewsService {
  constructor(private http: HttpClient) {}

  getAll(merchantId?: number): Observable<Review[]> {
    let params = new HttpParams();
    if (merchantId != null) params = params.set('merchantId', merchantId.toString());
    return this.http.get<Review[]>(`${environment.apiUrl}/admin/reviews`, { params });
  }

  updateStatus(id: number, status: string): Observable<void> {
    return this.http.patch<void>(`${environment.apiUrl}/admin/reviews/${id}/status`, { status });
  }
}
