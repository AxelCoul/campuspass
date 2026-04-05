import { Component, OnDestroy, OnInit } from '@angular/core';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { CommonModule, DatePipe } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { MerchantsService, Merchant } from '../../services/merchants.service';
import { CategoriesService, Category } from '../../services/categories.service';
import { OffersService, Offer } from '../../services/offers.service';
import { TransactionsService, Transaction } from '../../services/transactions.service';
import { ReviewsService, Review } from '../../services/reviews.service';
import { CountriesService, Country } from '../../services/countries.service';
import { CitiesService, City } from '../../services/cities.service';
import { environment } from '../../../environments/environment';

@Component({
  selector: 'app-merchant-detail-page',
  standalone: true,
  imports: [CommonModule, RouterLink, DatePipe, FormsModule],
  templateUrl: './merchant-detail-page.component.html',
  styleUrl: './merchant-detail-page.component.css'
})
export class MerchantDetailPageComponent implements OnInit, OnDestroy {
  merchant: Merchant | null = null;
  loading = true;
  savingLocation = false;
  saveMessage = '';
  email = '';
  phone = '';
  pendingLogoUrl: string | null = null;
  lat: number | null = null;
  lng: number | null = null;
  address = '';
  city = '';
  country = '';
  openingHours = '';
  categories: Category[] = [];
  countries: Country[] = [];
  cities: City[] = [];
  filteredCities: City[] = [];
  categoryId: number | null = null;
  offers: Offer[] = [];
  offersLoading = true;
  transactions: Transaction[] = [];
  transactionsLoading = true;
  reviews: Review[] = [];
  reviewsLoading = true;
  uploadingLogo = false;
  logoError = '';
  /** Aperçu local pendant la sélection / upload du logo */
  private _logoObjectUrl: string | null = null;
  logoLocalPreview: string | null = null;

  /** URL affichée pour le logo (aperçu fichier ou image enregistrée). */
  get logoDisplaySrc(): string | null {
    if (this.logoLocalPreview) return this.logoLocalPreview;
    const raw = this.merchant?.logoUrl;
    if (!raw) return null;
    return this._resolveUploadUrl(raw);
  }

  private _resolveUploadUrl(url: string): string {
    if (!url) return '';
    if (url.startsWith('http')) return url;
    const serverBase = environment.apiUrl.replace(/\/api$/, '');
    const path = url.startsWith('/') ? url : `/${url}`;
    return `${serverBase}${path}`;
  }

  private _clearLogoLocalPreview(): void {
    if (this._logoObjectUrl) {
      URL.revokeObjectURL(this._logoObjectUrl);
    }
    this._logoObjectUrl = null;
    this.logoLocalPreview = null;
  }

  ngOnDestroy(): void {
    this._clearLogoLocalPreview();
  }

  constructor(
    private route: ActivatedRoute,
    private merchantsService: MerchantsService,
    private categoriesService: CategoriesService,
    private countriesService: CountriesService,
    private citiesService: CitiesService,
    private offersService: OffersService,
    private transactionsService: TransactionsService,
    private reviewsService: ReviewsService
  ) {}

  ngOnInit(): void {
    const id = Number(this.route.snapshot.paramMap.get('id'));
    this.countriesService.getAllActive().subscribe({
      next: (list) => this.countries = list,
      error: () => this.countries = [],
    });
    this.citiesService.getAllActive().subscribe({
      next: (list) => {
        this.cities = list;
        this.onCountryChanged();
      },
      error: () => {
        this.cities = [];
        this.filteredCities = [];
      },
    });
    this.categoriesService.getAll().subscribe({
      next: (c) => { this.categories = c; },
      error: () => { this.categories = []; }
    });
    this.merchantsService.getById(id).subscribe({
      next: (m) => {
        this.merchant = m;
        this.email = m.email ?? '';
        this.phone = m.phone ?? '';
        this.lat = m.latitude ?? null;
        this.lng = m.longitude ?? null;
        this.address = m.address ?? '';
        this.city = m.city ?? '';
        this.country = m.country ?? '';
        this.onCountryChanged();
        this.openingHours = m.openingHours ?? '';
        this.categoryId = m.categoryId ?? null;
        this.loading = false;
        this.loadOffers(m.id);
        this.loadTransactions(m.id);
        this.loadReviews(m.id);
      },
      error: () => { this.loading = false; }
    });
  }

  saveLocation(): void {
    if (!this.merchant) return;
    this.saveMessage = '';
    this.savingLocation = true;
    this.merchantsService.update(this.merchant.id, {
      name: this.merchant.name,
      email: this.email || undefined,
      phone: this.phone || undefined,
      logoUrl: (this.pendingLogoUrl ?? this.merchant.logoUrl) || undefined,
      latitude: this.lat ?? undefined,
      longitude: this.lng ?? undefined,
      address: this.address || undefined,
      city: this.city || undefined,
      country: this.country || undefined,
      openingHours: this.openingHours || undefined,
      categoryId: this.categoryId ?? undefined,
    }).subscribe({
      next: (updated) => {
        this.merchant = updated;
        this.savingLocation = false;
        this.saveMessage = 'Enregistrement réussi.';
      },
      error: () => {
        this.savingLocation = false;
        this.saveMessage = 'Erreur lors de l\'enregistrement.';
      }
    });
  }

  loadOffers(merchantId: number): void {
    this.offersLoading = true;
    this.offersService.getAll({ merchantId }).subscribe({
      next: (list) => {
        this.offers = list;
        this.offersLoading = false;
      },
      error: () => {
        this.offers = [];
        this.offersLoading = false;
      }
    });
  }

  loadTransactions(merchantId: number): void {
    this.transactionsLoading = true;
    this.transactionsService.getAll().subscribe({
      next: (list) => {
        this.transactions = list.filter(t => t.merchantId === merchantId);
        this.transactionsLoading = false;
      },
      error: () => {
        this.transactions = [];
        this.transactionsLoading = false;
      }
    });
  }

  loadReviews(merchantId: number): void {
    this.reviewsLoading = true;
    this.reviewsService.getAll(merchantId).subscribe({
      next: (list) => {
        this.reviews = list;
        this.reviewsLoading = false;
      },
      error: () => {
        this.reviews = [];
        this.reviewsLoading = false;
      }
    });
  }

  async onLogoSelected(event: Event): Promise<void> {
    if (!this.merchant) return;
    const input = event.target as HTMLInputElement;
    if (!input.files || input.files.length === 0) {
      return;
    }
    const file = input.files[0];
    this._clearLogoLocalPreview();
    this._logoObjectUrl = URL.createObjectURL(file);
    this.logoLocalPreview = this._logoObjectUrl;

    const formData = new FormData();
    formData.append('file', file);
    this.uploadingLogo = true;
    this.logoError = '';
    try {
      const token = localStorage.getItem('admin_token');
      const headers: Record<string, string> = {};
      if (token) {
        headers['Authorization'] = `Bearer ${token}`;
      }
      const res = await fetch(`${environment.apiUrl}/upload/offer-image`, {
        method: 'POST',
        body: formData,
        headers,
      });
      if (!res.ok) {
        throw new Error('Upload échoué');
      }
      const data = await res.json() as { url?: string };
      if (!data.url) {
        throw new Error('Réponse upload invalide');
      }
      // On stocke juste l'URL pour l'enregistrer avec le bouton global
      this.pendingLogoUrl = data.url;
      this.merchant = { ...this.merchant, logoUrl: data.url };
      this._clearLogoLocalPreview();
      this.uploadingLogo = false;
    } catch (e) {
      this.uploadingLogo = false;
      this.logoError = (e as Error).message || 'Erreur lors de l\'upload du logo.';
    }
  }

  onCountryChanged(): void {
    const selectedCountry = this.country?.trim();
    const selected = this.countries.find(c => c.name === selectedCountry);
    if (!selected) {
      this.filteredCities = this.cities;
      return;
    }
    this.filteredCities = this.cities.filter(city => city.countryId === selected.id);
    if (this.city && !this.filteredCities.some(c => c.name === this.city)) {
      this.city = '';
    }
  }
}
