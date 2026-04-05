import { Component, OnInit } from '@angular/core';
import { NgClass, NgIf, NgFor } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { CategoriesService, Category } from '../../services/categories.service';

@Component({
  selector: 'app-categories-page',
  standalone: true,
  imports: [NgIf, NgFor, FormsModule, NgClass],
  templateUrl: './categories-page.component.html',
  styleUrl: './categories-page.component.css'
})
export class CategoriesPageComponent implements OnInit {
  categories: Category[] = [];
  loading = true;
  error = '';

  // Formulaire de création
  newCategory = {
    name: '',
    icon: '',
    description: ''
  };
  creating = false;

  // Edition inline
  editingId: number | null = null;
  editModel: { name: string; icon: string; description: string } = {
    name: '',
    icon: '',
    description: ''
  };

  constructor(private categoriesService: CategoriesService) {}

  ngOnInit(): void {
    this.load();
  }

  load(): void {
    this.loading = true;
    this.error = '';
    this.categoriesService.getAll().subscribe({
      next: (c) => { this.categories = c; this.loading = false; },
      error: () => { this.loading = false; this.error = 'Impossible de charger les catégories.'; }
    });
  }

  create(): void {
    if (!this.newCategory.name.trim()) return;
    this.creating = true;
    this.error = '';
    this.categoriesService.create({
      name: this.newCategory.name.trim(),
      icon: this.newCategory.icon || undefined,
      description: this.newCategory.description || undefined
    }).subscribe({
      next: () => {
        this.newCategory = { name: '', icon: '', description: '' };
        this.creating = false;
        this.load();
      },
      error: () => {
        this.creating = false;
        this.error = 'Erreur lors de la création de la catégorie.';
      }
    });
  }

  startEdit(c: Category): void {
    this.editingId = c.id;
    this.editModel = {
      name: c.name,
      icon: c.icon || '',
      description: c.description || ''
    };
  }

  cancelEdit(): void {
    this.editingId = null;
  }

  saveEdit(c: Category): void {
    if (!this.editModel.name.trim()) return;
    this.error = '';
    this.categoriesService.update(c.id, {
      name: this.editModel.name.trim(),
      icon: this.editModel.icon || undefined,
      description: this.editModel.description || undefined
    }).subscribe({
      next: () => {
        this.editingId = null;
        this.load();
      },
      error: () => {
        this.error = 'Erreur lors de la mise à jour de la catégorie.';
      }
    });
  }

  delete(c: Category): void {
    if (!confirm(`Supprimer la catégorie "${c.name}" ?`)) return;
    this.error = '';
    this.categoriesService.delete(c.id).subscribe({
      next: () => this.load(),
      error: () => { this.error = 'Erreur lors de la suppression de la catégorie.'; }
    });
  }
}
