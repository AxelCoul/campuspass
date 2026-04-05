import { Component, OnInit } from '@angular/core';
import { CommonModule, DatePipe } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { PaymentsService, Payment, PaymentAlerts } from '../../services/payments.service';
import { AuthService } from '../../core/auth.service';

@Component({
  selector: 'app-payments-page',
  standalone: true,
  imports: [CommonModule, FormsModule, DatePipe],
  templateUrl: './payments-page.component.html',
  styleUrl: './payments-page.component.css'
})
export class PaymentsPageComponent implements OnInit {
  payments: Payment[] = [];
  filtered: Payment[] = [];
  loading = true;
  actionError = '';
  actionSuccess = '';
  filterStatus = '';
  search = '';
  recheckingId: number | null = null;
  relaunchingId: number | null = null;
  relaunchUrlByPaymentId: Record<number, string> = {};
  totalSuccess = 0;
  totalPending = 0;
  revenueFiltered = 0;
  alerts: PaymentAlerts | null = null;

  constructor(
    private paymentsService: PaymentsService,
    private authService: AuthService
  ) {}

  get canManagePayments(): boolean {
    return this.authService.hasAdminLevel('SUPER_ADMIN');
  }

  ngOnInit(): void {
    this.load();
    this.loadAlerts();
  }

  load(): void {
    this.loading = true;
    this.paymentsService.getAll().subscribe({
      next: (p) => {
        this.payments = p;
        this.applyFilters();
        this.loading = false;
      },
      error: () => { this.loading = false; }
    });
  }

  loadAlerts(): void {
    this.paymentsService.getAlerts().subscribe({
      next: (res) => { this.alerts = res; },
      error: () => {}
    });
  }

  get alertClass(): string {
    const severity = this.alerts?.severity ?? 'OK';
    if (severity === 'CRITICAL') return 'alert-critical';
    if (severity === 'WARNING') return 'alert-warning';
    return 'alert-ok';
  }

  applyFilters(): void {
    const q = this.search.trim().toLowerCase();
    this.filtered = this.payments.filter(p => {
      const statusOk = !this.filterStatus || (p.status || '').toUpperCase() === this.filterStatus;
      const haystack = `${p.id} ${p.paymentReference ?? ''} ${p.studentName ?? ''} ${p.studentEmail ?? ''} ${p.studentPhone ?? ''} ${p.planName ?? ''}`.toLowerCase();
      const searchOk = !q || haystack.includes(q);
      return statusOk && searchOk;
    });
    this.totalSuccess = this.filtered.filter(p => p.status === 'SUCCESS').length;
    this.totalPending = this.filtered.filter(p => p.status === 'PENDING').length;
    this.revenueFiltered = this.filtered
      .filter(p => p.status === 'SUCCESS')
      .reduce((sum, p) => sum + (p.amount ?? 0), 0);
  }

  onFilter(): void {
    this.applyFilters();
  }

  recheckPayment(p: Payment): void {
    this.actionError = '';
    this.actionSuccess = '';
    this.recheckingId = p.id;
    this.paymentsService.recheck(p.id).subscribe({
      next: (res) => {
        this.actionSuccess = res.message || 'Vérification terminée.';
        this.recheckingId = null;
        this.load();
        this.loadAlerts();
      },
      error: (e) => {
        this.actionError = e.error?.message || 'Erreur lors de la re-vérification.';
        this.recheckingId = null;
      }
    });
  }

  relaunchPayment(p: Payment): void {
    this.actionError = '';
    this.actionSuccess = '';
    this.relaunchingId = p.id;
    this.paymentsService.relaunch(p.id).subscribe({
      next: (res) => {
        this.actionSuccess = res.message || 'Lien de paiement regénéré.';
        const url = res.paymentUrl?.trim();
        if (url) {
          this.relaunchUrlByPaymentId[p.id] = url;
        }
        this.relaunchingId = null;
        this.load();
        this.loadAlerts();
      },
      error: (e) => {
        this.actionError = e.error?.message || 'Erreur lors de la relance.';
        this.relaunchingId = null;
      }
    });
  }

  async copyPaymentLink(p: Payment): Promise<void> {
    const url = this.relaunchUrlByPaymentId[p.id];
    if (!url) {
      this.actionError = 'Aucun lien disponible. Clique d’abord sur "Relancer paiement".';
      return;
    }
    this.actionError = '';
    try {
      await navigator.clipboard.writeText(url);
      this.actionSuccess = 'Lien copié dans le presse-papiers.';
    } catch {
      this.actionError = 'Impossible de copier automatiquement. Ouvre le lien puis copie-le.';
    }
  }

  openPaymentLink(p: Payment): void {
    const url = this.relaunchUrlByPaymentId[p.id];
    if (!url) {
      this.actionError = 'Aucun lien disponible. Clique d’abord sur "Relancer paiement".';
      return;
    }
    this.actionError = '';
    window.open(url, '_blank', 'noopener');
  }

  exportCsv(): void {
    const headers = [
      'id',
      'reference',
      'studentName',
      'studentEmail',
      'studentPhone',
      'planName',
      'amount',
      'currency',
      'paymentMethod',
      'status',
      'createdAt',
      'paidAt',
      'lastSyncedAt',
      'subscriptionEndDate',
      'hasActiveSubscription',
      'remainingDays'
    ];
    const rows = this.filtered.map(p => [
      p.id,
      p.paymentReference ?? '',
      p.studentName ?? '',
      p.studentEmail ?? '',
      p.studentPhone ?? '',
      p.planName ?? '',
      p.amount ?? '',
      p.currency ?? '',
      p.paymentMethod ?? '',
      p.status ?? '',
      p.createdAt ?? '',
      p.paidAt ?? '',
      p.lastSyncedAt ?? '',
      p.subscriptionEndDate ?? '',
      p.hasActiveSubscription ?? false,
      p.remainingDays ?? 0
    ]);

    const csv = [headers, ...rows]
      .map(row => row.map(v => `"${String(v).replace(/"/g, '""')}"`).join(','))
      .join('\n');

    const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    const date = new Date().toISOString().slice(0, 10);
    a.href = url;
    a.download = `paiements-abonnement-${date}.csv`;
    a.click();
    URL.revokeObjectURL(url);
  }
}
