import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../shared_widgets/cards/offer_card.dart';

class HomePreviewScreen extends StatelessWidget {
  const HomePreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mockTotalSavings = 12500.0;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('Aperçu accueil'),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SECTION 1 : Pub (bannière promo avec image/offre)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, Color(0xFFFB8C00)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '🍕 Offre Flash Étudiants',
                            style: AppTextStyles.h2(context).copyWith(
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '-50% sur ta pizza ce soir chez Pizza King avec ton PASS CAMPUS.',
                            style: AppTextStyles.bodySecondary(context).copyWith(
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 32,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppColors.primary,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                              onPressed: () {},
                              child: Text(
                                'Voir l’offre',
                                style: AppTextStyles.buttonSecondary(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // SECTION 2 : Offres populaires (carrousel)
              Text(
                '🔥 Offres populaires',
                style: AppTextStyles.h2(context),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 280,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(right: 8),
                  itemCount: _mockOffers.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final offer = _mockOffers[index];
                    return OfferCard(
                      imageUrl: offer.imageUrl,
                      offerId: index,
                      title: offer.merchantName,
                      subtitle: offer.subtitle,
                      categoryLabel: offer.categoryLabel,
                      location: offer.location,
                      rating: offer.rating,
                      reviewCount: offer.reviewCount,
                      originalPrice: offer.originalPrice,
                      finalPrice: offer.finalPrice,
                      isFavorite: false,
                      onToggleFavorite: () {},
                      onUseOffer: () {},
                    );
                  },
                ),
              ),

              const SizedBox(height: 14),

              // SECTION 3 : Bannière info (statut / économies)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.insights_outlined,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Ce mois-ci, tu as déjà économisé '
                        '${AppFormatters.currencyCfa(mockTotalSavings)} '
                        'grâce à ton PASS CAMPUS.',
                        style: AppTextStyles.caption(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MockOffer {
  _MockOffer({
    required this.imageUrl,
    required this.merchantName,
    required this.subtitle,
    required this.categoryLabel,
    required this.location,
    required this.rating,
    this.reviewCount,
    required this.originalPrice,
    required this.finalPrice,
  });

  final String imageUrl;
  final String merchantName;
  final String subtitle;
  final String categoryLabel;
  final String location;
  final double rating;
  final int? reviewCount;
  final double originalPrice;
  final double finalPrice;
}

final List<_MockOffer> _mockOffers = [
  _MockOffer(
    imageUrl:
        'https://images.pexels.com/photos/1639562/pexels-photo-1639562.jpeg?auto=compress&cs=tinysrgb&w=800',
    merchantName: 'Burger House',
    subtitle: '-30% Burger Royal',
    categoryLabel: '🍔 RESTAURANT',
    location: 'Ouaga 2000',
    rating: 4.6,
    reviewCount: 24,
    originalPrice: 2500,
    finalPrice: 1750,
  ),
  _MockOffer(
    imageUrl:
        'https://images.pexels.com/photos/374885/pexels-photo-374885.jpeg?auto=compress&cs=tinysrgb&w=800',
    merchantName: 'Café Campus',
    subtitle: '-20% Latte + Viennoiserie',
    categoryLabel: '☕ CAFÉ',
    location: 'Zone du Bois',
    rating: 4.8,
    reviewCount: 8,
    originalPrice: 2000,
    finalPrice: 1600,
  ),
  _MockOffer(
    imageUrl:
        'https://images.pexels.com/photos/1552103/pexels-photo-1552103.jpeg?auto=compress&cs=tinysrgb&w=800',
    merchantName: 'Gym Universitaire',
    subtitle: '-40% Abonnement mensuel',
    categoryLabel: '🏋️ SPORT',
    location: 'Koulouba',
    rating: 4.5,
    reviewCount: 3,
    originalPrice: 15000,
    finalPrice: 9000,
  ),
];

