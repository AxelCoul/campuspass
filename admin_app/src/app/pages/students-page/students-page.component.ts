import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RouterLink } from '@angular/router';
import { DatePipe } from '@angular/common';
import { environment } from '../../../environments/environment';
import { StudentsService, Student } from '../../services/students.service';

@Component({
  selector: 'app-students-page',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterLink, DatePipe],
  templateUrl: './students-page.component.html',
  styleUrl: './students-page.component.css'
})
export class StudentsPageComponent implements OnInit {
  students: Student[] = [];
  filtered: Student[] = [];
  loading = true;
  filterCity = '';
  filterUniversity = '';
  filterStatus = '';
  actionError = '';
  actionSuccess = '';
  rejectModalOpen = false;
  rejectReason = '';
  rejectSubmitting = false;
  selectedStudent: Student | null = null;
  private backendBaseUrl = environment.apiUrl.replace(/\/api\/?$/, '');

  constructor(private studentsService: StudentsService) {}

  ngOnInit(): void {
    this.load();
  }

  load(): void {
    this.loading = true;
    this.studentsService.getAll().subscribe({
      next: (list) => {
        this.students = list;
        this.applyFilters();
        this.loading = false;
      },
      error: () => { this.loading = false; }
    });
  }

  applyFilters(): void {
    this.filtered = this.students.filter(s => {
      const cityOk = !this.filterCity || (s.city || '').toLowerCase().includes(this.filterCity.toLowerCase());
      const univOk = !this.filterUniversity || (s.university || '').toLowerCase().includes(this.filterUniversity.toLowerCase());
      const statusOk = !this.filterStatus || (s.status || 'ACTIVE') === this.filterStatus;
      return cityOk && univOk && statusOk;
    });
  }

  onFilter(): void {
    this.applyFilters();
  }

  suspend(s: Student): void {
    this.actionError = '';
    this.actionSuccess = '';
    this.studentsService.updateStatus(s.id, 'SUSPENDED').subscribe({
      next: () => { this.actionSuccess = 'Compte suspendu.'; this.load(); },
      error: (e) => { this.actionError = e.error?.message || 'Erreur'; }
    });
  }

  reactivate(s: Student): void {
    this.actionError = '';
    this.actionSuccess = '';
    this.studentsService.updateStatus(s.id, 'ACTIVE').subscribe({
      next: () => { this.actionSuccess = 'Compte réactivé.'; this.load(); },
      error: (e) => { this.actionError = e.error?.message || 'Erreur'; }
    });
  }

  validateCard(s: Student): void {
    this.actionError = '';
    this.actionSuccess = '';
    this.studentsService.validateCard(s.id).subscribe({
      next: () => { this.actionSuccess = 'Carte étudiante validée.'; this.load(); },
      error: (e) => { this.actionError = e.error?.message || 'Erreur'; }
    });
  }

  openRejectModal(s: Student): void {
    this.selectedStudent = s;
    // Pré-remplit un motif clair basé sur les champs manquants.
    this.rejectReason = this.suggestionsRejectReason(s);
    this.rejectModalOpen = true;
  }

  closeRejectModal(): void {
    if (this.rejectSubmitting) return;
    this.rejectModalOpen = false;
    this.selectedStudent = null;
    this.rejectReason = '';
  }

  confirmRejectCard(): void {
    this.actionError = '';
    this.actionSuccess = '';
    const s = this.selectedStudent;
    if (!s) return;
    if (!this.rejectReason.trim()) {
      return;
    }
    this.rejectSubmitting = true;
    this.studentsService.rejectCard(s.id, this.rejectReason.trim()).subscribe({
      next: () => {
        this.actionSuccess = 'Demande rejetée.';
        this.rejectSubmitting = false;
        this.closeRejectModal();
        this.load();
      },
      error: (e) => {
        this.actionError = e.error?.message || 'Erreur';
        this.rejectSubmitting = false;
      }
    });
  }

  resolveFileUrl(pathOrUrl: string | undefined | null): string {
    if (!pathOrUrl) return '';
    if (pathOrUrl.startsWith('http://') || pathOrUrl.startsWith('https://')) {
      return pathOrUrl;
    }
    // Le backend renvoie souvent des chemins du type "/uploads/...".
    // On les transforme en URL absolue vers le backend.
    const path = pathOrUrl.startsWith('/') ? pathOrUrl : `/${pathOrUrl}`;
    return `${this.backendBaseUrl}${path}`;
  }

  missingFields(s: Student | null): string[] {
    if (!s) return [];
    const missing: string[] = [];

    if (!s.studentCardImage) missing.push('Photo de la carte');
    if (!s.studentCardNumber) missing.push('Matricule / numéro carte');
    if (!s.university || !s.university.trim()) missing.push('Université');
    if (!s.city || !s.city.trim()) missing.push('Ville');
    if (!s.country || !s.country.trim()) missing.push('Pays');
    if (!s.verificationDocumentType || !s.verificationDocumentType.trim()) missing.push('Type de document');

    return missing;
  }

  suggestionsRejectReason(s: Student | null): string {
    const missing = this.missingFields(s);
    if (!s) return '';
    if (missing.length === 0) {
      return 'Demande rejetée.\n- Le document ne correspond pas / illisible.\n- Merci de soumettre une nouvelle pièce conforme.';
    }

    return [
      'Demande rejetée. Éléments manquants / non conformes :',
      ...missing.map((m) => `- ${m}`),
      'Merci de soumettre à nouveau un document complet et lisible.',
    ].join('\n');
  }

  hasVerificationRequest(s: Student | null): boolean {
    if (!s) return false;
    return !!(s.studentCardNumber || s.studentCardImage || s.verificationDocumentType || s.university);
  }

  missingCount(s: Student | null): number {
    return this.missingFields(s).length;
  }
}
