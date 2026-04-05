import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/campus_pass_palette.dart';
import '../../models/offer.dart';
import '../../models/merchant.dart';

/// Écran présentation du QR pour validation en caisse — design soigné & lisible.
class OfferUseScreen extends StatelessWidget {
  const OfferUseScreen({
    super.key,
    required this.offer,
    required this.merchant,
    required this.couponCode,
    required this.qrCodeData,
  });

  final Offer offer;
  final Merchant? merchant;
  final String couponCode;
  final String qrCodeData;

  @override
  Widget build(BuildContext context) {
    final merchantName = merchant?.name ?? offer.title;
    final palette = CampusPassPalette.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final qrPayload = qrCodeData.isNotEmpty ? qrCodeData : couponCode;

    // Modules du QR : bleu profond (marque) — bon contraste sur blanc.
    const qrForeground = AppColors.secondary;

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        title: const Text('Ton code PASS'),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: palette.background,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Taille QR responsive : on évite le défilement en ajustant la taille
            // à la hauteur dispo (écran + SafeArea + AppBar).
            final maxW = constraints.maxWidth;
            final maxH = constraints.maxHeight;

            final qrSizeByW = (maxW * 0.62).clamp(170.0, 232.0);
            final qrSizeByH = (maxH * 0.28).clamp(150.0, 232.0);
            final qrSize = qrSizeByW < qrSizeByH ? qrSizeByW : qrSizeByH;

            final qrInnerPadding = (qrSize * 0.075).clamp(12.0, 18.0);
            final qrGapAfter = qrSize < 190 ? 12.0 : 18.0;

            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Montre ce code au commerçant',
                    style: AppTextStyles.h2(context),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'À utiliser uniquement en caisse',
                    style: AppTextStyles.caption(context).copyWith(
                      color: AppColors.textMuted,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),

                  // Carte QR principale (bloquée, sans scroll)
                  Container(
                    decoration: BoxDecoration(
                      color: palette.card,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: palette.cardBorder),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isDark ? 0.35 : 0.08,
                          ),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Bandeau marque
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary,
                                Color(0xFFC1121F),
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(27),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.qr_code_scanner_rounded,
                                color: Colors.white.withValues(alpha: 0.95),
                                size: 22,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'SCAN EN CAISSE',
                                style: AppTextStyles.caption(context).copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            18,
                            18,
                            18,
                            16,
                          ),
                          child: Column(
                            children: [
                              // Zone QR : fond blanc forcé (meilleure lecture scan)
                              Container(
                                padding: EdgeInsets.all(qrInnerPadding),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppColors.cardBorder,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.secondary.withValues(
                                        alpha: 0.06,
                                      ),
                                      blurRadius: 16,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: QrImageView(
                                  data: qrPayload,
                                  version: QrVersions.auto,
                                  size: qrSize,
                                  gapless: true,
                                  backgroundColor: Colors.white,
                                  errorCorrectionLevel: QrErrorCorrectLevel.M,
                                  eyeStyle: const QrEyeStyle(
                                    eyeShape: QrEyeShape.circle,
                                    color: qrForeground,
                                  ),
                                  dataModuleStyle: const QrDataModuleStyle(
                                    dataModuleShape:
                                        QrDataModuleShape.circle,
                                    color: qrForeground,
                                  ),
                                ),
                              ),
                              SizedBox(height: qrGapAfter),

                              // Code alphanumérique (secours)
                              Text(
                                'Code coupon',
                                style: AppTextStyles.caption(context).copyWith(
                                  color: AppColors.textMuted,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Material(
                                color: palette.imageCanvas,
                                borderRadius: BorderRadius.circular(14),
                                child: InkWell(
                                  onTap: () {
                                    Clipboard.setData(
                                      ClipboardData(text: couponCode),
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text('Code copié'),
                                        behavior:
                                            SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(14),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 10,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: SelectableText(
                                            couponCode,
                                            style: AppTextStyles.body(context)
                                                .copyWith(
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 1.2,
                                              fontFeatures: const [
                                                FontFeature.tabularFigures(),
                                              ],
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(
                                          Icons.copy_rounded,
                                          size: 18,
                                          color: AppColors.textMuted,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Appuie pour copier',
                                style: AppTextStyles.caption(context).copyWith(
                                  color: AppColors.textMuted,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Récap offre (plus compact)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: palette.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: palette.cardBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.storefront_outlined,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    merchantName,
                                    style:
                                        AppTextStyles.body(context).copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    offer.title,
                                    style: AppTextStyles.bodySecondary(context),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (offer.finalPrice != null &&
                            offer.originalPrice != null) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.savings_outlined,
                                  color: AppColors.success,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Tu paies ${offer.finalPrice!.toStringAsFixed(0)} FCFA',
                                    style: AppTextStyles.body(context).copyWith(
                                      color: AppColors.success,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Note compacte
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.secondary.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 20,
                          color: AppColors.secondary.withValues(alpha: 0.85),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Le commerçant scanne ton QR en caisse.',
                            style: AppTextStyles.caption(context).copyWith(
                              height: 1.35,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
