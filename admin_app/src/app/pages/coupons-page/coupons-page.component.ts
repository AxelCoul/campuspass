import { Component, OnInit } from '@angular/core';
import { DatePipe } from '@angular/common';
import { CouponsService, Coupon } from '../../services/coupons.service';

@Component({
  selector: 'app-coupons-page',
  standalone: true,
  imports: [DatePipe],
  templateUrl: './coupons-page.component.html',
  styleUrl: './coupons-page.component.css'
})
export class CouponsPageComponent implements OnInit {
  coupons: Coupon[] = [];
  loading = true;

  constructor(private couponsService: CouponsService) {}

  ngOnInit(): void {
    this.couponsService.getAll().subscribe({
      next: (c) => { this.coupons = c; this.loading = false; },
      error: () => { this.loading = false; }
    });
  }
}
