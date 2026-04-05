import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { DatePipe } from '@angular/common';
import { ReviewsService, Review } from '../../services/reviews.service';
import { MerchantsService } from '../../services/merchants.service';

@Component({
  selector: 'app-reviews-page',
  standalone: true,
  imports: [CommonModule, FormsModule, DatePipe],
  templateUrl: './reviews-page.component.html',
  styleUrl: './reviews-page.component.css'
})
export class ReviewsPageComponent implements OnInit {
  reviews: Review[] = [];
  filtered: Review[] = [];
  loading = true;
  filterMerchantId: number | null = null;
  merchantOptions: { id: number; name: string }[] = [];
  actionError = '';
  actionSuccess = '';

  constructor(
    private reviewsService: ReviewsService,
    private merchantsService: MerchantsService
  ) {}

  ngOnInit(): void {
    this.loadMerchants();
    this.load();
  }

  loadMerchants(): void {
    this.merchantsService.getAll().subscribe({
      next: (list) => {
        this.merchantOptions = list.map(m => ({ id: m.id, name: m.name }));
      }
    });
  }

  load(): void {
    this.loading = true;
    this.reviewsService.getAll(this.filterMerchantId ?? undefined).subscribe({
      next: (list) => {
        this.reviews = list;
        this.filtered = list;
        this.loading = false;
      },
      error: () => { this.loading = false; }
    });
  }

  onFilter(): void {
    this.load();
  }

  hideReview(r: Review): void {
    this.actionError = '';
    this.actionSuccess = '';
    this.reviewsService.updateStatus(r.id, 'HIDDEN').subscribe({
      next: () => { this.actionSuccess = 'Avis masqué.'; this.load(); },
      error: (e) => { this.actionError = e.error?.message || 'Erreur'; }
    });
  }

  showReview(r: Review): void {
    this.actionError = '';
    this.actionSuccess = '';
    this.reviewsService.updateStatus(r.id, 'VISIBLE').subscribe({
      next: () => { this.actionSuccess = 'Avis visible.'; this.load(); },
      error: (e) => { this.actionError = e.error?.message || 'Erreur'; }
    });
  }
}
