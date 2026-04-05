import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/campus_pass_palette.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/merchant.dart';

class MerchantCard extends StatelessWidget {
  const MerchantCard({
    super.key,
    required this.merchant,
    this.categoryLabel,
    this.distanceKm,
    this.offersCount,
    this.onTap,
    this.isFavorite = false,
    this.onToggleFavorite,
  });

  final Merchant merchant;
  final String? categoryLabel; // ex: "🍔 Restaurant · Fast-food"
  final double? distanceKm; // ex: 1.2
  final int? offersCount; // ex: 3
  final VoidCallback? onTap;
  final bool isFavorite;
  final VoidCallback? onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final palette = CampusPassPalette.of(context);
    final distanceText =
        distanceKm != null ? '${distanceKm!.toStringAsFixed(1)} km' : null;

    // Icône dans le cercle à gauche : on essaie de prendre l'emoji de la catégorie
    String circleIcon = '🍔';
    if (categoryLabel != null && categoryLabel!.isNotEmpty) {
      final first = categoryLabel!.trim().split(' ').first;
      // Heuristique simple : si le premier "mot" contient un emoji, on l'utilise
      circleIcon = first;
    } else if (merchant.name.isNotEmpty) {
      circleIcon = merchant.name[0].toUpperCase();
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 96,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: palette.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: palette.cardBorder,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              // Logo
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  circleIcon,
                  style: AppTextStyles.body(context).copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Texte centre
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      merchant.name,
                      style: AppTextStyles.body(context).copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      categoryLabel ?? '',
                      style: AppTextStyles.caption(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (merchant.city != null || distanceText != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        '📍 ${merchant.city ?? ''}'
                        '${distanceText != null ? ' · $distanceText' : ''}',
                        style: AppTextStyles.caption(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Droite: nb offres + favori + chevron
              if (offersCount != null)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Text(
                    '$offersCount offre${offersCount == 1 ? '' : 's'}',
                    style: AppTextStyles.caption(context).copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              if (onToggleFavorite != null)
                IconButton(
                  iconSize: 24,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: onToggleFavorite,
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : AppColors.textMuted,
                  ),
                ),
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}