import { Component, OnInit } from '@angular/core';
import { DatePipe } from '@angular/common';
import { TransactionsService, Transaction } from '../../services/transactions.service';

@Component({
  selector: 'app-transactions-page',
  standalone: true,
  imports: [DatePipe],
  templateUrl: './transactions-page.component.html',
  styleUrl: './transactions-page.component.css'
})
export class TransactionsPageComponent implements OnInit {
  transactions: Transaction[] = [];
  loading = true;

  constructor(private transactionsService: TransactionsService) {}

  ngOnInit(): void {
    this.transactionsService.getAll().subscribe({
      next: (t) => { this.transactions = t; this.loading = false; },
      error: () => { this.loading = false; }
    });
  }
}
