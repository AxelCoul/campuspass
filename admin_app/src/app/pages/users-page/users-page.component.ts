import { Component, OnInit } from '@angular/core';
import { RouterLink } from '@angular/router';
import { DatePipe } from '@angular/common';
import { UsersService, User } from '../../services/users.service';

@Component({
  selector: 'app-users-page',
  standalone: true,
  imports: [RouterLink, DatePipe],
  templateUrl: './users-page.component.html',
  styleUrl: './users-page.component.css'
})
export class UsersPageComponent implements OnInit {
  users: User[] = [];
  loading = true;

  constructor(private usersService: UsersService) {}

  ngOnInit(): void {
    this.usersService.getAll().subscribe({
      next: (u) => { this.users = u; this.loading = false; },
      error: () => { this.loading = false; }
    });
  }
}
