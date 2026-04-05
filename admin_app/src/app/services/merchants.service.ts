import { Injectable } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';

export interface Merchant {
  id: number;
  ownerId: number;
  name: string;
  description?: string;
  email?: string;
  phone?: string;
  logoUrl?: string;
  /** Image de couverture (affichée en priorité sur la carte liste admin). */
  coverImage?: string;
  address?: string;
  city?: string;
  country?: string;
  categoryId?: number;
  latitude?: number;
  longitude?: number;
  openingHours?: string;
  status: string;
  verified?: boolean;
  createdAt?: string;
}

export interface CreateMerchantRequest {
  firstName: string;
  lastName: string;
  email: string;
  password: string;
  phoneNumber?: string;
  merchantName: string;
  city?: string;
  country?: string;
  categoryId?: number;
}

export interface UpdateMerchantRequest {
  name?: string;
  description?: string;
  email?: string;
  phone?: string;
  logoUrl?: string;
  address?: string;
  city?: string;
  country?: string;
  latitude?: number;
  longitude?: number;
  categoryId?: number;
  openingHours?: string;
}

@Injectable({ providedIn: 'root' })
export class MerchantsService {
  constructor(private http: HttpClient) {}

  getAll(params?: { status?: string }): Observable<Merchant[]> {
    let p = new HttpParams();
    if (params?.status) p = p.set('status', params.status);
    return this.http.get<Merchant[]>(`${environment.apiUrl}/merchants`, { params: p });
  }

  getById(id: number): Observable<Merchant> {
    return this.http.get<Merchant>(`${environment.apiUrl}/merchants/${id}`);
  }

  approve(id: number): Observable<Merchant> {
    return this.http.put<Merchant>(`${environment.apiUrl}/admin/merchants/${id}/approve`, {});
  }

  reject(id: number): Observable<void> {
    return this.http.put<void>(`${environment.apiUrl}/admin/merchants/${id}/reject`, {});
  }

  /** Création d'un compte commerce (utilisateur MERCHANT + Merchant) par un admin. */
  createAccount(body: CreateMerchantRequest): Observable<void> {
    const payload = { ...body, role: 'MERCHANT' };
    return this.http.post<void>(`${environment.apiUrl}/auth/register`, payload);
  }

  update(id: number, body: UpdateMerchantRequest): Observable<Merchant> {
    return this.http.put<Merchant>(`${environment.apiUrl}/merchants/${id}`, body);
  }
}
