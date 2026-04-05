import { Component } from '@angular/core';
import { RouterLink, RouterLinkActive, RouterOutlet } from '@angular/router';
import { AuthService } from '../../core/auth.service';
import { PaymentsService, PaymentAlerts } from '../../services/payments.service';

@Component({
  selector: 'app-admin-layout',
  standalone: true,
  imports: [RouterLink, RouterLinkActive, RouterOutlet],
  templateUrl: './admin-layout.component.html',
  styleUrl: './admin-layout.component.css'
})
export class AdminLayoutComponent {
  paymentAlerts: PaymentAlerts | null = null;

  constructor(
    public auth: AuthService,
    private paymentsService: PaymentsService
  ) {
    this.loadPaymentAlerts();
  }

  logout(): void {
    this.auth.logout();
  }

  private loadPaymentAlerts(): void {
    this.paymentsService.getAlerts().subscribe({
      next: (res) => { this.paymentAlerts = res; },
      error: () => {}
    });
  }
}
