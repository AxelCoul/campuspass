import 'package:flutter/material.dart';

import '../../core/theme/app_text_styles.dart';
import '../../core/theme/campus_pass_palette.dart';
import '../../core/utils/category_labels.dart';
import '../../core/utils/offer_card_display.dart';
import '../../models/category.dart';
import '../../models/merchant.dart';
import '../../models/offer.dart';
import '../../services/categories_service.dart';
import '../../services/favorites_service.dart';
import '../../services/merchants_service.dart';
import '../../services/offers_service.dart';
import '../../services/student_service.dart';
import '../../services/auth_service.dart';
import '../../shared_widgets/cards/merchant_card.dart';
import '../../shared_widgets/cards/offer_card.dart';
import '../../shared_widgets/chips/filter_pill_chip.dart';
import '../../shared_widgets/layout/search_bar.dart';
import '../merchants/merchant_detail_screen.dart';
import '../offers/offer_detail_screen.dart';
import '../profile/screens/subscription_screen.dart';

class ExploreTabsScreen extends StatefulWidget {
  const ExploreTabsScreen({
    super.key,
    this.city,
    this.country,
    this.initialCategoryId,
    this.initialMerchantId,
  });

  /// Si `city` est null => aucune restriction (toutes les zones).
  final String? city;
  /// Si `country` est null => match seulement sur `city`.
  final String? country;
  final int? initialCategoryId;
  final int? initialMerchantId;

  @override
  State<ExploreTabsScreen> createState() => _ExploreTabsScreenState();
}

class _ExploreTabsScreenState extends State<ExploreTabsScreen> {
  late Future<_ExploreData> _future;
  late String _selectedCategoryKey;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _future = _load();
    _selectedCategoryKey = widget.initialCategoryId == null
        ? 'all'
        : widget.initialCategoryId!.toString();
  }

  Future<_ExploreData> _load() async {
    // On récupère les offres actives (ciblées université si connecté) + tous les commerces.
    final bool loggedIn = AuthService.instance.isLoggedIn;
    String? university;
    StudentMe? me;
    if (loggedIn) {
      try {
        me = await StudentService.instance.getMe();
        university = me.university;
      } catch (_) {
        university = null;
      }
    }

    final offers = await OffersService.instance.getActiveOffers(
      university: university,
    );
    final merchants = await MerchantsService.instance.getAll();
    final categories = await CategoriesService.instance.getAll();
    if (loggedIn) {
      try {
        await FavoritesService.instance.preload();
      } catch (_) {
        // invité / 401 : on ignore les favoris
      }
    }
    return _ExploreData(
      me: me,
      offers: offers,
      merchants: merchants,
      categories: categories,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tabColor = Theme.of(context).colorScheme.onSurface;
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Explorer',
                  style: AppTextStyles.h1(context),
                ),
                const SizedBox(height: 8),
                SearchBarHome(
                  placeholder: 'Rechercher une offre ou un commerce...',
                  outerPadding: const EdgeInsets.fromLTRB(16, 12, 16, 2),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 4),
                TabBar(
                  isScrollable: false,
                  labelColor: tabColor,
                  indicatorColor: tabColor,
                  tabs: const [
                    Tab(text: 'Offres'),
                    Tab(text: 'Commerces'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<_ExploreData>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Impossible de charger les données.'),
                  );
                }

                final data = snapshot.data!;
                final palette = CampusPassPalette.of(context);
                final showSubscribeBanner = AuthService.instance.isLoggedIn &&
                    !(data.me?.hasActiveSubscription ?? false);

                bool offerMatchesWithoutArea(Offer offer) {
                  final catKey = offer.categoryId?.toString() ?? '';
                  final matchesCategory = _selectedCategoryKey == 'all' ||
                      catKey == _selectedCategoryKey;
                  final matchesMerchant = widget.initialMerchantId == null ||
                      offer.merchantId == widget.initialMerchantId;
                  final lowerTitle = offer.title.toLowerCase();
                  final lowerDesc = (offer.description ?? '').toLowerCase();
                  final query = _searchQuery.toLowerCase();
                  final matchesSearch = query.isEmpty ||
                      lowerTitle.contains(query) ||
                      lowerDesc.contains(query);
                  return matchesCategory && matchesMerchant && matchesSearch;
                }

                bool offerMatchesArea(Offer offer) {
                  final merchant = data.merchantById(offer.merchantId);
                  final merchantCity = (merchant?.city ?? '').trim().toLowerCase();
                  final merchantCountry = (merchant?.country ?? '').trim().toLowerCase();
                  final selectedCity = widget.city?.trim().toLowerCase();
                  final selectedCountry = widget.country?.trim().toLowerCase();
                  return selectedCity == null ||
                      selectedCity.isEmpty ||
                      merchantCity.isEmpty ||
                      (merchantCity == selectedCity &&
                          (selectedCountry == null ||
                              selectedCountry.isEmpty ||
                              merchantCountry.isEmpty ||
                              merchantCountry == selectedCountry));
                }

                final offersWithoutArea = data.offers.where(offerMatchesWithoutArea).toList();
                final offersInArea = offersWithoutArea.where(offerMatchesArea).toList();
                final filteredOffers = offersInArea.isNotEmpty ? offersInArea : offersWithoutArea;

                final merchantsWithoutArea = data.merchants.where((merchant) {
                  final offersForM = data.offers
                      .where((o) => o.merchantId == merchant.id)
                      .toList();
                  final catKey = resolveMerchantCategoryId(merchant, offersForM)
                          ?.toString() ??
                      '';
                  final matchesCategory = _selectedCategoryKey == 'all' ||
                      catKey == _selectedCategoryKey;
                  final matchesMerchant = widget.initialMerchantId == null ||
                      merchant.id == widget.initialMerchantId;
                  final lowerName = merchant.name.toLowerCase();
                  final query = _searchQuery.toLowerCase();
                  final matchesSearch = query.isEmpty || lowerName.contains(query);
                  return matchesCategory && matchesMerchant && matchesSearch;
                }).toList();

                bool merchantMatchesArea(Merchant merchant) {
                  final merchantCity = (merchant.city ?? '').trim().toLowerCase();
                  final merchantCountry = (merchant.country ?? '').trim().toLowerCase();
                  final selectedCity = widget.city?.trim().toLowerCase();
                  final selectedCountry = widget.country?.trim().toLowerCase();
                  return selectedCity == null ||
                      selectedCity.isEmpty ||
                      merchantCity.isEmpty ||
                      (merchantCity == selectedCity &&
                          (selectedCountry == null ||
                              selectedCountry.isEmpty ||
                              merchantCountry.isEmpty ||
                              merchantCountry == selectedCountry));
                }

                final merchantsInArea =
                    merchantsWithoutArea.where(merchantMatchesArea).toList();
                final filteredMerchants =
                    merchantsInArea.isNotEmpty ? merchantsInArea : merchantsWithoutArea;

                Category? selectedCategory;
                if (_selectedCategoryKey != 'all') {
                  try {
                    selectedCategory = data.categories.firstWhere(
                      (c) => c.id.toString() == _selectedCategoryKey,
                    );
                  } catch (_) {
                    selectedCategory = null;
                  }
                }

                return TabBarView(
                  children: [
                    // Onglet Offres : liste verticale
                    SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (showSubscribeBanner) ...[
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
                            const SizedBox(height: 8),
                          ],
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: palette.card,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: FilterPillChip(
                                      label: _selectedCategoryKey == 'all'
                                          ? '✨ Toutes'
                                          : '✨',
                                      isSelected:
                                          _selectedCategoryKey == 'all',
                                      onTap: () {
                                        setState(() {
                                          _selectedCategoryKey = 'all';
                                        });
                                      },
                                    ),
                                  ),
                                  ...data.categories.map((c) {
                                    final key = c.id.toString();
                                    final selected =
                                        _selectedCategoryKey == key;
                                    final fullLabel =
                                        formatCategoryChipLabel(c);
                                    final parts = fullLabel.trim().split(' ');
                                    final iconOnlyLabel =
                                        parts.isNotEmpty ? parts.first : null;
                                    final label = selected
                                        ? fullLabel
                                        : (iconOnlyLabel != null &&
                                                iconOnlyLabel.trim().isNotEmpty)
                                            ? iconOnlyLabel
                                            : fullLabel;
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: FilterPillChip(
                                        label: label,
                                        isSelected: selected,
                                        onTap: () {
                                          setState(() {
                                            _selectedCategoryKey = key;
                                          });
                                        },
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (filteredOffers.isEmpty)
                            Text(
                              'Aucune offre trouvée pour le moment.',
                              style: AppTextStyles.body(context),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: filteredOffers.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final offer = filteredOffers[index];
                                final merchant =
                                    data.merchantById(offer.merchantId);
                                final subtitle = buildOfferCardPromoLine(offer);
                                final category = data.categoryById(
                                  offer.categoryId,
                                );

                                return OfferCard(
                                  imageUrls: offer.imageUrls,
                                  offerId: offer.id,
                                  title: merchant?.name.isNotEmpty == true
                                      ? merchant!.name
                                      : offer.title,
                                  subtitle: subtitle,
                                  categoryLabel:
                                      formatOfferCategoryLabel(category),
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
                                    if (!context.mounted) return;
                                    setState(() {});
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
                    ),

                    // Onglet Commerces : liste verticale (style "Commerces populaires")
                    SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: palette.card,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: FilterPillChip(
                                      label: _selectedCategoryKey == 'all'
                                          ? '✨ Toutes'
                                          : '✨',
                                      isSelected:
                                          _selectedCategoryKey == 'all',
                                      onTap: () {
                                        setState(() {
                                          _selectedCategoryKey = 'all';
                                        });
                                      },
                                    ),
                                  ),
                                  ...data.categories.map((c) {
                                    final key = c.id.toString();
                                    final selected =
                                        _selectedCategoryKey == key;
                                    final fullLabel =
                                        formatCategoryChipLabel(c);
                                    final parts = fullLabel.trim().split(' ');
                                    final iconOnlyLabel =
                                        parts.isNotEmpty ? parts.first : null;
                                    final label = selected
                                        ? fullLabel
                                        : (iconOnlyLabel != null &&
                                                iconOnlyLabel.trim().isNotEmpty)
                                            ? iconOnlyLabel
                                            : fullLabel;
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: FilterPillChip(
                                        label: label,
                                        isSelected: selected,
                                        onTap: () {
                                          setState(() {
                                            _selectedCategoryKey = key;
                                          });
                                        },
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _selectedCategoryKey == 'all' || selectedCategory == null
                                      ? 'Commerces (${filteredMerchants.length})'
                                      : '${selectedCategory.icon ?? '🏪'} ${selectedCategory.name} (${filteredMerchants.length})',
                                  style: AppTextStyles.h2(context),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Column(
                            children: filteredMerchants
                                .map(
                                  (merchant) {
                                    final offersForMerchant = data.offers
                                        .where(
                                          (o) => o.merchantId == merchant.id,
                                        )
                                        .toList();
                                    final category = data.categoryById(
                                      resolveMerchantCategoryId(
                                        merchant,
                                        offersForMerchant,
                                      ),
                                    );
                                    final categoryLabel =
                                        formatCategoryChipLabel(category);

                                    final minDistanceMeters = offersForMerchant
                                        .map((o) => o.distanceMeters)
                                        .whereType<double>()
                                        .fold<double?>(
                                      null,
                                      (prev, d) {
                                        if (prev == null) return d;
                                        return d < prev ? d : prev;
                                      },
                                    );

                                    final distanceKm = minDistanceMeters != null
                                        ? minDistanceMeters / 1000
                                        : null;

                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 12.0),
                                      child: MerchantCard(
                                        merchant: merchant,
                                        categoryLabel: categoryLabel,
                                        distanceKm: distanceKm,
                                        offersCount: offersForMerchant.length,
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  MerchantDetailScreen(
                                                merchant: merchant,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ExploreData {
  _ExploreData({
    required this.me,
    required this.offers,
    required this.merchants,
    required this.categories,
  });

  final StudentMe? me;
  final List<Offer> offers;
  final List<Merchant> merchants;
  final List<Category> categories;

  Merchant? merchantById(int id) => merchants.firstWhere(
        (m) => m.id == id,
        orElse: () => Merchant(id: id, name: ''),
      );

  Category? categoryById(int? id) {
    if (id == null) return null;
    try {
      return categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}

