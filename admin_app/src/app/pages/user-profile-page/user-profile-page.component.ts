import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { DatePipe } from '@angular/common';
import { UsersService, User } from '../../services/users.service';
import { TransactionsService, Transaction } from '../../services/transactions.service';
import { CouponsService, Coupon } from '../../services/coupons.service';

@Component({
  selector: 'app-user-profile-page',
  standalone: true,
  imports: [CommonModule, RouterLink, DatePipe],
  templateUrl: './user-profile-page.component.html',
  styleUrl: './user-profile-page.component.css'
})
export class UserProfilePageComponent implements OnInit {
  user: User | null = null;
  transactions: Transaction[] = [];
  coupons: Coupon[] = [];
  loading = true;
  actionError = '';
  actionSuccess = '';

  constructor(
    private route: ActivatedRoute,
    private usersService: UsersService,
    private transactionsService: TransactionsService,
    private couponsService: CouponsService
  ) {}

  ngOnInit(): void {
    const id = this.route.snapshot.paramMap.get('id');
    if (!id) return;
    const numId = +id;
    this.usersService.getById(numId).subscribe({
      next: (u) => {
        this.user = u;
        this.transactionsService.getAll().subscribe({
          next: (list) => { this.transactions = list.filter(t => t.userId === numId).slice(0, 20); }
        });
        this.couponsService.getAll().subscribe({
          next: (list) => { this.coupons = list.filter(c => c.userId === numId).slice(0, 20); }
        });
        this.loading = false;
      },
      error: () => { this.loading = false; }
    });
  }

  suspend(): void {
    if (!this.user) return;
    this.actionError = '';
    this.actionSuccess = '';
    this.usersService.updateStatus(this.user.id, 'SUSPENDED').subscribe({
      next: () => { this.actionSuccess = 'Compte suspendu.'; if (this.user) this.user.status = 'SUSPENDED'; },
      error: (e) => { this.actionError = e.error?.message || 'Erreur'; }
    });
  }

  reactivate(): void {
    if (!this.user) return;
    this.actionError = '';
    this.actionSuccess = '';
    this.usersService.updateStatus(this.user.id, 'ACTIVE').subscribe({
      next: () => { this.actionSuccess = 'Compte réactivé.'; if (this.user) this.user.status = 'ACTIVE'; },
      error: (e) => { this.actionError = e.error?.message || 'Erreur'; }
    });
  }
}
