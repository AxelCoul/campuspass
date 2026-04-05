import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';

export interface Category {
  id: number;
  name: string;
  icon?: string;
  description?: string;
  createdAt?: string;
}

@Injectable({ providedIn: 'root' })
export class CategoriesService {
  constructor(private http: HttpClient) {}

  getAll(): Observable<Category[]> {
    return this.http.get<Category[]>(`${environment.apiUrl}/categories`);
  }

  create(body: { name: string; icon?: string; description?: string }): Observable<Category> {
    return this.http.post<Category>(`${environment.apiUrl}/admin/categories`, body);
  }

  update(id: number, body: Partial<Category>): Observable<Category> {
    return this.http.put<Category>(`${environment.apiUrl}/admin/categories/${id}`, body);
  }

  delete(id: number): Observable<void> {
    return this.http.delete<void>(`${environment.apiUrl}/admin/categories/${id}`);
  }
}
