import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/campus_pass_palette.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../core/constants/api_constants.dart';

class MerchantOfferCard extends StatelessWidget {
  const MerchantOfferCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.originalPrice,
    this.finalPrice,
    required this.onUseOffer,
  });

  final String title;
  final String subtitle;
  final String? imageUrl;
  final double? originalPrice;
  final double? finalPrice;
  final VoidCallback onUseOffer;

  @override
  Widget build(BuildContext context) {
    final palette = CampusPassPalette.of(context);
    return Container(
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: palette.cardBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image à gauche
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: Container(
                    color: palette.imageCanvas,
                    child: imageUrl != null && imageUrl!.isNotEmpty
                        ? Image.network(
                            resolveImageUrl(imageUrl),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _placeholder(context),
                          )
                        : _placeholder(context),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Texte à droite
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.body(context).copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTextStyles.body(context).copyWith(
                        color: AppColors.primary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    if (originalPrice != null || finalPrice != null)
                      Row(
                        children: [
                          if (originalPrice != null) ...[
                            Text(
                              AppFormatters.currencyCfa(originalPrice!),
                              style: AppTextStyles.caption(context).copyWith(
                                decoration: TextDecoration.lineThrough,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          if (finalPrice != null)
                            Text(
                              AppFormatters.currencyCfa(finalPrice!),
                              style: AppTextStyles.body(context).copyWith(
                                color: AppColors.success,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 36,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              onPressed: onUseOffer,
              child: Text(
                'Utiliser l’offre',
                style: AppTextStyles.buttonPrimary(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder(BuildContext context) {
    final p = CampusPassPalette.of(context);
    return Container(
      color: p.imageCanvas,
      alignment: Alignment.center,
      child: Icon(
        Icons.local_offer_outlined,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

