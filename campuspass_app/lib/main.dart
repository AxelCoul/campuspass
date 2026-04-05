import 'package:flutter/material.dart';
import 'features/home/home_preview_screen.dart';
import 'core/theme/app_theme.dart';
import 'core/app_settings.dart';
import 'features/splash/splash_screen.dart';

void main() {
  runApp(const CampusPassApp());
}

class CampusPassApp extends StatelessWidget {
  const CampusPassApp({super.key, this.homeOverride});

  /// Utilisé uniquement pour les tests (évite de lancer le bootstrap du `SplashScreen`).
  final Widget? homeOverride;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppSettings.instance,
      builder: (context, _) {
        return MaterialApp(
          title: 'Campus Pass',
          theme: buildAppTheme(),
          darkTheme: buildAppDarkTheme(),
          themeMode: AppSettings.instance.themeMode,
          home: homeOverride ?? const SplashScreen(),
        );
      },
    );
  }
}

