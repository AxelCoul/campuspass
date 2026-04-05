import { Component, OnInit } from '@angular/core';
import { CommonModule, DatePipe } from '@angular/common';
import { FormsModule } from '@angular/forms';
import {
  AdminReferralStats,
  AdminReferralPayoutRequest,
  AdminReferrerStatsRow,
  AdminRewardRedemption,
  RewardCatalogItem,
  RewardCatalogItemRequest,
  RewardsAdminService
} from '../../services/rewards-admin.service';

@Component({
  selector: 'app-rewards-page',
  standalone: true,
  imports: [CommonModule, FormsModule, DatePipe],
  templateUrl: './rewards-page.component.html',
  styleUrl: './rewards-page.component.css'
})
export class RewardsPageComponent implements OnInit {
  items: RewardCatalogItem[] = [];
  redemptions: AdminRewardRedemption[] = [];
  loading = false;
  saving = false;
  savingConfig = false;
  error = '';
  success = '';
  configError = '';
  configSuccess = '';
  fcfaPerPoint = 500;
  referralStats: AdminReferralStats = {
    registeredReferrals: 0,
    activeSubscribedReferrals: 0
  };
  referrersStats: AdminReferrerStatsRow[] = [];
  refFilterDateFrom = '';
  refFilterDateTo = '';
  refFilterUniversity = '';
  refFilterTop = 10;
  payoutRequests: AdminReferralPayoutRequest[] = [];
  payoutStatusFilter: 'ALL' | 'PENDING' | 'PAID' | 'REJECTED' = 'ALL';
  payoutSearch = '';

  editing: RewardCatalogItem | null = null;

  form: RewardCatalogItemRequest = {
    title: '',
    description: '',
    pointsCost: 100,
    active: true
  };

  constructor(private rewardsService: RewardsAdminService) {}

  ngOnInit(): void {
    this.loadConfig();
    this.loadReferralStats();
    this.loadReferrersStats();
    this.loadPayoutRequests();
    this.load();
  }

  load(): void {
    this.loading = true;
    this.error = '';
    this.rewardsService.getCatalog().subscribe({
      next: (data) => {
        this.items = data;
        this.loading = false;
        this.loadRedemptions();
      },
      error: (err) => {
        console.error(err);
        this.error = 'Impossible de charger le catalogue des récompenses.';
        this.loading = false;
      }
    });
  }

  loadRedemptions(): void {
    this.rewardsService.getRedemptions().subscribe({
      next: (data) => {
        this.redemptions = data;
      },
      error: (err) => {
        console.error(err);
      }
    });
  }

  loadConfig(): void {
    this.rewardsService.getLoyaltyConfig().subscribe({
      next: (cfg) => {
        this.fcfaPerPoint = cfg.fcfaPerPoint;
      },
      error: (err) => {
        console.error(err);
      }
    });
  }

  loadReferralStats(): void {
    this.rewardsService.getReferralStats().subscribe({
      next: (stats) => {
        this.referralStats = stats;
      },
      error: (err) => {
        console.error(err);
      }
    });
  }

  loadReferrersStats(): void {
    this.rewardsService.getReferrersStats({
      dateFrom: this.refFilterDateFrom || undefined,
      dateTo: this.refFilterDateTo || undefined,
      university: this.refFilterUniversity.trim() || undefined,
      top: this.refFilterTop > 0 ? this.refFilterTop : undefined
    }).subscribe({
      next: (rows) => {
        this.referrersStats = rows;
      },
      error: (err) => {
        console.error(err);
      }
    });
  }

  applyReferrerFilters(): void {
    this.loadReferrersStats();
  }

  loadPayoutRequests(): void {
    this.rewardsService.getPayoutRequests().subscribe({
      next: (rows) => {
        this.payoutRequests = rows;
      },
      error: (err) => console.error(err)
    });
  }

  markPaid(row: AdminReferralPayoutRequest): void {
    this.rewardsService.markPayoutPaid(row.id).subscribe({
      next: () => this.loadPayoutRequests(),
      error: (err) => console.error(err)
    });
  }

  reject(row: AdminReferralPayoutRequest): void {
    this.rewardsService.rejectPayout(row.id).subscribe({
      next: () => this.loadPayoutRequests(),
      error: (err) => console.error(err)
    });
  }

  saveConfig(): void {
    if (this.fcfaPerPoint <= 0) {
      this.configError = 'La valeur doit être supérieure à 0.';
      this.configSuccess = '';
      return;
    }
    this.savingConfig = true;
    this.configError = '';
    this.configSuccess = '';
    this.rewardsService.updateLoyaltyConfig(Math.floor(this.fcfaPerPoint)).subscribe({
      next: (cfg) => {
        this.savingConfig = false;
        this.fcfaPerPoint = cfg.fcfaPerPoint;
        this.configSuccess = 'Règle de points mise à jour.';
      },
      error: (err) => {
        console.error(err);
        this.savingConfig = false;
        this.configError = 'Impossible de mettre à jour la règle.';
      }
    });
  }

  startCreate(): void {
    this.editing = null;
    this.success = '';
    this.error = '';
    this.form = {
      title: '',
      description: '',
      pointsCost: 100,
      active: true
    };
  }

  startEdit(item: RewardCatalogItem): void {
    this.editing = item;
    this.success = '';
    this.error = '';
    this.form = {
      title: item.title,
      description: item.description,
      pointsCost: item.pointsCost,
      active: item.active
    };
  }

  save(): void {
    if (!this.form.title.trim() || !this.form.description.trim() || this.form.pointsCost <= 0) {
      this.error = 'Titre, description et coût en points valides sont requis.';
      return;
    }

    this.saving = true;
    this.error = '';
    this.success = '';

    const body: RewardCatalogItemRequest = {
      title: this.form.title.trim(),
      description: this.form.description.trim(),
      pointsCost: Math.floor(this.form.pointsCost),
      active: this.form.active
    };

    const obs = this.editing
      ? this.rewardsService.update(this.editing.id, body)
      : this.rewardsService.create(body);

    obs.subscribe({
      next: () => {
        this.saving = false;
        this.success = this.editing ? 'Récompense mise à jour.' : 'Récompense créée.';
        this.startCreate();
        this.load();
      },
      error: (err) => {
        console.error(err);
        this.saving = false;
        this.error = 'Erreur lors de l’enregistrement.';
      }
    });
  }

  toggleActive(item: RewardCatalogItem): void {
    this.error = '';
    this.success = '';
    this.rewardsService.setActive(item.id, !item.active).subscribe({
      next: () => {
        this.success = 'Statut mis à jour.';
        this.load();
      },
      error: (err) => {
        console.error(err);
        this.error = 'Impossible de changer le statut.';
      }
    });
  }

  remove(item: RewardCatalogItem): void {
    if (!confirm(`Supprimer la récompense "${item.title}" ?`)) return;
    this.error = '';
    this.success = '';
    this.rewardsService.delete(item.id).subscribe({
      next: () => {
        this.success = 'Récompense supprimée.';
        this.load();
      },
      error: (err) => {
        console.error(err);
        this.error = 'Suppression impossible.';
      }
    });
  }

  get filteredPayoutRequests(): AdminReferralPayoutRequest[] {
    const q = this.payoutSearch.trim().toLowerCase();
    return this.payoutRequests.filter((r) => {
      const statusOk = this.payoutStatusFilter === 'ALL' || r.status === this.payoutStatusFilter;
      if (!statusOk) return false;
      if (!q) return true;
      const haystack = `${r.studentName ?? ''} ${r.studentEmail ?? ''} ${r.referrerId} ${r.id}`.toLowerCase();
      return haystack.includes(q);
    });
  }

  resetPayoutFilters(): void {
    this.payoutStatusFilter = 'ALL';
    this.payoutSearch = '';
  }
}
