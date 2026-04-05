import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { UniversitiesService, University } from '../../services/universities.service';
import { CountriesService, Country } from '../../services/countries.service';
import { CitiesService, City } from '../../services/cities.service';

@Component({
  selector: 'app-universities-page',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './universities-page.component.html',
  styleUrl: './universities-page.component.css'
})
export class UniversitiesPageComponent implements OnInit {
  universities: University[] = [];
  countries: Country[] = [];
  cities: City[] = [];
  filteredCities: City[] = [];
  loading = true;
  showForm = false;
  editing: University | null = null;
  submitting = false;
  error = '';

  form: Partial<University> = {
    name: '',
    code: '',
    city: '',
    country: '',
    active: true,
  };

  constructor(
    private universitiesService: UniversitiesService,
    private countriesService: CountriesService,
    private citiesService: CitiesService
  ) {}

  ngOnInit(): void {
    this.loadReferences();
    this.load();
  }

  loadReferences(): void {
    this.countriesService.getAllActive().subscribe({
      next: (list) => this.countries = list,
      error: () => this.countries = [],
    });
    this.citiesService.getAllActive().subscribe({
      next: (list) => this.cities = list,
      error: () => this.cities = [],
    });
  }

  load(): void {
    this.loading = true;
    this.universitiesService.getAll().subscribe({
      next: (list) => {
        this.universities = list;
        this.loading = false;
      },
      error: () => {
        this.loading = false;
      }
    });
  }

  openCreate(): void {
    this.showForm = true;
    this.editing = null;
    this.error = '';
    this.form = {
      name: '',
      code: '',
      city: '',
      country: '',
      active: true,
    };
    this.onCountryChanged();
  }

  openEdit(u: University): void {
    this.showForm = true;
    this.editing = u;
    this.error = '';
    this.form = {
      name: u.name,
      code: u.code,
      city: u.city,
      country: u.country,
      active: u.active,
    };
    this.onCountryChanged();
  }

  closeForm(): void {
    this.showForm = false;
    this.editing = null;
  }

  submit(): void {
    if (!this.form.name || !this.form.name.trim()) {
      this.error = 'Le nom de l\'université est obligatoire.';
      return;
    }
    this.submitting = true;
    this.error = '';
    const payload: Partial<University> = {
      name: this.form.name.trim(),
      code: this.form.code?.trim() || undefined,
      city: this.form.city?.trim() || undefined,
      country: this.form.country?.trim() || undefined,
      active: this.form.active ?? true,
    };

    const obs = this.editing
      ? this.universitiesService.update(this.editing.id, payload)
      : this.universitiesService.create(payload);

    obs.subscribe({
      next: () => {
        this.submitting = false;
        this.showForm = false;
        this.editing = null;
        this.load();
      },
      error: (err) => {
        this.submitting = false;
        this.error = err?.error?.message || 'Erreur lors de l\'enregistrement.';
      }
    });
  }

  onCountryChanged(): void {
    const selectedCountry = this.form.country?.trim();
    const country = this.countries.find(c => c.name === selectedCountry);
    if (!country) {
      this.filteredCities = this.cities;
      return;
    }
    this.filteredCities = this.cities.filter(city => city.countryId === country.id);
    if (this.form.city && !this.filteredCities.some(c => c.name === this.form.city)) {
      this.form.city = '';
    }
  }

  delete(u: University): void {
    if (!confirm(`Supprimer l'université « ${u.name} » ?`)) return;
    this.universitiesService.delete(u.id).subscribe({
      next: () => this.load(),
      error: () => {}
    });
  }
}

