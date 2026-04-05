import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { DatePipe } from '@angular/common';
import { AdminsService, Admin, CreateAdminRequest } from '../../services/admins.service';
import { AuthService } from '../../core/auth.service';

@Component({
  selector: 'app-admins-page',
  standalone: true,
  imports: [CommonModule, FormsModule, DatePipe],
  templateUrl: './admins-page.component.html',
  styleUrl: './admins-page.component.css'
})
export class AdminsPageComponent implements OnInit {
  admins: Admin[] = [];
  loading = true;
  showCreateForm = false;
  createForm: CreateAdminRequest = {
    firstName: '',
    lastName: '',
    email: '',
    password: '',
    adminLevel: 'ADMIN'
  };
  createLoading = false;
  createError = '';
  actionError = '';
  actionSuccess = '';
  editingRoleId: number | null = null;
  editRoleValue = '';
  canManageAdmins = false;
  adminLevels = ['SUPER_ADMIN', 'ADMIN_OPERATIONS', 'ADMIN_SUPPORT', 'ADMIN'];

  constructor(
    private adminsService: AdminsService,
    public auth: AuthService
  ) {}

  ngOnInit(): void {
    this.canManageAdmins = this.auth.hasAdminLevel('SUPER_ADMIN');
    this.load();
  }

  load(): void {
    this.loading = true;
    this.adminsService.getAll().subscribe({
      next: (list) => { this.admins = list; this.loading = false; },
      error: () => { this.loading = false; }
    });
  }

  openCreate(): void {
    this.showCreateForm = true;
    this.createForm = { firstName: '', lastName: '', email: '', password: '', adminLevel: 'ADMIN' };
    this.createError = '';
  }

  closeCreate(): void {
    this.showCreateForm = false;
    this.createError = '';
  }

  submitCreate(): void {
    this.createError = '';
    if (!this.createForm.firstName?.trim() || !this.createForm.lastName?.trim() || !this.createForm.email?.trim() || !this.createForm.password) {
      this.createError = 'Tous les champs obligatoires doivent être renseignés.';
      return;
    }
    this.createLoading = true;
    this.adminsService.create(this.createForm).subscribe({
      next: () => {
        this.createLoading = false;
        this.closeCreate();
        this.load();
        this.actionSuccess = 'Administrateur créé.';
        setTimeout(() => this.actionSuccess = '', 3000);
      },
      error: (e) => {
        this.createLoading = false;
        this.createError = e.error?.message || 'Erreur lors de la création.';
      }
    });
  }

  openEditRole(a: Admin): void {
    this.editingRoleId = a.id;
    this.editRoleValue = a.adminLevel || 'ADMIN';
  }

  cancelEditRole(): void {
    this.editingRoleId = null;
    this.editRoleValue = '';
  }

  saveRole(): void {
    if (this.editingRoleId == null) return;
    this.actionError = '';
    this.actionSuccess = '';
    this.adminsService.updateRole(this.editingRoleId, this.editRoleValue).subscribe({
      next: () => {
        this.actionSuccess = 'Rôle mis à jour.';
        this.cancelEditRole();
        this.load();
        setTimeout(() => this.actionSuccess = '', 3000);
      },
      error: (e) => { this.actionError = e.error?.message || 'Erreur'; }
    });
  }

  disable(a: Admin): void {
    if (!confirm('Désactiver cet administrateur ?')) return;
    this.actionError = '';
    this.actionSuccess = '';
    this.adminsService.disable(a.id).subscribe({
      next: () => { this.actionSuccess = 'Administrateur désactivé.'; this.load(); setTimeout(() => this.actionSuccess = '', 3000); },
      error: (e) => { this.actionError = e.error?.message || 'Erreur'; }
    });
  }
}
