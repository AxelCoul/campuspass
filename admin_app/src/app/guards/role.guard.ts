import { inject } from '@angular/core';
import { Router, CanActivateFn } from '@angular/router';
import { AuthService } from '../core/auth.service';

export function roleGuard(allowedRoles: string[]): CanActivateFn {
  return () => {
    const auth = inject(AuthService);
    const router = inject(Router);
    if (!auth.isAuthenticated()) {
      router.navigate(['/admin/login']);
      return false;
    }
    if (allowedRoles.some(r => auth.hasRole(r))) return true;
    router.navigate(['/admin/dashboard']);
    return false;
  };
}
