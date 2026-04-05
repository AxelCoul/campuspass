import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../shared_widgets/cards/offer_card.dart';

class OfferCardPreviewScreen extends StatelessWidget {
  const OfferCardPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: buildAppTheme(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Prévisualisation des offres'),
        ),
        backgroundColor: const Color(0xFFF5F5F5),
        body: Center(
          child: SizedBox(
            height: 300,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _mockOffers.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
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
    reviewCount: 10,
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
    reviewCount: 5,
    originalPrice: 2000,
    finalPrice: 1600,
  ),
  _MockOffer(
    imageUrl:
        'https://images.pexels.com/photos/1552103/pexels-photo-1552103.jpeg?auto=compress&cs=tinysrgb&w=800',
    merchantName: 'Gym Universitaire',
    subtitle: '-40% Abonnement mensuel',
    categoryLabel: '🏋️ GYMNASE',
    location: 'Koulouba',
    rating: 4.5,
    reviewCount: 2,
    originalPrice: 15000,
    finalPrice: 9000,
  ),
];

