import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { CitiesService, City } from '../../services/cities.service';
import { CountriesService, Country } from '../../services/countries.service';

@Component({
  selector: 'app-cities-page',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './cities-page.component.html',
  styleUrl: './cities-page.component.css'
})
export class CitiesPageComponent implements OnInit {
  cities: City[] = [];
  countries: Country[] = [];
  loading = true;
  showForm = false;
  editing: City | null = null;
  submitting = false;
  error = '';

  form: Partial<City> = {
    name: '',
    countryId: undefined,
    active: true,
  };

  constructor(
    private citiesService: CitiesService,
    private countriesService: CountriesService
  ) {}

  ngOnInit(): void {
    this.loadCountries();
    this.loadCities();
  }

  loadCountries(): void {
    this.countriesService.getAllAdmin().subscribe({
      next: (list) => {
        this.countries = list.filter(c => c.active);
      },
      error: () => {
        this.countries = [];
      }
    });
  }

  loadCities(): void {
    this.loading = true;
    this.citiesService.getAllAdmin().subscribe({
      next: (list) => {
        this.cities = list;
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
      countryId: this.countries[0]?.id,
      active: true,
    };
  }

  openEdit(city: City): void {
    this.showForm = true;
    this.editing = city;
    this.error = '';
    this.form = {
      name: city.name,
      countryId: city.countryId,
      active: city.active,
    };
  }

  closeForm(): void {
    this.showForm = false;
    this.editing = null;
  }

  submit(): void {
    if (!this.form.name || !this.form.name.trim()) {
      this.error = 'Le nom de la ville est obligatoire.';
      return;
    }
    if (this.form.countryId == null) {
      this.error = 'Le pays est obligatoire.';
      return;
    }
    this.submitting = true;
    this.error = '';
    const payload: Partial<City> = {
      name: this.form.name.trim(),
      countryId: this.form.countryId,
      active: this.form.active ?? true,
    };
    const obs = this.editing
      ? this.citiesService.update(this.editing.id, payload)
      : this.citiesService.create(payload);

    obs.subscribe({
      next: () => {
        this.submitting = false;
        this.showForm = false;
        this.editing = null;
        this.loadCities();
      },
      error: (err) => {
        this.submitting = false;
        this.error = err?.error?.message || 'Erreur lors de l\'enregistrement.';
      }
    });
  }

  countryName(countryId: number): string {
    return this.countries.find(c => c.id === countryId)?.name || `#${countryId}`;
  }

  delete(city: City): void {
    if (!confirm(`Supprimer la ville « ${city.name} » ?`)) return;
    this.citiesService.delete(city.id).subscribe({
      next: () => this.loadCities(),
      error: () => {}
    });
  }
}
