import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';

export interface University {
  id: number;
  name: string;
  code?: string;
  city?: string;
  country?: string;
  active: boolean;
  createdAt?: string;
}

@Injectable({ providedIn: 'root' })
export class UniversitiesService {
  constructor(private http: HttpClient) {}

  getAll(): Observable<University[]> {
    return this.http.get<University[]>(`${environment.apiUrl}/admin/universities`);
  }

  create(body: Partial<University>): Observable<University> {
    return this.http.post<University>(`${environment.apiUrl}/admin/universities`, body);
  }

  update(id: number, body: Partial<University>): Observable<University> {
    return this.http.put<University>(`${environment.apiUrl}/admin/universities/${id}`, body);
  }

  delete(id: number): Observable<void> {
    return this.http.delete<void>(`${environment.apiUrl}/admin/universities/${id}`);
  }
}

