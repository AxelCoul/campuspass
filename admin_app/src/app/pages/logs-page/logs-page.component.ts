import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { DatePipe } from '@angular/common';
import { LogsService, LogEntry } from '../../services/logs.service';

@Component({
  selector: 'app-logs-page',
  standalone: true,
  imports: [CommonModule, DatePipe],
  templateUrl: './logs-page.component.html',
  styleUrl: './logs-page.component.css'
})
export class LogsPageComponent implements OnInit {
  logs: LogEntry[] = [];
  loading = true;

  constructor(private logsService: LogsService) {}

  ngOnInit(): void {
    this.logsService.getLogs(200).subscribe({
      next: (list) => { this.logs = list; this.loading = false; },
      error: () => { this.loading = false; }
    });
  }
}
