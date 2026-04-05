import { Component, OnDestroy, OnInit } from '@angular/core';
import { ActivatedRoute, Router, RouterLink } from '@angular/router';
import { FormsModule } from '@angular/forms';
import { OffersService, OfferRequest } from '../../services/offers.service';
import { MerchantsService } from '../../services/merchants.service';
import { CategoriesService } from '../../services/categories.service';
import { UniversitiesService, University } from '../../services/universities.service';
import { environment } from '../../../environments/environment';
import { AuthService } from '../../core/auth.service';

@Component({
  selector: 'app-offer-form-page',
  standalone: true,
  imports: [FormsModule, RouterLink],
  templateUrl: './offer-form-page.component.html',
  styleUrl: './offer-form-page.component.css'
})
export class OfferFormPageComponent implements OnInit, OnDestroy {
  merchants: { id: number; name: string }[] = [];
  categories: { id: number; name: string }[] = [];
  universities: University[] = [];
  selectedUniversityNames: string[] = [];
  /** `from_prices` : prix initial + final → % calculé. `percent_only` : uniquement le %, pas de prix sur la carte. */
  pricingMode: 'from_prices' | 'percent_only' = 'from_prices';
  model = {
    merchantId: 0,
    categoryId: undefined as number | undefined,
    title: '',
    description: '',
    imageUrl: '' as string | undefined,
    imageUrls: [] as string[],
    originalPrice: undefined as number | undefined,
    discountPercentage: undefined as number | undefined,
    finalPrice: undefined as number | undefined,
    startDate: '',
    endDate: '',
    maxCoupons: 0,
    maxPassesPerDayPerUser: undefined as number | undefined,
    maxQuantityPerPass: undefined as number | undefined,
    targetUniversities: '',
  };
  loading = false;
  error = '';
  success = '';
  isEdit = false;
  offerId?: number;
  /** Aperçu immédiat du fichier image choisi (avant fin d’upload) */
  imageLocalPreviews: string[] = [];
  private _imageObjectUrls: string[] = [];
  activeImageIndex = 0;

  /** URL affichée dans l’aperçu (fichier local ou image serveur). */
  get imageDisplaySrc(): string {
    const list = this.imagePreviewList;
    if (list.length === 0) return '';
    const idx = Math.min(this.activeImageIndex, list.length - 1);
    return list[idx];
  }

  get imagePreviewList(): string[] {
    if (this.imageLocalPreviews.length > 0) return this.imageLocalPreviews;
    if (this.model.imageUrls?.length) return this.model.imageUrls;
    if (this.model.imageUrl) return [this.model.imageUrl];
    return [];
  }

  private _clearLocalImagePreview(): void {
    for (const u of this._imageObjectUrls) {
      try {
        URL.revokeObjectURL(u);
      } catch (_) {}
    }
    this._imageObjectUrls = [];
    this.imageLocalPreviews = [];
    this.activeImageIndex = 0;
  }

  ngOnDestroy(): void {
    this._clearLocalImagePreview();
  }

  private _resolveUploadUrl(url?: string): string {
    if (!url) return '';
    if (url.startsWith('http')) return url;
    const serverBase = environment.apiUrl.replace(/\/api$/, '');
    const path = url.startsWith('/') ? url : `/${url}`;
    return `${serverBase}${path}`;
  }

  private _normalizeForSave(url?: string): string | undefined {
    if (!url) return undefined;
    const trimmed = url.trim();
    if (!trimmed) return undefined;
    const serverBase = environment.apiUrl.replace(/\/api$/, '');
    if (trimmed.startsWith(serverBase)) {
      const relative = trimmed.substring(serverBase.length);
      return relative.startsWith('/') ? relative : `/${relative}`;
    }
    return trimmed;
  }

  constructor(
    private route: ActivatedRoute,
    private offersService: OffersService,
    private merchantsService: MerchantsService,
    private categoriesService: CategoriesService,
    private universitiesService: UniversitiesService,
    private auth: AuthService,
    private router: Router
  ) {}

  ngOnInit(): void {
    this.merchantsService.getAll().subscribe((m) => {
      this.merchants = m.map(x => ({ id: x.id, name: x.name }));
      if (this.merchants.length) this.model.merchantId = this.merchants[0].id;
    });
    this.categoriesService.getAll().subscribe((c) => {
      this.categories = c.map(x => ({ id: x.id, name: x.name }));
    });
    this.universitiesService.getAll().subscribe({
      next: (list) => {
        this.universities = list.filter(u => u.active);
      },
      error: () => {
        this.universities = [];
      }
    });
    const id = this.route.snapshot.paramMap.get('id');
    if (id) {
      this.offerId = Number(id);
      this.isEdit = true;
      this.offersService.getById(this.offerId).subscribe({
        next: (o) => {
          this.model.merchantId = o.merchantId;
          this.model.categoryId = o.categoryId;
          this.model.title = o.title;
          this.model.description = o.description ?? '';
          const resolvedSingle = this._resolveUploadUrl(o.imageUrl ?? '');
          const resolvedList = o.imageUrls
            ? o.imageUrls.map((u: string) => this._resolveUploadUrl(u))
            : (resolvedSingle ? [resolvedSingle] : []);
          this.model.imageUrls = resolvedList;
          this.model.imageUrl = resolvedList[0] ?? undefined;
          this.model.originalPrice = o.originalPrice;
          this.model.discountPercentage = o.discountPercentage;
          this.model.finalPrice = o.finalPrice;
          this.model.startDate = o.startDate ? o.startDate.toString().slice(0, 10) : '';
          this.model.endDate = o.endDate ? o.endDate.toString().slice(0, 10) : '';
          this.model.maxCoupons = o.maxCoupons ?? 0;
          this.model.maxPassesPerDayPerUser = o.maxPassesPerDayPerUser;
          this.model.maxQuantityPerPass = o.maxQuantityPerPass;
          this.model.targetUniversities = o.targetUniversities ?? '';
          this.selectedUniversityNames = this.parseUniversitiesCsv(this.model.targetUniversities);
          this.applyPricingModeFromOffer(o);
        }
      });
    }
  }

  /** Déduit le mode à partir des données chargées (édition). */
  private applyPricingModeFromOffer(o: {
    originalPrice?: number | null;
    finalPrice?: number | null;
    discountPercentage?: number | null;
  }): void {
    const hasBothPrices =
      o.originalPrice != null &&
      o.finalPrice != null &&
      o.originalPrice > 0;
    if (hasBothPrices) {
      this.pricingMode = 'from_prices';
      this.recalculatePercentFromPrices();
      return;
    }
    if (o.discountPercentage != null && o.discountPercentage > 0) {
      this.pricingMode = 'percent_only';
    }
  }

  onPricingModeChange(): void {
    if (this.pricingMode === 'percent_only') {
      this.model.originalPrice = undefined;
      this.model.finalPrice = undefined;
    } else {
      this.recalculatePercentFromPrices();
    }
  }

  /** Choix 1 : % = (prix initial − prix final) / prix initial × 100 */
  recalculatePercentFromPrices(): void {
    const o = this.model.originalPrice;
    const f = this.model.finalPrice;
    if (o != null && f != null && o > 0 && f <= o) {
      const pct = Math.round(((o - f) / o) * 10000) / 100;
      this.model.discountPercentage = pct;
    } else if (o != null && f != null && o > 0 && f > o) {
      this.model.discountPercentage = 0;
    }
  }

  submit(): void {
    this.error = '';
    this.success = '';
    this.loading = true;
    if (this.pricingMode === 'from_prices') {
      this.recalculatePercentFromPrices();
    }
    const normalizedImageUrls = (this.model.imageUrls ?? [])
      .map((u) => this._normalizeForSave(u))
      .filter((x): x is string => !!x);

    const body: OfferRequest = {
      merchantId: this.model.merchantId,
      categoryId: this.model.categoryId ?? undefined,
      title: this.model.title,
      description: this.model.description,
      originalPrice: this.model.originalPrice,
      discountPercentage: this.model.discountPercentage,
      finalPrice: this.model.finalPrice,
      startDate: this.model.startDate || undefined,
      endDate: this.model.endDate || undefined,
      maxCoupons: this.model.maxCoupons ?? undefined,
      maxPassesPerDayPerUser: this.model.maxPassesPerDayPerUser || undefined,
      maxQuantityPerPass: this.model.maxQuantityPerPass || undefined,
      targetUniversities:
        this.selectedUniversityNames.length > 0
          ? this.selectedUniversityNames.join(', ')
          : undefined,
      imageUrl: normalizedImageUrls[0] ?? this._normalizeForSave(this.model.imageUrl),
      imageUrls: normalizedImageUrls.length > 0 ? normalizedImageUrls : undefined,
    };
    if (this.pricingMode === 'percent_only') {
      body.originalPrice = null;
      body.finalPrice = null;
    }
    (this.isEdit && this.offerId
      ? this.offersService.update(this.offerId, body)
      : this.offersService.create(body)
    ).subscribe({
      next: () => {
        this.loading = false;
        if (this.isEdit) {
          this.success = 'Offre mise à jour.';
        } else {
          this.router.navigate(['/admin/offers']);
        }
      },
      error: (e) => { this.error = e?.error?.message || 'Erreur'; this.loading = false; }
    });
  }

  async onImageSelected(event: Event): Promise<void> {
    const input = event.target as HTMLInputElement;
    if (!input.files || input.files.length === 0) return;

    const files = Array.from(input.files).slice(0, 3);
    this._clearLocalImagePreview();
    this.model.imageUrls = [];
    this.model.imageUrl = undefined;
    this.activeImageIndex = 0;
    this.error = '';
    this.success = '';

    this.loading = true;
    try {
      const token = this.auth.getToken();
      const headers: Record<string, string> = {};
      if (token) headers['Authorization'] = `Bearer ${token}`;

      for (let i = 0; i < files.length; i++) {
        const file = files[i];
        const localUrl = URL.createObjectURL(file);
        this.imageLocalPreviews.push(localUrl);
        this._imageObjectUrls.push(localUrl);

        const formData = new FormData();
        formData.append('file', file);
        const res = await fetch(`${environment.apiUrl}/upload/offer-image`, {
          method: 'POST',
          body: formData,
          headers,
        });
        if (!res.ok) throw new Error('Upload échoué');
        const data = await res.json() as { url?: string };
        if (!data.url) throw new Error('Réponse upload invalide');

        const resolved = this._resolveUploadUrl(data.url);
        this.model.imageUrls.push(resolved);
        if (i === 0) this.model.imageUrl = resolved;
      }
    } catch (e) {
      this.error = (e as Error).message || 'Erreur lors de l\'upload de l\'image.';
    } finally {
      this.loading = false;
    }
  }

  isUniversitySelected(name: string): boolean {
    return this.selectedUniversityNames.some(n => n.toLowerCase() === name.toLowerCase());
  }

  toggleUniversity(name: string, checked: boolean): void {
    const exists = this.isUniversitySelected(name);
    if (checked && !exists) {
      this.selectedUniversityNames = [...this.selectedUniversityNames, name];
    } else if (!checked && exists) {
      this.selectedUniversityNames = this.selectedUniversityNames
        .filter(n => n.toLowerCase() !== name.toLowerCase());
    }
    this.model.targetUniversities = this.selectedUniversityNames.join(', ');
  }

  private parseUniversitiesCsv(csv: string): string[] {
    if (!csv || !csv.trim()) return [];
    return csv
      .split(',')
      .map(x => x.trim())
      .filter(x => x.length > 0);
  }
}
