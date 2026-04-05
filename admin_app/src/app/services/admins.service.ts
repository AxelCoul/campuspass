import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';

export interface Admin {
  id: number;
  firstName: string;
  lastName: string;
  email: string;
  adminLevel?: string;
  status?: string;
  createdAt?: string;
}

export interface CreateAdminRequest {
  firstName: string;
  lastName: string;
  email: string;
  password: string;
  adminLevel?: string;
}

@Injectable({ providedIn: 'root' })
export class AdminsService {
  constructor(private http: HttpClient) {}

  getAll(): Observable<Admin[]> {
    return this.http.get<Admin[]>(`${environment.apiUrl}/admin/admins`);
  }

  create(req: CreateAdminRequest): Observable<Admin> {
    return this.http.post<Admin>(`${environment.apiUrl}/admin/admins`, req);
  }

  updateRole(id: number, adminLevel: string): Observable<void> {
    return this.http.patch<void>(`${environment.apiUrl}/admin/admins/${id}/role`, { adminLevel });
  }

  disable(id: number): Observable<void> {
    return this.http.patch<void>(`${environment.apiUrl}/admin/admins/${id}/disable`, {});
  }
}
