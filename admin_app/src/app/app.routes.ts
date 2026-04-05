import { Routes } from '@angular/router';
import { authGuard } from './guards/auth.guard';
import { AdminLayoutComponent } from './layouts/admin-layout/admin-layout.component';
import { LoginPageComponent } from './pages/login-page/login-page.component';
import { DashboardPageComponent } from './pages/dashboard-page/dashboard-page.component';
import { UsersPageComponent } from './pages/users-page/users-page.component';
import { StudentsPageComponent } from './pages/students-page/students-page.component';
import { MerchantsPageComponent } from './pages/merchants-page/merchants-page.component';
import { MerchantDetailPageComponent } from './pages/merchant-detail-page/merchant-detail-page.component';
import { MerchantCreatePageComponent } from './pages/merchant-create-page/merchant-create-page.component';
import { OffersPageComponent } from './pages/offers-page/offers-page.component';
import { OfferFormPageComponent } from './pages/offer-form-page/offer-form-page.component';
import { CouponsPageComponent } from './pages/coupons-page/coupons-page.component';
import { TransactionsPageComponent } from './pages/transactions-page/transactions-page.component';
import { PaymentsPageComponent } from './pages/payments-page/payments-page.component';
import { AdvertisementsPageComponent } from './pages/advertisements-page/advertisements-page.component';
import { BannersPageComponent } from './pages/banners-page/banners-page.component';
import { CategoriesPageComponent } from './pages/categories-page/categories-page.component';
import { CountriesPageComponent } from './pages/countries-page/countries-page.component';
import { CitiesPageComponent } from './pages/cities-page/cities-page.component';
import { UniversitiesPageComponent } from './pages/universities-page/universities-page.component';
import { ReviewsPageComponent } from './pages/reviews-page/reviews-page.component';
import { NotificationsPageComponent } from './pages/notifications-page/notifications-page.component';
import { AnalyticsPageComponent } from './pages/analytics-page/analytics-page.component';
import { AdminsPageComponent } from './pages/admins-page/admins-page.component';
import { SettingsPageComponent } from './pages/settings-page/settings-page.component';
import { PlansPageComponent } from './pages/plans-page/plans-page.component';
import { UserProfilePageComponent } from './pages/user-profile-page/user-profile-page.component';
import { LogsPageComponent } from './pages/logs-page/logs-page.component';
import { RewardsPageComponent } from './pages/rewards-page/rewards-page.component';
import { adminLevelGuard } from './guards/admin-level.guard';

export const routes: Routes = [
  { path: '', redirectTo: '/admin/login', pathMatch: 'full' },
  { path: 'admin/login', component: LoginPageComponent },
  {
    path: 'admin',
    component: AdminLayoutComponent,
    canActivate: [authGuard],
    children: [
      { path: '', redirectTo: 'dashboard', pathMatch: 'full' },
      { path: 'dashboard', component: DashboardPageComponent },
      { path: 'users', component: UsersPageComponent },
      { path: 'users/:id', component: UserProfilePageComponent },
      { path: 'students', component: StudentsPageComponent },
      { path: 'merchants', component: MerchantsPageComponent },
      { path: 'merchants/create', component: MerchantCreatePageComponent },
      { path: 'merchants/:id', component: MerchantDetailPageComponent },
      { path: 'offers', component: OffersPageComponent },
      { path: 'offers/create', component: OfferFormPageComponent },
      { path: 'offers/edit/:id', component: OfferFormPageComponent },
      { path: 'coupons', component: CouponsPageComponent },
      { path: 'transactions', component: TransactionsPageComponent },
      { path: 'payments', component: PaymentsPageComponent },
      { path: 'advertisements', component: AdvertisementsPageComponent },
      { path: 'banners', component: BannersPageComponent },
      { path: 'categories', component: CategoriesPageComponent },
      { path: 'countries', component: CountriesPageComponent },
      { path: 'cities', component: CitiesPageComponent },
      { path: 'universities', component: UniversitiesPageComponent },
      { path: 'reviews', component: ReviewsPageComponent },
      { path: 'notifications', component: NotificationsPageComponent },
      { path: 'analytics', component: AnalyticsPageComponent },
      { path: 'admins', component: AdminsPageComponent, canActivate: [adminLevelGuard(['SUPER_ADMIN'])] },
      { path: 'settings', component: SettingsPageComponent },
      { path: 'plans', component: PlansPageComponent, canActivate: [adminLevelGuard(['SUPER_ADMIN'])] },
      { path: 'rewards', component: RewardsPageComponent, canActivate: [adminLevelGuard(['SUPER_ADMIN'])] },
      { path: 'logs', component: LogsPageComponent, canActivate: [adminLevelGuard(['SUPER_ADMIN'])] }
    ]
  },
  { path: '**', redirectTo: '/admin/login' }
];
