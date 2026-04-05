import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Styles liés au [Theme] : en mode sombre, les couleurs de texte s’adaptent automatiquement.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle h1(BuildContext context) =>
      Theme.of(context).textTheme.headlineLarge!;

  static TextStyle h2(BuildContext context) =>
      Theme.of(context).textTheme.headlineMedium!;

  static TextStyle body(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium!;

  static TextStyle caption(BuildContext context) =>
      Theme.of(context).textTheme.bodySmall!;

  static TextStyle bodySecondary(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return body(context).copyWith(color: cs.onSurfaceVariant);
  }

  static TextStyle buttonPrimary(BuildContext context) => body(context).copyWith(
        fontWeight: FontWeight.w600,
        color: Colors.white,
      );

  static TextStyle buttonSecondary(BuildContext context) =>
      body(context).copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
      );
}
