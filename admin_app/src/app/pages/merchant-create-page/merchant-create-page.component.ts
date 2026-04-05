import { Component } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Router, RouterLink } from '@angular/router';
import { CreateMerchantRequest, MerchantsService } from '../../services/merchants.service';
import { CategoriesService, Category } from '../../services/categories.service';
import { CountriesService, Country } from '../../services/countries.service';
import { CitiesService, City } from '../../services/cities.service';

@Component({
  selector: 'app-merchant-create-page',
  standalone: true,
  imports: [FormsModule, RouterLink],
  templateUrl: './merchant-create-page.component.html',
  styleUrl: './merchant-create-page.component.css'
})
export class MerchantCreatePageComponent {
  countries: Country[] = [];
  cities: City[] = [];
  filteredCities: City[] = [];
  categories: Category[] = [];
  model: CreateMerchantRequest = {
    firstName: '',
    lastName: '',
    email: '',
    password: '',
    phoneNumber: '',
    merchantName: '',
    city: '',
    country: '',
    categoryId: undefined,
  };
  loading = false;
  error = '';

  constructor(
    private merchantsService: MerchantsService,
    private categoriesService: CategoriesService,
    private countriesService: CountriesService,
    private citiesService: CitiesService,
    private router: Router
  ) {
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
      next: (list) => this.categories = list,
      error: () => this.categories = [],
    });
  }

  submit(): void {
    this.error = '';
    this.loading = true;
    const body: CreateMerchantRequest = {
      firstName: this.model.firstName.trim(),
      lastName: this.model.lastName.trim(),
      email: this.model.email.trim(),
      password: this.model.password,
      phoneNumber: this.model.phoneNumber?.trim() || undefined,
      merchantName: this.model.merchantName.trim(),
      city: this.model.city || undefined,
      country: this.model.country || undefined,
      categoryId: this.model.categoryId || undefined,
    };
    this.merchantsService.createAccount(body).subscribe({
      next: () => this.router.navigate(['/admin/merchants']),
      error: (e) => {
        this.error = e?.error?.message || 'Erreur lors de la création du commerce.';
        this.loading = false;
      }
    });
  }

  onCountryChanged(): void {
    const selectedCountry = this.model.country?.trim();
    const country = this.countries.find(c => c.name === selectedCountry);
    if (!country) {
      this.filteredCities = this.cities;
      return;
    }
    this.filteredCities = this.cities.filter(city => city.countryId === country.id);
    if (this.model.city && !this.filteredCities.some(c => c.name === this.model.city)) {
      this.model.city = '';
    }
  }
}

