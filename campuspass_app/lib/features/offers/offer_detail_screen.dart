import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../core/constants/api_constants.dart';
import '../../models/offer.dart';
import '../../models/merchant.dart';
import '../../services/coupons_service.dart';
import '../../services/auth_service.dart';
import '../../services/student_service.dart';
import '../auth/login_screen.dart';
import '../profile/screens/subscription_screen.dart';
import 'offer_use_screen.dart';

class OfferDetailScreen extends StatelessWidget {
  const OfferDetailScreen({
    super.key,
    required this.offer,
    required this.merchant,
  });

  final Offer offer;
  final Merchant? merchant;

  @override
  Widget build(BuildContext context) {
    final merchantName = merchant?.name ?? offer.title;
    final city = merchant?.city ?? 'Ouagadougou';

    final discountText = offer.discountPercentage != null
        ? '-${offer.discountPercentage!.toStringAsFixed(0)}% ${offer.title}'
        : offer.title;

    final originalPriceText = offer.originalPrice != null
        ? AppFormatters.currencyCfa(offer.originalPrice!)
        : null;
    final finalPriceText = offer.finalPrice != null
        ? AppFormatters.currencyCfa(offer.finalPrice!)
        : null;

    final validityText = _buildValidityText(offer.startDate, offer.endDate);
    final availabilityText =
        _buildAvailabilityText(offer.maxCoupons, offer.usedCoupons);

    final bool isLimitReached =
        offer.remainingPassesTodayForCurrentUser != null &&
            offer.remainingPassesTodayForCurrentUser == 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          merchantName,
          style: AppTextStyles.body(context).copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: 200,
                width: double.infinity,
                child: offer.imageUrl != null && offer.imageUrl!.isNotEmpty
                    ? Image.network(
                        resolveImageUrl(offer.imageUrl),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey[300],
                        ),
                      )
                    : Container(
                        color: Colors.grey[300],
                      ),
              ),
            ),
            const SizedBox(height: 16),
            // Nom du commerce
            Text(
              merchantName,
              style: AppTextStyles.h2(context),
            ),
            const SizedBox(height: 4),
            Text(
              discountText,
              style: AppTextStyles.body(context).copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '📍 $city',
              style: AppTextStyles.caption(context),
            ),
            const SizedBox(height: 12),
            // Prix d'origine + prix promo
            if (originalPriceText != null || finalPriceText != null) ...[
              Row(
                children: [
                  if (originalPriceText != null) ...[
                    Text(
                      originalPriceText,
                      style: AppTextStyles.body(context).copyWith(
                        decoration: TextDecoration.lineThrough,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (finalPriceText != null)
                    Text(
                      finalPriceText,
                      style: AppTextStyles.h2(context).copyWith(
                        color: AppColors.success,
                      ),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            Text(
              'Conditions',
              style: AppTextStyles.h2(context),
            ),
            const SizedBox(height: 4),
            Text(
              offer.description ??
                  'Offre valable uniquement sur présentation de ton PASS CAMPUS lors du paiement.',
              style: AppTextStyles.body(context),
            ),
            const SizedBox(height: 16),
            Text(
              'Période de validité',
              style: AppTextStyles.h2(context),
            ),
            const SizedBox(height: 4),
            Text(
              validityText,
              style: AppTextStyles.body(context),
            ),
            const SizedBox(height: 16),
            Text(
              'Disponibilité',
              style: AppTextStyles.h2(context),
            ),
            const SizedBox(height: 4),
            Text(
              availabilityText,
              style: AppTextStyles.body(context),
            ),
            if (offer.targetUniversities != null &&
                offer.targetUniversities!.trim().isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Offre reservee',
                style: AppTextStyles.h2(context),
              ),
              const SizedBox(height: 4),
              Text(
                'Visible pour tous, mais utilisable uniquement par les abonnes des universites suivantes : ${offer.targetUniversities}.',
                style: AppTextStyles.body(context),
              ),
            ],
            const SizedBox(height: 16),
            if (offer.maxPassesPerDayPerUser != null) ...[
              Text(
                'Passages par jour',
                style: AppTextStyles.h2(context),
              ),
              const SizedBox(height: 4),
              Text(
                'Valable jusqu’à ${offer.maxPassesPerDayPerUser} passage(s) par jour et par étudiant.',
                style: AppTextStyles.body(context),
              ),
              const SizedBox(height: 4),
              if (offer.remainingPassesTodayForCurrentUser != null)
                Text(
                  offer.remainingPassesTodayForCurrentUser == 0
                      ? 'Tu as déjà utilisé le nombre de passages autorisés pour aujourd’hui.'
                      : 'Passages restants aujourd’hui : ${offer.remainingPassesTodayForCurrentUser}.',
                  style: AppTextStyles.bodySecondary(context),
                ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isLimitReached ? AppColors.textMuted : AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              onPressed: isLimitReached
                  ? null
                  : () async {
                // Si non connecté, redirige vers la page de connexion.
                if (!AuthService.instance.isLoggedIn) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => LoginScreen(),
                    ),
                  );
                  return;
                }
                StudentMe me;
                try {
                  me = await StudentService.instance.getMe();
                } catch (_) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Impossible de verifier ton abonnement.'),
                    ),
                  );
                  return;
                }
                if (!me.hasActiveSubscription) {
                  if (!context.mounted) return;
                  final action = await showModalBottomSheet<String>(
                    context: context,
                    builder: (ctx) {
                      return SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Abonnement requis',
                                style: AppTextStyles.h2(context),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tu dois etre abonne pour utiliser cette offre et generer ton QR code.',
                                style: AppTextStyles.body(context),
                              ),
                              const SizedBox(height: 14),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () => Navigator.of(ctx).pop('subscribe'),
                                  child: const Text('S’abonner maintenant'),
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(),
                                  child: const Text('Plus tard'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                  if (!context.mounted) return;
                  if (action == 'subscribe') {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SubscriptionScreen(),
                      ),
                    );
                    return;
                  }
                  return;
                }
                if (!context.mounted) return;
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Utiliser cette offre ?'),
                    content: const Text(
                      'Le commerçant va scanner ton code. '
                      'Tu ne pourras utiliser cette offre qu’une seule fois.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: const Text('Annuler'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: const Text('Oui, utiliser'),
                      ),
                    ],
                  ),
                );
                if (confirmed != true) return;

                    try {
                      final created =
                          await CouponsService.instance.createCoupon(
                        offerId: offer.id,
                      );
                      if (context.mounted) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => OfferUseScreen(
                              offer: offer,
                              merchant: merchant,
                              couponCode: created.code,
                              qrCodeData: created.qrCodeData,
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      if (!context.mounted) return;
                      String message =
                          'Impossible de générer le code pour cette offre.';
                      if (e is DioException &&
                          e.response?.statusCode == 400) {
                        final data = e.response?.data;
                        if (data is Map<String, dynamic>) {
                          final apiMessage = data['message']?.toString();
                          if (apiMessage != null && apiMessage.trim().isNotEmpty) {
                            message = apiMessage;
                          } else {
                            message =
                                'Tu as atteint le nombre de passages autorises pour aujourd hui.';
                          }
                        } else {
                          message =
                              'Tu as atteint le nombre de passages autorises pour aujourd hui.';
                        }
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(message),
                        ),
                      );
                    }
                  },
              child: Text(
                'Utiliser cette offre',
                style: AppTextStyles.buttonPrimary(context),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String _buildValidityText(String? start, String? end) {
  if (start == null && end == null) {
    return 'Période non renseignée';
  }
  if (start != null && end != null) {
    return 'Du $start au $end';
  }
  if (start != null) {
    return 'À partir du $start';
  }
  return 'Jusqu’au $end';
}

String _buildAvailabilityText(int? maxCoupons, int? usedCoupons) {
  if (maxCoupons == null) {
    return 'Nombre d’utilisations illimité';
  }
  final used = usedCoupons ?? 0;
  final remaining = (maxCoupons - used).clamp(0, maxCoupons);
  return '$remaining / $maxCoupons restants';
}


