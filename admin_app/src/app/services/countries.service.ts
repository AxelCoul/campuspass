import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';

export interface Country {
  id: number;
  name: string;
  code: string;
  active: boolean;
  createdAt?: string;
}

@Injectable({ providedIn: 'root' })
export class CountriesService {
  constructor(private http: HttpClient) {}

  getAllAdmin(): Observable<Country[]> {
    return this.http.get<Country[]>(`${environment.apiUrl}/admin/countries`);
  }

  getAllActive(): Observable<Country[]> {
    return this.http.get<Country[]>(`${environment.apiUrl}/countries`);
  }

  create(body: Partial<Country>): Observable<Country> {
    return this.http.post<Country>(`${environment.apiUrl}/admin/countries`, body);
  }

  update(id: number, body: Partial<Country>): Observable<Country> {
    return this.http.put<Country>(`${environment.apiUrl}/admin/countries/${id}`, body);
  }

  delete(id: number): Observable<void> {
    return this.http.delete<void>(`${environment.apiUrl}/admin/countries/${id}`);
  }
}
