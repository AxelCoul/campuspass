import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';

export interface LogEntry {
  id: number;
  userId: number;
  email?: string;
  loginAt?: string;
  ipAddress?: string;
  device?: string;
}

@Injectable({ providedIn: 'root' })
export class LogsService {
  constructor(private http: HttpClient) {}

  getLogs(limit = 100): Observable<LogEntry[]> {
    return this.http.get<LogEntry[]>(`${environment.apiUrl}/admin/logs`, { params: { limit: limit.toString() } });
  }
}
