import { Component, OnDestroy, OnInit } from '@angular/core';
import { CommonModule, DecimalPipe } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { AdvertisementsService, Advertisement, AdvertisementRequest } from '../../services/advertisements.service';
import { MerchantsService } from '../../services/merchants.service';
import { OffersService, Offer } from '../../services/offers.service';
import { CountriesService, Country } from '../../services/countries.service';
import { CitiesService, City } from '../../services/cities.service';
import { UniversitiesService, University } from '../../services/universities.service';
import { environment } from '../../../environments/environment';
import { AuthService } from '../../core/auth.service';

@Component({
  selector: 'app-advertisements-page',
  standalone: true,
  imports: [CommonModule, FormsModule, DecimalPipe],
  templateUrl: './advertisements-page.component.html',
  styleUrl: './advertisements-page.component.css'
})
export class AdvertisementsPageComponent implements OnInit, OnDestroy {
  ads: Advertisement[] = [];
  merchants: { id: number; name: string }[] = [];
  merchantOffers: Offer[] = [];
  countries: Country[] = [];
  cities: City[] = [];
  filteredCities: City[] = [];
  universities: University[] = [];
  loading = true;
  showForm = false;
  submitting = false;
  error = '';
  editingAd: Advertisement | null = null;
  videoPreviewUrl: string | null = null; // URL locale (avant upload)
  videoUploadProgress = 0; // 0..100
  private _videoObjectUrl: string | null = null;
  /** Aperçu image local (fichier choisi, avant/après upload) */
  imageLocalPreview: string | null = null;
  private _imageObjectUrl: string | null = null;
  form: Omit<AdvertisementRequest, 'merchantId'> & { merchantId: number | null } = {
    merchantId: null,
    title: '',
    description: '',
    ctaLabel: '',
    imageUrl: '',
    videoUrl: '',
    targetUrl: '',
    targetCity: '',
    targetCountry: '',
    targetUniversity: '',
    targetSegment: 'ALL',
    position: 'HOME_BANNER',
    startDate: '',
    endDate: '',
    budget: undefined,
    offerId: undefined
  };

  private _resolveUploadUrl(url?: string): string {
    if (!url) return '';
    if (url.startsWith('http')) return url;
    const serverBase = environment.apiUrl.replace(/\/api$/, '');
    const path = url.startsWith('/') ? url : `/${url}`;
    return `${serverBase}${path}`;
  }

  constructor(
    private adsService: AdvertisementsService,
    private merchantsService: MerchantsService,
    private offersService: OffersService,
    private countriesService: CountriesService,
    private citiesService: CitiesService,
    private universitiesService: UniversitiesService,
    private auth: AuthService
  ) {}

  ngOnInit(): void {
    this.loadAds();
    this.countriesService.getAllActive().subscribe({
      next: (list) => this.countries = list,
      error: () => this.countries = [],
    });
    this.citiesService.getAllActive().subscribe({
      next: (list) => {
        this.cities = list;
        this.onTargetCountryChanged();
      },
      error: () => {
        this.cities = [];
        this.filteredCities = [];
      },
    });
    this.universitiesService.getAll().subscribe({
      next: (list) => this.universities = list.filter(u => u.active),
      error: () => this.universities = [],
    });
    this.merchantsService.getAll().subscribe({
      next: (m) => this.merchants = m.map(x => ({ id: x.id, name: x.name || `Commerce #${x.id}` }))
    });
  }

  loadAds(): void {
    this.loading = true;
    this.adsService.getAll({ position: 'HOME_BANNER' }).subscribe({
      next: (a) => { this.ads = a; this.loading = false; },
      error: () => { this.loading = false; }
    });
  }

  openCreate(): void {
    this.editingAd = null;
    this.showForm = true;
    this.error = '';
    this._clearVideoPreview();
    this._clearImagePreview();
    this.form = {
      merchantId: this.merchants[0]?.id ?? null,
      title: '',
      description: '',
      ctaLabel: '',
      imageUrl: '',
      videoUrl: '',
      targetUrl: '',
      targetCity: '',
      targetCountry: '',
      targetUniversity: '',
      targetSegment: 'ALL',
      position: 'HOME_BANNER',
      startDate: '',
      endDate: '',
      budget: undefined,
      offerId: undefined
    };
    this.onTargetCountryChanged();
    this.loadMerchantOffers();
  }

  openEdit(a: Advertisement): void {
    this.editingAd = a;
    this.showForm = true;
    this.error = '';
    this._clearVideoPreview();
    this._clearImagePreview();
    this.form = {
      merchantId: a.merchantId,
      title: a.title ?? '',
      description: a.description ?? '',
      ctaLabel: a.ctaLabel ?? '',
      imageUrl: this._resolveUploadUrl(a.imageUrl ?? ''),
      videoUrl: this._resolveUploadUrl(a.videoUrl ?? ''),
      targetUrl: a.targetUrl ?? '',
      targetCity: a.targetCity ?? '',
      targetCountry: a.targetCountry ?? '',
      targetUniversity: a.targetUniversity ?? '',
      targetSegment: a.targetSegment ?? 'ALL',
      position: 'HOME_BANNER',
      startDate: a.startDate?.toString().substring(0, 10) ?? '',
      endDate: a.endDate?.toString().substring(0, 10) ?? '',
      budget: a.budget,
      offerId: a.offerId ?? undefined
    };
    this.onTargetCountryChanged();
    this.loadMerchantOffers();
  }

  loadMerchantOffers(): void {
    const mid = this.form.merchantId;
    if (mid == null) {
      this.merchantOffers = [];
      return;
    }
    this.offersService.getAll({ merchantId: mid }).subscribe({
      next: (list) => this.merchantOffers = list,
      error: () => this.merchantOffers = []
    });
  }

  closeForm(): void {
    this.showForm = false;
    this.editingAd = null;
    this._clearVideoPreview();
    this._clearImagePreview();
  }

  get videoSrcForPreview(): string | null {
    if (this.videoPreviewUrl) return this.videoPreviewUrl;
    const v = this.form.videoUrl?.trim();
    if (!v) return null;
    return this._resolveUploadUrl(v);
  }

  /** Image affichée dans le formulaire (fichier local ou URL serveur). */
  get imageSrcForForm(): string {
    return this.imageLocalPreview ?? this.form.imageUrl ?? '';
  }

  private _clearImagePreview(): void {
    if (this._imageObjectUrl) {
      URL.revokeObjectURL(this._imageObjectUrl);
    }
    this._imageObjectUrl = null;
    this.imageLocalPreview = null;
  }

  private _clearVideoPreview(): void {
    if (this._videoObjectUrl) {
      URL.revokeObjectURL(this._videoObjectUrl);
    }
    this._videoObjectUrl = null;
    this.videoPreviewUrl = null;
    this.videoUploadProgress = 0;
  }

  ngOnDestroy(): void {
    this._clearVideoPreview();
    this._clearImagePreview();
  }

  submit(): void {
    if (this.form.merchantId == null) {
      this.error = 'Sélectionnez un commerce.';
      return;
    }
    this.submitting = true;
    this.error = '';
    const req: AdvertisementRequest = {
      merchantId: this.form.merchantId,
      title: this.form.title || undefined,
      description: this.form.description || undefined,
      imageUrl: this.form.imageUrl || undefined,
      videoUrl: this.form.videoUrl || undefined,
      targetUrl: this.form.targetUrl?.trim() || undefined,
      targetCity: this.form.targetCity || undefined,
      targetCountry: this.form.targetCountry || undefined,
      targetUniversity: this.form.targetUniversity || undefined,
      targetSegment: this.form.targetSegment || undefined,
      position: 'HOME_BANNER',
      ctaLabel: this.form.ctaLabel?.trim() || undefined,
      startDate: this.form.startDate || undefined,
      endDate: this.form.endDate || undefined,
      budget: this.form.budget,
      offerId: this.form.offerId
    };
    const obs = this.editingAd
      ? this.adsService.update(this.editingAd.id, req)
      : this.adsService.create(req);
    obs.subscribe({
      next: () => {
        this.loadAds();
        this.closeForm();
        this.submitting = false;
      },
      error: (err) => {
        this.error = err?.error?.message || 'Erreur lors de l\'enregistrement.';
        this.submitting = false;
      }
    });
  }

  onTargetCountryChanged(): void {
    const selectedCountry = this.form.targetCountry?.trim();
    const country = this.countries.find(c => c.name === selectedCountry);
    if (!country) {
      this.filteredCities = this.cities;
      return;
    }
    this.filteredCities = this.cities.filter(city => city.countryId === country.id);
    if (this.form.targetCity && !this.filteredCities.some(c => c.name === this.form.targetCity)) {
      this.form.targetCity = '';
    }
  }

  deleteAd(a: Advertisement): void {
    if (!confirm(`Supprimer la campagne « ${a.title || a.id} » ?`)) return;
    this.adsService.delete(a.id).subscribe({
      next: () => this.loadAds(),
      error: () => {}
    });
  }

  async onImageSelected(event: Event): Promise<void> {
    const input = event.target as HTMLInputElement;
    if (!input.files || input.files.length === 0) {
      return;
    }
    const file = input.files[0];
    this._clearImagePreview();
    this._imageObjectUrl = URL.createObjectURL(file);
    this.imageLocalPreview = this._imageObjectUrl;

    const formData = new FormData();
    formData.append('file', file);
    this.submitting = true;
    this.error = '';
    try {
      const token = this.auth.getToken();
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
      this.form.imageUrl = this._resolveUploadUrl(data.url);
      this._clearImagePreview();
    } catch (e) {
      this.error = (e as Error).message || 'Erreur lors de l\'upload de l\'image.';
    } finally {
      this.submitting = false;
    }
  }

  async onVideoSelected(event: Event): Promise<void> {
    const input = event.target as HTMLInputElement;
    if (!input.files || input.files.length === 0) return;

    const file = input.files[0];
    this.error = '';

    const allowedExtensions = [
      'mp4',
      'webm',
      'ogg',
      'mov',
      'm4v',
      'avi',
      'mkv',
    ];

    const ext = (file.name?.split('.').pop() ?? '').toLowerCase();
    const isAllowedByExt = !!ext && allowedExtensions.includes(ext);
    const isAllowedByType = !!file.type && file.type.startsWith('video/');

    if (!isAllowedByExt && !isAllowedByType) {
      this.error =
        'Format vidéo non reconnu. Formats supportés : mp4, webm, ogg, mov, m4v, avi, mkv.';
      return;
    }
    // Backend: spring.servlet.multipart.max-file-size=10MB
    const maxBytes = 10 * 1024 * 1024;
    if (file.size > maxBytes) {
      this.error = "La vidéo dépasse 10MB. Compresse-la et réessaie.";
      return;
    }

    this._clearVideoPreview();
    const formData = new FormData();
    formData.append('file', file);

    this.submitting = true;
    this.videoUploadProgress = 0;

    try {
      const token = this.auth.getToken();

      // Preview instantanée (choix natif galerie => object URL)
      this._videoObjectUrl = URL.createObjectURL(file);
      this.videoPreviewUrl = this._videoObjectUrl;

      // Upload avec barre de progression (XHR)
      await new Promise<void>((resolve, reject) => {
        const xhr = new XMLHttpRequest();
        xhr.open('POST', `${environment.apiUrl}/upload/advertisement-video`);
        if (token) xhr.setRequestHeader('Authorization', `Bearer ${token}`);

        xhr.upload.onprogress = (e) => {
          if (!e.lengthComputable) return;
          this.videoUploadProgress = Math.round((e.loaded / e.total) * 100);
        };

        xhr.onload = () => {
          if (xhr.status < 200 || xhr.status >= 300) {
            reject(new Error('Upload vidéo échoué'));
            return;
          }
          try {
            const data = JSON.parse(xhr.responseText) as { url?: string };
            if (!data.url) {
              reject(new Error('Réponse upload invalide'));
              return;
            }
            this.form.videoUrl = this._resolveUploadUrl(data.url);
            resolve();
          } catch {
            reject(new Error('Réponse upload invalide'));
          }
        };

        xhr.onerror = () => reject(new Error('Erreur réseau pendant l\'upload.'));
        xhr.send(formData);
      });
    } catch (e) {
      this.error = (e as Error).message || "Erreur lors de l'upload de la vidéo.";
      // Garder l'objet preview local même en cas d'erreur.
    } finally {
      this.submitting = false;
      // Une fois upload OK, on peut enlever la preview locale et afficher l'URL backend.
      if (!this.error) {
        this._clearVideoPreview();
      }
    }
  }
}
