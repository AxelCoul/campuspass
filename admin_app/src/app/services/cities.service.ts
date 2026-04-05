import { Injectable } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';

export interface City {
  id: number;
  name: string;
  countryId: number;
  active: boolean;
  createdAt?: string;
}

@Injectable({ providedIn: 'root' })
export class CitiesService {
  constructor(private http: HttpClient) {}

  getAllAdmin(): Observable<City[]> {
    return this.http.get<City[]>(`${environment.apiUrl}/admin/cities`);
  }

  getAllActive(params?: { countryId?: number }): Observable<City[]> {
    let p = new HttpParams();
    if (params?.countryId != null) p = p.set('countryId', params.countryId);
    return this.http.get<City[]>(`${environment.apiUrl}/cities`, { params: p });
  }

  create(body: Partial<City>): Observable<City> {
    return this.http.post<City>(`${environment.apiUrl}/admin/cities`, body);
  }

  update(id: number, body: Partial<City>): Observable<City> {
    return this.http.put<City>(`${environment.apiUrl}/admin/cities/${id}`, body);
  }

  delete(id: number): Observable<void> {
    return this.http.delete<void>(`${environment.apiUrl}/admin/cities/${id}`);
  }
}
