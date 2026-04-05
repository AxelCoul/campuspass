import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, tap } from 'rxjs';
import { Router } from '@angular/router';
import { environment } from '../../environments/environment';

export interface AdminUser {
  id: number;
  email: string;
  firstName?: string;
  lastName?: string;
  role: string;
  adminLevel?: string;
}

export interface AuthResponse {
  token: string;
  id?: number;
  email?: string;
  firstName?: string;
  lastName?: string;
  role?: string;
  adminLevel?: string;
}

@Injectable({ providedIn: 'root' })
export class AuthService {
  private readonly tokenKey = 'admin_token';
  private readonly userKey = 'admin_user';

  constructor(
    private http: HttpClient,
    private router: Router
  ) {}

  login(email: string, password: string): Observable<AuthResponse> {
    return this.http
      .post<AuthResponse>(`${environment.apiUrl}/auth/admin/login`, { email, password })
      .pipe(
        tap((res) => {
          if (res.token) {
            localStorage.setItem(this.tokenKey, res.token);
            localStorage.setItem(this.userKey, JSON.stringify({
              id: res.id,
              email: res.email,
              firstName: res.firstName,
              lastName: res.lastName,
              role: res.role || 'ADMIN',
              adminLevel: (res as { adminLevel?: string }).adminLevel || 'ADMIN'
            }));
          }
        })
      );
  }

  logout(): void {
    localStorage.removeItem(this.tokenKey);
    localStorage.removeItem(this.userKey);
    this.router.navigate(['/admin/login']);
  }

  getToken(): string | null {
    return localStorage.getItem(this.tokenKey);
  }

  getCurrentUser(): AdminUser | null {
    const u = localStorage.getItem(this.userKey);
    return u ? JSON.parse(u) : null;
  }

  isAuthenticated(): boolean {
    return !!this.getToken();
  }

  hasRole(role: string | string[]): boolean {
    const user = this.getCurrentUser();
    if (!user) return false;
    if (Array.isArray(role)) return role.includes(user.role);
    return user.role === role;
  }

  getAdminLevel(): string {
    return this.getCurrentUser()?.adminLevel || 'ADMIN';
  }

  hasAdminLevel(level: string | string[]): boolean {
    const adminLevel = this.getAdminLevel();
    if (Array.isArray(level)) return level.includes(adminLevel);
    return adminLevel === level;
  }
}
