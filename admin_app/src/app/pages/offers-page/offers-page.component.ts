import { Component, OnInit } from '@angular/core';
import { RouterLink } from '@angular/router';
import { DatePipe, NgClass } from '@angular/common';
import { OffersService, Offer } from '../../services/offers.service';

@Component({
  selector: 'app-offers-page',
  standalone: true,
  imports: [RouterLink, DatePipe, NgClass],
  templateUrl: './offers-page.component.html',
  styleUrl: './offers-page.component.css'
})
export class OffersPageComponent implements OnInit {
  offers: Offer[] = [];
  loading = true;

  constructor(private offersService: OffersService) {}

  ngOnInit(): void {
    this.offersService.getAll().subscribe({
      next: (o) => { this.offers = o; this.loading = false; },
      error: () => { this.loading = false; }
    });
  }

  setStatus(o: Offer, status: string): void {
    this.offersService.updateStatus(o.id, status).subscribe({
      next: () => {
        o.status = status;
      }
    });
  }
}
