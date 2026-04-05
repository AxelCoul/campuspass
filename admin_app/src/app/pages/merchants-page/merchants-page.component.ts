import { Component, OnInit } from '@angular/core';
import { RouterLink } from '@angular/router';
import { DatePipe } from '@angular/common';
import { MerchantsService, Merchant } from '../../services/merchants.service';
import { environment } from '../../../environments/environment';

@Component({
  selector: 'app-merchants-page',
  standalone: true,
  imports: [RouterLink, DatePipe],
  templateUrl: './merchants-page.component.html',
  styleUrl: './merchants-page.component.css'
})
export class MerchantsPageComponent implements OnInit {
  merchants: Merchant[] = [];
  loading = true;

  constructor(private merchantsService: MerchantsService) {}

  ngOnInit(): void {
    this.merchantsService.getAll().subscribe({
      next: (m) => { this.merchants = m; this.loading = false; },
      error: () => { this.loading = false; }
    });
  }

  approve(m: Merchant): void {
    this.merchantsService.approve(m.id).subscribe({
      next: (updated) => {
        m.status = updated.status;
      }
    });
  }

  reject(m: Merchant): void {
    if (!confirm(`Rejeter le commerce « ${m.name} » ?`)) return;
    this.merchantsService.reject(m.id).subscribe({
      next: () => {
        m.status = 'REJECTED';
      }
    });
  }

  /** URL absolue pour afficher logo / couverture (fichiers relatifs uploadés côté API). */
  resolveImageUrl(m: Merchant): string {
    const raw = (m.coverImage || m.logoUrl || '').trim();
    if (!raw) return '';
    if (raw.startsWith('http')) return raw;
    const serverBase = environment.apiUrl.replace(/\/api$/, '');
    const path = raw.startsWith('/') ? raw : `/${raw}`;
    return `${serverBase}${path}`;
  }

  hasImage(m: Merchant): boolean {
    return !!this.resolveImageUrl(m);
  }
}
