import 'package:flutter/material.dart';

import '../../core/theme/app_text_styles.dart';
import '../../core/utils/offer_card_display.dart';
import '../../models/offer.dart';
import '../../models/merchant.dart';
import '../../models/category.dart';
import '../../services/favorites_service.dart';
import '../../services/offers_service.dart';
import '../../services/merchants_service.dart';
import '../../services/categories_service.dart';
import '../../services/auth_service.dart';
import '../../shared_widgets/layout/section_header.dart';
import '../../shared_widgets/cards/offer_card.dart';
import '../offers/offer_detail_screen.dart';
import '../auth/login_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late Future<_FavoritesData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_FavoritesData> _load() async {
    await FavoritesService.instance.preload();
    final favoriteIds = FavoritesService.instance.currentIds;
    if (favoriteIds.isEmpty) {
      return _FavoritesData(
        offers: const [],
        merchants: const [],
        categories: const [],
      );
    }

    final allOffers = await OffersService.instance.getActiveOffers();
    final offers =
        allOffers.where((o) => favoriteIds.contains(o.id)).toList();
    final merchants = await MerchantsService.instance.getAll();
    final categories = await CategoriesService.instance.getAll();
    return _FavoritesData(
      offers: offers,
      merchants: merchants,
      categories: categories,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!AuthService.instance.isLoggedIn) {
      return _GuestFavoritesPlaceholder();
    }
    return FutureBuilder<_FavoritesData>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Impossible de charger tes favoris.'),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _future = _load();
                    });
                  },
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          );
        }

        final data = snapshot.data!;
        final offers = data.offers;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tes favoris',
                style: AppTextStyles.h2(context),
              ),
              const SizedBox(height: 4),
              Text(
                'Retrouve rapidement les offres que tu as sauvegardées.',
                style: AppTextStyles.body(context),
              ),
              const SizedBox(height: 16),
              const SectionHeader(
                title: 'Offres sauvegardées',
              ),
              const SizedBox(height: 8),
              if (offers.isEmpty)
                Text(
                  'Tu n’as pas encore ajouté d’offre en favori.',
                  style: AppTextStyles.body(context),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: offers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final offer = offers[index];
                    final merchant = data.merchantById(offer.merchantId);
                    final subtitle = buildOfferCardPromoLine(offer);
                    final category =
                        data.categoryById(offer.categoryId);

                    return OfferCard(
                    imageUrls: offer.imageUrls,
                      offerId: offer.id,
                      title: merchant?.name.isNotEmpty == true
                          ? merchant!.name
                          : offer.title,
                      subtitle: subtitle,
                      categoryLabel: _buildCategoryLabel(category),
                      location:
                          merchant?.neighborhood ?? merchant?.city ?? 'Ouaga',
                      rating: merchant?.rating,
                      reviewCount: merchant?.reviewCount,
                      targetUniversities: offer.targetUniversities,
                      isFavorite: true,
                      onToggleFavorite: () async {
                        await FavoritesService.instance
                            .toggleFavorite(offer.id);
                        if (context.mounted) {
                          setState(() {
                            _future = _load();
                          });
                        }
                      },
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
        );
      },
    );
  }
}

class _GuestFavoritesPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Connecte-toi pour voir tes favoris',
            style: AppTextStyles.h2(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Ajoute des offres en favori pour les retrouver facilement. Cette fonctionnalité nécessite un compte étudiant.',
            style: AppTextStyles.bodySecondary(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              child: const Text('Se connecter / Créer un compte'),
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoritesData {
  _FavoritesData({
    required this.offers,
    required this.merchants,
    required this.categories,
  });

  final List<Offer> offers;
  final List<Merchant> merchants;
  final List<Category> categories;

  Merchant? merchantById(int id) =>
      merchants.firstWhere((m) => m.id == id, orElse: () => Merchant(id: id, name: ''));

  Category? categoryById(int? id) {
    if (id == null) return null;
    try {
      return categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}

String _buildCategoryLabel(Category? category) {
  if (category == null) return '🍔 RESTAURANT';
  final icon = category.icon ?? '🍔';
  return '$icon ${category.name}';
}

