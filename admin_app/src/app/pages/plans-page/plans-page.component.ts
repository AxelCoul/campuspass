import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import {
  SubscriptionPlan,
  SubscriptionPlanRequest,
  SubscriptionPlanType,
  SubscriptionPlansService
} from '../../services/subscription-plans.service';

@Component({
  selector: 'app-plans-page',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './plans-page.component.html',
  styleUrl: './plans-page.component.css'
})
export class PlansPageComponent implements OnInit {
  plans: SubscriptionPlan[] = [];
  loading = false;
  saving = false;
  error = '';
  success = '';

  // Formulaire simple pour création / édition
  editingPlan: SubscriptionPlan | null = null;
  form: {
    name: string;
    type: SubscriptionPlanType;
    price: number | null;
    promoPrice: number | null;
    startPromoDate: string | null;
    endPromoDate: string | null;
    active: boolean;
  } = {
    name: '',
    type: 'MONTHLY',
    price: null,
    promoPrice: null,
    startPromoDate: null,
    endPromoDate: null,
    active: true
  };

  constructor(private plansService: SubscriptionPlansService) {}

  ngOnInit(): void {
    this.load();
  }

  load(): void {
    this.loading = true;
    this.error = '';
    this.plansService.getAll().subscribe({
      next: (data) => {
        this.plans = data;
        this.loading = false;
      },
      error: (err) => {
        console.error(err);
        this.error = 'Impossible de charger les plans.';
        this.loading = false;
      }
    });
  }

  startCreate(type: SubscriptionPlanType): void {
    this.editingPlan = null;
    this.error = '';
    this.success = '';
    this.form = {
      name: type === 'MONTHLY' ? 'Abonnement mensuel' : 'Abonnement annuel',
      type,
      price: null,
      promoPrice: null,
      startPromoDate: null,
      endPromoDate: null,
      active: true
    };
  }

  startEdit(plan: SubscriptionPlan): void {
    this.editingPlan = plan;
    this.error = '';
    this.success = '';
    this.form = {
      name: plan.name,
      type: plan.type,
      price: plan.price,
      promoPrice: plan.promoPrice ?? null,
      startPromoDate: plan.startPromoDate ?? null,
      endPromoDate: plan.endPromoDate ?? null,
      active: plan.active
    };
  }

  resetForm(): void {
    this.editingPlan = null;
    this.form = {
      name: '',
      type: 'MONTHLY',
      price: null,
      promoPrice: null,
      startPromoDate: null,
      endPromoDate: null,
      active: true
    };
  }

  save(): void {
    if (this.form.price == null || this.form.price <= 0) {
      this.error = 'Le prix doit être strictement positif.';
      return;
    }

    this.saving = true;
    this.error = '';
    this.success = '';

    const body: SubscriptionPlanRequest = {
      name: this.form.name.trim(),
      type: this.form.type,
      price: this.form.price,
      promoPrice: this.form.promoPrice || null,
      startPromoDate: this.form.startPromoDate || null,
      endPromoDate: this.form.endPromoDate || null,
      active: this.form.active
    };

    const obs = this.editingPlan
      ? this.plansService.update(this.editingPlan.id, body)
      : this.plansService.create(body);

    obs.subscribe({
      next: () => {
        this.saving = false;
        this.success = 'Plan enregistré.';
        this.resetForm();
        this.load();
      },
      error: (err) => {
        console.error(err);
        this.saving = false;
        this.error = 'Erreur lors de l’enregistrement du plan.';
      }
    });
  }

  delete(plan: SubscriptionPlan): void {
    if (!confirm(`Supprimer le plan "${plan.name}" ?`)) {
      return;
    }
    this.error = '';
    this.success = '';
    this.plansService.delete(plan.id).subscribe({
      next: () => {
        this.success = 'Plan supprimé.';
        this.load();
      },
      error: (err) => {
        console.error(err);
        this.error = 'Impossible de supprimer le plan.';
      }
    });
  }
}

