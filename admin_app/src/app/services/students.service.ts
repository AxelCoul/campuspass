import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';

export interface Student {
  id: number;
  firstName: string;
  lastName: string;
  email: string;
  university?: string;
  city?: string;
  country?: string;
  couponsUsed?: number;
  status?: string;
  cardVerified?: boolean;
  /** Numéro de carte / matricule transmis par l'étudiant. */
  studentCardNumber?: string;
  /** Type de document fourni (STUDENT_CARD, ENROLLMENT_CERTIFICATE...). */
  verificationDocumentType?: string;
  /** URL de la photo de la carte / attestation. */
  studentCardImage?: string;
  /** Date de dernière vérification côté admin. */
  verificationDate?: string;
  verificationStatus?: 'NONE' | 'PENDING' | 'APPROVED' | 'REJECTED';
  verificationRejectionReason?: string;
  createdAt?: string;
}

@Injectable({ providedIn: 'root' })
export class StudentsService {
  constructor(private http: HttpClient) {}

  getAll(): Observable<Student[]> {
    return this.http.get<Student[]>(`${environment.apiUrl}/admin/students`);
  }

  updateStatus(id: number, status: string): Observable<void> {
    return this.http.patch<void>(`${environment.apiUrl}/admin/users/${id}/status`, { status });
  }

  validateCard(id: number): Observable<void> {
    return this.http.patch<void>(`${environment.apiUrl}/admin/students/${id}/validate-card`, {});
  }

  rejectCard(id: number, reason: string): Observable<void> {
    return this.http.patch<void>(`${environment.apiUrl}/admin/students/${id}/reject-card`, { reason });
  }
}
