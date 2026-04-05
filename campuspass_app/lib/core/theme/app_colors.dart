import 'package:flutter/material.dart';

/// Palette startup – app étudiant Campus Pass
class AppColors {
  static const Color primary = Color(0xFFE63946);      // Rouge PASS CAMPUS (CTA, promos)
  static const Color secondary = Color(0xFF1D3557);    // Bleu profond (navigation, éléments secondaires)
  static const Color success = Color(0xFF2ECC71);      // Vert économies
  /// Fond mode clair — gris un peu plus marqué pour mieux détacher les cartes blanches.
  static const Color background = Color(0xFFE8EBF1);
  static const Color card = Colors.white;
  static const Color cardBorder = Color(0xFFE2E8F0);
  static const Color imageCanvas = Color(0xFFF1F5F9);
  static const Color text = Color(0xFF1A1A1A);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color danger = Color(0xFFE53935);

  /// Mode sombre — fond et surfaces
  static const Color backgroundDark = Color(0xFF0F1419);
  static const Color cardDark = Color(0xFF1A1F26);
  static const Color cardBorderDark = Color(0xFF2D3748);
  static const Color imageCanvasDark = Color(0xFF252B36);
}
