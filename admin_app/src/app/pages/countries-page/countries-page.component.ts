import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { CountriesService, Country } from '../../services/countries.service';

@Component({
  selector: 'app-countries-page',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './countries-page.component.html',
  styleUrl: './countries-page.component.css'
})
export class CountriesPageComponent implements OnInit {
  countries: Country[] = [];
  loading = true;
  showForm = false;
  editing: Country | null = null;
  submitting = false;
  error = '';

  form: Partial<Country> = {
    name: '',
    code: '',
    active: true,
  };

  constructor(private countriesService: CountriesService) {}

  ngOnInit(): void {
    this.load();
  }

  load(): void {
    this.loading = true;
    this.countriesService.getAllAdmin().subscribe({
      next: (list) => {
        this.countries = list;
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
    this.form = { name: '', code: '', active: true };
  }

  openEdit(c: Country): void {
    this.showForm = true;
    this.editing = c;
    this.error = '';
    this.form = {
      name: c.name,
      code: c.code,
      active: c.active,
    };
  }

  closeForm(): void {
    this.showForm = false;
    this.editing = null;
  }

  submit(): void {
    if (!this.form.name || !this.form.name.trim()) {
      this.error = 'Le nom du pays est obligatoire.';
      return;
    }
    if (!this.form.code || !this.form.code.trim()) {
      this.error = 'Le code du pays est obligatoire.';
      return;
    }

    this.submitting = true;
    this.error = '';
    const payload: Partial<Country> = {
      name: this.form.name.trim(),
      code: this.form.code.trim().toUpperCase(),
      active: this.form.active ?? true,
    };
    const obs = this.editing
      ? this.countriesService.update(this.editing.id, payload)
      : this.countriesService.create(payload);

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

  delete(c: Country): void {
    if (!confirm(`Supprimer le pays « ${c.name} » ?`)) return;
    this.countriesService.delete(c.id).subscribe({
      next: () => this.load(),
      error: () => {}
    });
  }
}
