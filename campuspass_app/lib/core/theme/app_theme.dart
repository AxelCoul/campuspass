import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'campus_pass_palette.dart';

TextTheme _textThemeFor(ColorScheme cs) {
  return TextTheme(
    headlineLarge: TextStyle(
      fontFamily: 'Poppins',
      fontSize: 26,
      fontWeight: FontWeight.w600,
      color: cs.onSurface,
    ),
    headlineMedium: TextStyle(
      fontFamily: 'Poppins',
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: cs.onSurface,
    ),
    bodyMedium: TextStyle(
      fontFamily: 'Poppins',
      fontSize: 15,
      fontWeight: FontWeight.w400,
      color: cs.onSurface,
    ),
    bodySmall: TextStyle(
      fontFamily: 'Poppins',
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: cs.onSurfaceVariant,
    ),
  );
}

ThemeData buildAppTheme() {
  final cs = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.light,
    primary: AppColors.primary,
    secondary: AppColors.secondary,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: cs,
    scaffoldBackgroundColor: AppColors.background,
    cardColor: AppColors.card,
    fontFamily: 'Poppins',
    textTheme: _textThemeFor(cs),
    extensions: const <ThemeExtension<dynamic>>[
      CampusPassPalette.light,
    ],
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: cs.onSurface,
      elevation: 0,
    ),
  );
}

/// Fond sombre + cartes légèrement plus claires pour le contraste.
ThemeData buildAppDarkTheme() {
  final cs = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.dark,
    primary: AppColors.primary,
    secondary: AppColors.secondary,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: cs,
    scaffoldBackgroundColor: AppColors.backgroundDark,
    cardColor: AppColors.cardDark,
    fontFamily: 'Poppins',
    textTheme: _textThemeFor(cs),
    extensions: const <ThemeExtension<dynamic>>[
      CampusPassPalette.dark,
    ],
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.backgroundDark,
      foregroundColor: cs.onSurface,
      elevation: 0,
    ),
    dividerTheme: DividerThemeData(color: cs.outlineVariant),
  );
}
