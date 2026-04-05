import 'package:flutter/material.dart';

import '../../../models/offer.dart';
import '../../../models/merchant.dart';
import '../../../models/category.dart';
import '../../../models/advertisement.dart';
import '../../../services/offers_service.dart';
import '../../../services/merchants_service.dart';
import '../../../services/categories_service.dart';
import '../../../services/ads_service.dart';
import '../../../services/student_service.dart';
import '../../../services/auth_service.dart';
import '../../../services/favorites_service.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/offer_card_display.dart';
import '../../offers/offer_detail_screen.dart';
import '../../profile/screens/subscription_screen.dart';
import '../home_screen.dart';
import '../../../shared_widgets/cards/flash_banner.dart';
import '../../../shared_widgets/layout/section_header.dart';
import '../../../shared_widgets/cards/offer_card.dart';
import '../../../shared_widgets/layout/auto_image_carousel.dart';
import '../advertisement_navigation.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({
    super.key,
    this.city,
    this.country,
  });

  final String? city;
  final String? country;

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  late final Future<_HomeData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_HomeData> _load() async {
    // Mode connecté vs invité
    final bool loggedIn = AuthService.instance.isLoggedIn;

    StudentMe me;
    if (loggedIn) {
      me = await StudentService.instance.getMe();
    } else {
      // Profil "invité" minimal
      me = StudentMe(
        hasActiveSubscription: false,
        subscriptionPlanName: null,
        subscriptionEndDate: null,
        studentVerified: false,
        city: null,
        university: null,
        totalSavings: 0,
        points: 0,
        referralBalance: 0,
        firstName: null,
        lastName: null,
        referralCode: null,
        referralsCount: null,
      );
    }

    // Offres visibles même en invité (university=null => toutes)
    final offers = await OffersService.instance.getActiveOffers(
      university: me.university,
    );

    final segment = loggedIn && me.hasActiveSubscription
        ? 'SUBSCRIBED'
        : 'NON_SUBSCRIBED';

    // Publicités gérées par l'admin (Angular) via "advertisements"
    final ads = await AdsService.instance.getActiveAds(
      position: 'HOME_BANNER',
      city: widget.city,
      country: widget.country,
      university: me.university,
      segment: segment,
    );
    final flashAds = await AdsService.instance.getActiveAds(
      position: 'HOME_TOP',
      city: widget.city,
      country: widget.country,
      university: me.university,
      segment: segment,
    );
    // On charge aussi les merchants pour construire les labels de localisation
    final merchants = await MerchantsService.instance.getAll();
    final categories = await CategoriesService.instance.getAll();
    if (loggedIn) {
      try {
        await FavoritesService.instance.preload();
      } catch (_) {
        // En mode invité ou si 401, on ignore les favoris.
      }
    }
    return _HomeData(
      me: me,
      offers: offers,
      ads: ads,
      flashAds: flashAds,
      merchants: merchants,
      categories: categories,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: FutureBuilder<_HomeData>(
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
                      const Text('Impossible de charger les données.'),
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

              // On calcule les offres les plus populaires à partir du nombre de coupons utilisés
              final sortedOffers = [...data.offers];
              sortedOffers.sort(
                (a, b) =>
                    (b.usedCoupons ?? 0).compareTo(a.usedCoupons ?? 0),
              );
              final selectedCity = widget.city;
              final selectedCountry = widget.country;

              bool matchesArea(Offer offer) {
                final merchant = data.merchantById(offer.merchantId);
                final matchesCity = selectedCity == null ||
                    (merchant?.city ?? '').toLowerCase() ==
                        selectedCity.toLowerCase();
                final matchesCountry = selectedCountry == null ||
                    (merchant?.country ?? '').toLowerCase() ==
                        selectedCountry.toLowerCase();
                return matchesCity && matchesCountry;
              }

              // On applique d'abord le filtre de zone. Si cela donne 0 resultat,
              // on fait un fallback sur toutes les offres pour eviter un ecran vide.
              final offersInArea = sortedOffers.where(matchesArea).toList();
              final offersSource = offersInArea.isNotEmpty ? offersInArea : sortedOffers;
              // On peut eventuellement limiter l'affichage a un certain nombre (ex: 30 max)
              final offers = offersSource.take(30).toList();

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SECTION 0 : Hero auto (images) piloté par les publicités admin
                    AutoImageCarousel(
                      items: data.ads
                          .where((ad) =>
                              (ad.imageUrl != null && ad.imageUrl!.isNotEmpty) ||
                              (ad.videoUrl != null && ad.videoUrl!.isNotEmpty))
                          .take(5)
                          .map(
                            (ad) => CarouselItem(
                              imageUrl: resolveImageUrl(ad.imageUrl),
                              videoUrl: resolveImageUrl(ad.videoUrl),
                              title: ad.title,
                              subtitle: ad.description ?? '',
                              onTap: () => navigateFromAdvertisement(
                                context,
                                ad,
                                offers: data.offers,
                                merchantById: data.merchantById,
                                city: widget.city,
                                country: widget.country,
                              ),
                            ),
                          )
                          .toList(),
                      height: 190,
                      borderRadius: 16,
                      interval: const Duration(seconds: 4),
                    ),
                    const SizedBox(height: 10),
                    if (AuthService.instance.isLoggedIn &&
                        !data.me.hasActiveSubscription) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0x22C1121F)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Debloque toutes les offres',
                              style: AppTextStyles.body(context).copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Abonne-toi pour utiliser les offres et generer ton QR code.',
                              style: AppTextStyles.bodySecondary(context),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => const SubscriptionScreen(),
                                        ),
                                      );
                                    },
                                    child: const Text('S’abonner'),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                TextButton(
                                  onPressed: () {
                                    showDialog<void>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('En savoir plus'),
                                        content: const Text(
                                          'L’abonnement actif te permet d’utiliser les offres et de generer ton QR code en caisse.',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(ctx).pop(),
                                            child: const Text('Fermer'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  child: const Text('En savoir plus'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Bandeau promo (API : publicité position HOME_TOP, configurable admin)
                    if (data.flashAds.isNotEmpty) ...[
                      Builder(
                        builder: (context) {
                          final flash = data.flashAds.first;
                          final title = flash.title.trim().isNotEmpty
                              ? flash.title
                              : 'Promo';
                          final subtitle = flash.description?.trim() ?? '';
                          final cta = flash.ctaLabel?.trim().isNotEmpty == true
                              ? flash.ctaLabel!.trim()
                              : 'Voir l’offre';
                          final canTap = flash.offerId != null ||
                              (flash.targetUrl != null &&
                                  flash.targetUrl!.trim().isNotEmpty);
                          return FlashBanner(
                            title: title,
                            subtitle: subtitle.isNotEmpty
                                ? subtitle
                                : ' ',
                            buttonLabel: cta,
                            onTap: canTap
                                ? () => navigateFromAdvertisement(
                                      context,
                                      flash,
                                      offers: data.offers,
                                      merchantById: data.merchantById,
                                      city: widget.city,
                                      country: widget.country,
                                    )
                                : null,
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Offres populaires : aligné au carrousel (pas de padding horizontal
                    // en double — le scroll a déjà 16px)
                    SectionHeader(
                      title: '🔥 Offres populaires',
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      actionLabel: 'Voir tout →',
                      onActionTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => HomeScreen(
                              initialIndex: 1,
                              initialCity: widget.city,
                              initialCountry: widget.country,
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(
                      height: 280,
                      child: ListView.separated(
                        padding: const EdgeInsets.only(right: 8),
                        scrollDirection: Axis.horizontal,
                        itemCount: offers.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final offer = offers[index];
                          final merchant = data.merchantById(offer.merchantId);
                          final subtitle = buildOfferCardPromoLine(offer);
                          return OfferCard(
                            imageUrls: offer.imageUrls,
                            offerId: offer.id,
                            title: merchant?.name.isNotEmpty == true
                                ? merchant!.name
                                : offer.title,
                            subtitle: subtitle,
                            categoryLabel: _buildCategoryLabel(
                              data.categoryById(offer.categoryId),
                            ),
                            location:
                                merchant?.neighborhood ?? merchant?.city ?? 'Ouaga',
                            rating: merchant?.rating,
                            reviewCount: merchant?.reviewCount,
                            targetUniversities: offer.targetUniversities,
                            isFavorite:
                                FavoritesService.instance.isFavoriteSync(offer.id),
                            onToggleFavorite: () async {
                              await FavoritesService.instance
                                  .toggleFavorite(offer.id);
                              if (context.mounted) {
                                setState(() {});
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
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _HomeData {
  _HomeData({
    required this.me,
    required this.offers,
    required this.ads,
    required this.flashAds,
    required this.merchants,
    required this.categories,
  });

  final StudentMe me;
  final List<Offer> offers;
  final List<Advertisement> ads;
  /// Bandeau promo sous le hero (position HOME_TOP côté API).
  final List<Advertisement> flashAds;
  final List<Merchant> merchants;
  final List<Category> categories;

  Merchant merchantById(int id) =>
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

