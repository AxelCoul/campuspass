import { inject } from '@angular/core';
import { Router, CanActivateFn } from '@angular/router';
import { AuthService } from '../core/auth.service';

/** Guard that requires one of the given admin levels (e.g. SUPER_ADMIN). */
export function adminLevelGuard(allowedLevels: string[]): CanActivateFn {
  return () => {
    const auth = inject(AuthService);
    const router = inject(Router);
    if (!auth.isAuthenticated()) {
      router.navigate(['/admin/login']);
      return false;
    }
    if (allowedLevels.some(level => auth.hasAdminLevel(level))) return true;
    router.navigate(['/admin/dashboard']);
    return false;
  };
}
