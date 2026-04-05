import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';

@Component({
  selector: 'app-notifications-page',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './notifications-page.component.html',
  styleUrl: './notifications-page.component.css'
})
export class NotificationsPageComponent {
  title = '';
  message = '';
  audience: string = 'ALL_STUDENTS';
  scheduledAt = '';
  sending = false;
  success = '';
  error = '';

  audienceOptions = [
    { value: 'ALL_STUDENTS', label: 'Tous les étudiants' },
    { value: 'BY_CITY', label: 'Par ville' },
    { value: 'BY_MERCHANT', label: 'Par commerce' }
  ];

  send(): void {
    this.error = '';
    this.success = '';
    if (!this.title.trim() || !this.message.trim()) {
      this.error = 'Titre et message obligatoires.';
      return;
    }
    this.sending = true;
    // TODO: appeler l'API d'envoi de notification quand disponible
    setTimeout(() => {
      this.sending = false;
      this.success = 'Notification enregistrée. (Envoi à connecter au backend.)';
      this.title = '';
      this.message = '';
      this.scheduledAt = '';
    }, 800);
  }
}
