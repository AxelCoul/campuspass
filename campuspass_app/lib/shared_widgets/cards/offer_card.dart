import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/campus_pass_palette.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../core/constants/api_constants.dart';
import '../../features/offers/offer_images_viewer_screen.dart';

class OfferCard extends StatefulWidget {
  const OfferCard({
    super.key,
    this.imageUrl,
    this.imageUrls,
    required this.offerId,
    required this.title,
    required this.subtitle,
    required this.categoryLabel,
    required this.location,
    this.rating,
    this.reviewCount,
    this.originalPrice,
    this.finalPrice,
    required this.onUseOffer,
    this.isFavorite = false,
    this.onToggleFavorite,
    this.targetUniversities,
  });

  final String? imageUrl;
  final List<String>? imageUrls;
  final int offerId;
  final String title;
  final String subtitle;
  final String categoryLabel;
  final String location;
  /// Note moyenne du commerce (null = pas encore de note).
  final double? rating;
  /// Nombre d'avis (si 0, on n'affiche pas d'étoiles).
  final int? reviewCount;
  final double? originalPrice;
  final double? finalPrice;
  final VoidCallback onUseOffer;
  final bool isFavorite;
  final VoidCallback? onToggleFavorite;
  final String? targetUniversities;

  @override
  State<OfferCard> createState() => _OfferCardState();
}

class _OfferCardState extends State<OfferCard> {
  int _pageIndex = 0;

  bool get _showRating {
    if (widget.rating == null) return false;
    if (widget.reviewCount != null && widget.reviewCount! <= 0) return false;
    return true;
  }

  List<String> _normalizedImages() {
    final list = widget.imageUrls ??
        (widget.imageUrl != null && widget.imageUrl!.isNotEmpty
            ? [widget.imageUrl!]
            : <String>[]);
    final cleaned = list.where((u) => u.trim().isNotEmpty).toList();
    return cleaned.take(3).toList();
  }

  void _openViewer(List<String> images, int initialIndex) {
    if (images.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OfferImagesViewerScreen(
          imageUrls: images,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = CampusPassPalette.of(context);
    final mutedIcon = Theme.of(context).colorScheme.onSurfaceVariant;

    // On sépare l'icône et le label de catégorie, ex: "🍔 RESTAURANT"
    final parts = widget.categoryLabel.split(' ');
    final categoryIcon = parts.isNotEmpty ? parts.first : '🍔';
    final categoryText = (parts.length > 1
            ? parts.sublist(1).join(' ')
            : '')
        .toUpperCase();

    final universitiesBadge = _universitiesBadgeText(widget.targetUniversities);
    final images = _normalizedImages();

    // ~80 % de l’écran : laisse ~20 % visible pour inciter au défilement horizontal.
    // Hauteur fixe 280 (comme avant) : le ListView accueil est aussi à 280 px.
    final screenW = MediaQuery.sizeOf(context).width;
    final cardWidth = screenW * 0.8;
    const cardHeight = 280.0;

    final imageCount = images.length;
    final canSwipe = imageCount > 1;

    return SizedBox(
      width: cardWidth,
      height: cardHeight,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: widget.onUseOffer,
          child: Container(
            decoration: BoxDecoration(
              color: palette.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: palette.cardBorder,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image (jusqu’à 3) défilable horizontalement.
                SizedBox(
                  height: 120,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        child: Container(
                          color: palette.imageCanvas,
                          child: imageCount == 0
                              ? Container(
                                  color: palette.imageCanvas,
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.local_offer_outlined,
                                    color: mutedIcon,
                                  ),
                                )
                              : PageView.builder(
                                  physics: canSwipe
                                      ? const PageScrollPhysics()
                                      : const NeverScrollableScrollPhysics(),
                                  itemCount: imageCount,
                                  onPageChanged: (i) {
                                    if (_pageIndex == i) return;
                                    setState(() => _pageIndex = i);
                                  },
                                  itemBuilder: (context, index) {
                                    final url = images[index];
                                    return GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () => _openViewer(images, index),
                                      child: Image.network(
                                        resolveImageUrl(url),
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          color: palette.imageCanvas,
                                          alignment: Alignment.center,
                                          child: Icon(
                                            Icons.image_not_supported_outlined,
                                            color: mutedIcon,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ),

                      // Badge catégorie
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(999),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.16),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                categoryIcon,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                              if (categoryText.isNotEmpty) ...[
                                const SizedBox(width: 4),
                                Text(
                                  categoryText,
                                  style: AppTextStyles.caption(context).copyWith(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                      // Icône favori
                      if (widget.onToggleFavorite != null)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: IconButton(
                            iconSize: 22,
                            padding: const EdgeInsets.all(4),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.black.withOpacity(0.25),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: widget.onToggleFavorite,
                            icon: Icon(
                              widget.isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: widget.isFavorite ? Colors.red : Colors.white,
                            ),
                          ),
                        ),

                      // Indicateur pages (si >1 image)
                      if (imageCount > 1)
                        Positioned(
                          left: 8,
                          right: 8,
                          bottom: 8,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(imageCount, (i) {
                              final active = i == _pageIndex;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                width: active ? 18 : 8,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: active
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.45),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              );
                            }),
                          ),
                        ),

                      if (universitiesBadge != null)
                        Positioned(
                          left: 8,
                          bottom: 8,
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: cardWidth - 24,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.55),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              universitiesBadge,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.caption(context).copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Texte
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Titre
                        Text(
                          widget.title,
                          style: AppTextStyles.body(context).copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        // Sous-titre
                        Text(
                          widget.subtitle,
                          style: AppTextStyles.body(context).copyWith(
                            color: AppColors.primary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        // Ligne prix
                        if (widget.originalPrice != null ||
                            widget.finalPrice != null) ...[
                          Row(
                            children: [
                              if (widget.originalPrice != null) ...[
                                Text(
                                  AppFormatters.currencyCfa(
                                    widget.originalPrice!,
                                  ),
                                  style: AppTextStyles.caption(context).copyWith(
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                                const SizedBox(width: 6),
                              ],
                              if (widget.finalPrice != null)
                                Text(
                                  AppFormatters.currencyCfa(
                                    widget.finalPrice!,
                                  ),
                                  style: AppTextStyles.body(context).copyWith(
                                    color: AppColors.success,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                        ],
                        // Ligne info
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.place,
                                    size: 14,
                                    color: AppColors.textMuted,
                                  ),
                                  const SizedBox(width: 2),
                                  Expanded(
                                    child: Text(
                                      widget.location,
                                      style: AppTextStyles.caption(context),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_showRating) ...[
                              const SizedBox(width: 4),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star,
                                    size: 14,
                                    color: Colors.amber,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    widget.rating!.toStringAsFixed(1),
                                    style: AppTextStyles.caption(context),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                        const Spacer(),
                        // Bouton
                        SizedBox(
                          width: double.infinity,
                          height: 32,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                            onPressed: widget.onUseOffer,
                            child: Text(
                              'Utiliser l’offre',
                              style: AppTextStyles.buttonPrimary(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String? _universitiesBadgeText(String? csv) {
  if (csv == null || csv.trim().isEmpty) {
    return null;
  }
  final names = csv
      .split(',')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();
  if (names.isEmpty) {
    return null;
  }
  if (names.length == 1) {
    return 'Reservee abonnes - ${names.first}';
  }
  return 'Reservee abonnes - ${names.first} +${names.length - 1}';
}