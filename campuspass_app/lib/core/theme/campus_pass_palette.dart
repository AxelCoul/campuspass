import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Surfaces (fond, cartes, images) pour que le mode sombre reste lisible.
@immutable
class CampusPassPalette extends ThemeExtension<CampusPassPalette> {
  const CampusPassPalette({
    required this.background,
    required this.card,
    required this.cardBorder,
    required this.imageCanvas,
  });

  final Color background;
  final Color card;
  final Color cardBorder;
  final Color imageCanvas;

  static CampusPassPalette of(BuildContext context) {
    return Theme.of(context).extension<CampusPassPalette>() ??
        CampusPassPalette.light;
  }

  static const CampusPassPalette light = CampusPassPalette(
    background: AppColors.background,
    card: AppColors.card,
    cardBorder: AppColors.cardBorder,
    imageCanvas: AppColors.imageCanvas,
  );

  static const CampusPassPalette dark = CampusPassPalette(
    background: AppColors.backgroundDark,
    card: AppColors.cardDark,
    cardBorder: AppColors.cardBorderDark,
    imageCanvas: AppColors.imageCanvasDark,
  );

  @override
  CampusPassPalette copyWith({
    Color? background,
    Color? card,
    Color? cardBorder,
    Color? imageCanvas,
  }) {
    return CampusPassPalette(
      background: background ?? this.background,
      card: card ?? this.card,
      cardBorder: cardBorder ?? this.cardBorder,
      imageCanvas: imageCanvas ?? this.imageCanvas,
    );
  }

  @override
  CampusPassPalette lerp(ThemeExtension<CampusPassPalette>? other, double t) {
    if (other is! CampusPassPalette) return this;
    return CampusPassPalette(
      background: Color.lerp(background, other.background, t)!,
      card: Color.lerp(card, other.card, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      imageCanvas: Color.lerp(imageCanvas, other.imageCanvas, t)!,
    );
  }
}
