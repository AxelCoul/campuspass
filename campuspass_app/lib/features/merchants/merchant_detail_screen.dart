import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/api_constants.dart';
import '../../core/utils/category_labels.dart';
import '../../models/category.dart';
import '../../models/merchant.dart';
import '../../models/offer.dart';
import '../../services/categories_service.dart';
import '../../services/offers_service.dart';
import '../../services/reviews_service.dart';
import '../../shared_widgets/cards/merchant_offer_card.dart';
import '../offers/offer_detail_screen.dart';

class MerchantDetailScreen extends StatelessWidget {
  const MerchantDetailScreen({
    super.key,
    required this.merchant,
  });

  final Merchant merchant;

  Future<_MerchantDetailData> _loadData() async {
    final offers = await OffersService.instance.getByMerchantId(merchant.id);
    final categories = await CategoriesService.instance.getAll();
    final resolvedId = resolveMerchantCategoryId(merchant, offers);
    final category = categoryById(categories, resolvedId);
    return _MerchantDetailData(
      offers: offers,
      category: category,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showReviewBottomSheet(context, merchant);
        },
        icon: const Icon(
          Icons.star_rate_rounded,
          size: 26,
        ),
        label: const Text('Noter ce commerce'),
      ),
      body: FutureBuilder<_MerchantDetailData>(
        future: _loadData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Impossible de charger les offres.'),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Revenir en arrière'),
                  ),
                ],
              ),
            );
          }
          final data = snapshot.data!;
          final offers = data.offers;
          final categoryLabel = formatCategoryChipLabel(data.category);

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 220,
                backgroundColor: AppColors.secondary,
              leading: Padding(
                padding: const EdgeInsets.only(left: 8, top: 8),
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black87),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (merchant.logoUrl != null &&
                          merchant.logoUrl!.isNotEmpty)
                        Image.network(
                          resolveImageUrl(merchant.logoUrl!),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              Container(color: AppColors.secondary),
                        )
                      else
                        Container(color: AppColors.secondary),
                      Container(
                        color: Colors.black.withOpacity(0.25),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        merchant.name,
                        style: AppTextStyles.h1(context),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          categoryLabel,
                          style: AppTextStyles.bodySecondary(context).copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '📍 ${merchant.neighborhood ?? merchant.city ?? ''}',
                        style: AppTextStyles.bodySecondary(context),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Informations pratiques',
                              style: AppTextStyles.body(context).copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFFF1F1F1),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.location_on_outlined,
                                    size: 22,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Adresse',
                                        style: AppTextStyles.body(context).copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        merchant.address ??
                                            (merchant.city ?? ''),
                                        style: AppTextStyles.bodySecondary(context),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFFF1F1F1),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.access_time,
                                    size: 22,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Horaires',
                                        style: AppTextStyles.body(context).copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        merchant.openingHours ??
                                            'Horaires non renseignés',
                                        style: AppTextStyles.bodySecondary(context),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 40,
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                                onPressed: () {},
                                icon: const Icon(
                                  Icons.map_outlined,
                                  size: 22,
                                ),
                                label: const Text('Voir sur Google Maps'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Offres disponibles (${offers.length})',
                        style: AppTextStyles.h2(context),
                      ),
                      const SizedBox(height: 8),
                      if (offers.isEmpty)
                        Text(
                          'Aucune offre active pour ce commerce pour le moment.',
                          style: AppTextStyles.bodySecondary(context),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: offers.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final offer = offers[index];
                            final subtitle =
                                offer.discountPercentage != null
                                    ? '-${offer.discountPercentage!.toStringAsFixed(0)}% ${offer.title}'
                                    : offer.description ?? offer.title;
                            return MerchantOfferCard(
                              imageUrl: offer.imageUrl,
                              title: merchant.name.isNotEmpty
                                  ? merchant.name
                                  : offer.title,
                              subtitle: subtitle,
                              originalPrice: offer.originalPrice,
                              finalPrice: offer.finalPrice,
                              onUseOffer: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => OfferDetailScreen(
                                      offer: offer,
                                      merchant: merchant,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

void _showReviewBottomSheet(BuildContext context, Merchant merchant) {
  int selectedRating = 5;
  final TextEditingController commentController = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
        ),
        child: StatefulBuilder(
          builder: (context, setModalState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Donner une note',
                  style: AppTextStyles.h2(context),
                ),
                const SizedBox(height: 12),
                Row(
                  children: List.generate(5, (index) {
                    final value = index + 1;
                    final isSelected = value <= selectedRating;
                    return IconButton(
                      onPressed: () {
                        setModalState(() {
                          selectedRating = value;
                        });
                      },
                      icon: Icon(
                        isSelected
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        color: Colors.amber,
                        size: 28,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: commentController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Ajoute un commentaire (optionnel)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        await ReviewsService.instance.createReview(
                          merchantId: merchant.id,
                          rating: selectedRating,
                          comment: commentController.text.trim(),
                        );
                        if (context.mounted) {
                          Navigator.of(ctx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Merci pour ton avis !'),
                            ),
                          );
                        }
                      } catch (_) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Impossible d\'envoyer ton avis pour le moment.',
                              ),
                            ),
                          );
                        }
                      }
                    },
                    child: const Text('Envoyer'),
                  ),
                ),
              ],
            );
          },
        ),
      );
    },
  );
}

class _MerchantDetailData {
  _MerchantDetailData({
    required this.offers,
    required this.category,
  });

  final List<Offer> offers;
  final Category? category;
}

