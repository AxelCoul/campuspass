import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';

export interface Transaction {
  id: number;
  couponId: number;
  userId: number;
  merchantId: number;
  offerId: number;
  originalAmount?: number;
  discountAmount?: number;
  finalAmount?: number;
  status: string;
  transactionDate?: string;
}

@Injectable({ providedIn: 'root' })
export class TransactionsService {
  constructor(private http: HttpClient) {}

  getAll(): Observable<Transaction[]> {
    return this.http.get<Transaction[]>(`${environment.apiUrl}/admin/transactions`);
  }
}

