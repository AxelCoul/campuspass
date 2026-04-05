import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_colors.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/main_shell.dart';
import 'screens/coupon_validation_screen.dart';
import 'screens/offer_create_screen.dart';
import 'screens/offer_edit_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/support_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/ads_screen.dart';
import 'screens/notifications_list_screen.dart';
import 'screens/staff_screen.dart';
import 'models/coupon.dart';
import 'services/auth_service.dart';
import 'services/feature_flags_service.dart';

final _router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const MainShell(),
    ),
    GoRoute(
      path: '/coupon-validation',
      builder: (context, state) {
        final coupon = state.extra as Coupon?;
        if (coupon == null) return const SizedBox.shrink();
        return CouponValidationScreen(coupon: coupon);
      },
    ),
    GoRoute(
      path: '/offers/create',
      redirect: (context, state) {
        final staff =
            AuthService.instance.user?.merchantRole?.toUpperCase() == 'STAFF';
        if (staff ||
            !FeatureFlagsService.instance.merchantOfferManagementEnabled) {
          return '/';
        }
        return null;
      },
      builder: (context, state) => const OfferCreateScreen(),
    ),
    GoRoute(
      path: '/offers/edit/:id',
      redirect: (context, state) {
        final staff =
            AuthService.instance.user?.merchantRole?.toUpperCase() == 'STAFF';
        if (staff ||
            !FeatureFlagsService.instance.merchantOfferManagementEnabled) {
          return '/';
        }
        return null;
      },
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return OfferEditScreen(offerId: int.tryParse(id) ?? 0);
      },
    ),
    GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
    GoRoute(path: '/support', builder: (context, state) => const SupportScreen()),
    GoRoute(path: '/analytics', builder: (context, state) => const AnalyticsScreen()),
    GoRoute(path: '/ads', builder: (context, state) => const AdsScreen()),
    GoRoute(path: '/notifications', builder: (context, state) => const NotificationsListScreen()),
    GoRoute(path: '/staff', builder: (context, state) => const StaffScreen()),
  ],
);

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'PASS CAMPUS Merchant',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.card,
          error: AppColors.danger,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      routerConfig: _router,
    );
  }
}
