import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';

@Component({
  selector: 'app-settings-page',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './settings-page.component.html',
  styleUrl: './settings-page.component.css'
})
export class SettingsPageComponent {
  commissionRate = 5;
  couponValidityDays = 30;
  emailFrom = '';
  emailHost = '';
  autoNotifications = true;
  saving = false;
  success = '';
  error = '';

  save(): void {
    this.error = '';
    this.success = '';
    this.saving = true;
    // TODO: appeler l'API de sauvegarde des paramètres quand disponible
    setTimeout(() => {
      this.saving = false;
      this.success = 'Paramètres enregistrés. (Sauvegarde à connecter au backend.)';
    }, 600);
  }
}
