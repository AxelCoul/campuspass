import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/merchant.dart';
import '../../models/offer.dart';
import '../../shared_widgets/cards/merchant_offer_card.dart';

class MerchantDetailPreviewScreen extends StatelessWidget {
  const MerchantDetailPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final merchant = Merchant(
      id: 1,
      name: 'Burger House Campus',
      city: 'Ouagadougou',
      address: 'Avenue de l’Université, Ouaga 2000',
      openingHours: 'Lun-Dim · 10h00 - 22h00',
      logoUrl:
          'https://images.pexels.com/photos/1435907/pexels-photo-1435907.jpeg?auto=compress&cs=tinysrgb&w=1200',
    );

    final offers = <Offer>[
      Offer(
        id: 1,
        merchantId: 1,
        categoryId: 1,
        title: 'Menu Burger Étudiant',
        description: 'Burger + Frites + Boisson',
        originalPrice: 2500,
        discountPercentage: 30,
        discountAmount: 750,
        finalPrice: 1750,
        imageUrl:
            'https://images.pexels.com/photos/1639562/pexels-photo-1639562.jpeg?auto=compress&cs=tinysrgb&w=800',
        status: 'ACTIVE',
      ),
      Offer(
        id: 2,
        merchantId: 1,
        categoryId: 1,
        title: 'Duo Pizza Étudiants',
        description: '2 pizzas moyennes au choix',
        originalPrice: 8000,
        discountPercentage: 40,
        discountAmount: 3200,
        finalPrice: 4800,
        imageUrl:
            'https://images.pexels.com/photos/774487/pexels-photo-774487.jpeg?auto=compress&cs=tinysrgb&w=800',
        status: 'ACTIVE',
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 220,
            backgroundColor: AppColors.secondary,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    merchant.logoUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Container(color: AppColors.secondary),
                  ),
                  Container(
                    color: Colors.black.withOpacity(0.25),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 64, 16, 16),
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
                      Text(
                        '🍔 Restaurant',
                        style: AppTextStyles.bodySecondary(context),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '📍 Ouaga 2000',
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
                                const Icon(
                                  Icons.location_on_outlined,
                                  size: 20,
                                  color: AppColors.textMuted,
                                ),
                                const SizedBox(width: 8),
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
                                        merchant.address ?? '',
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
                                const Icon(
                                  Icons.access_time,
                                  size: 20,
                                  color: AppColors.textMuted,
                                ),
                                const SizedBox(width: 8),
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
                                            'Lun-Dim · 10h00 - 22h00',
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
                                  size: 18,
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
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: offers.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final offer = offers[index];
                          final subtitle = offer.discountPercentage != null
                              ? '-${offer.discountPercentage!.toStringAsFixed(0)}% ${offer.title}'
                              : offer.description ?? offer.title;

                          return MerchantOfferCard(
                            imageUrl: offer.imageUrl,
                            title: merchant.name,
                            subtitle: subtitle,
                            originalPrice: offer.originalPrice,
                            finalPrice: offer.finalPrice,
                            onUseOffer: () {},
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: -40,
                  left: 16,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white,
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      '🍔',
                      style: TextStyle(
                        fontSize: 40,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

