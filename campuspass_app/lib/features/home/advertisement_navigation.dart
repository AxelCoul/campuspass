import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/advertisement.dart';
import '../../models/offer.dart';
import '../../models/merchant.dart';
import '../merchants/merchant_detail_screen.dart';
import '../offers/offer_detail_screen.dart';
import '../profile/screens/subscription_screen.dart';
import 'home_screen.dart';

/// Navigation commune : carrousel hero, bandeau HOME_TOP, etc.
void navigateFromAdvertisement(
  BuildContext context,
  Advertisement ad, {
  required List<Offer> offers,
  required Merchant Function(int id) merchantById,
  String? city,
  String? country,
}) {
  final isVideo =
      ad.videoUrl != null && ad.videoUrl!.isNotEmpty;
  final isPhoto =
      ad.imageUrl != null && ad.imageUrl!.isNotEmpty;

  if (ad.offerId != null) {
    final offerId = ad.offerId!;
    Offer? offer;
    try {
      offer = offers.firstWhere((o) => o.id == offerId);
    } catch (_) {
      offer = null;
    }

    if (offer != null) {
      final merchant = merchantById(offer.merchantId);

      if (isVideo) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => OfferDetailScreen(
              offer: offer!,
              merchant: merchant,
            ),
          ),
        );
        return;
      }

      if (isPhoto) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => OfferDetailScreen(
              offer: offer!,
              merchant: merchant,
            ),
          ),
        );
        return;
      }

      // Pub texte seule (ex. bandeau HOME_TOP) : ouvrir l'offre quand même.
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OfferDetailScreen(
            offer: offer!,
            merchant: merchant,
          ),
        ),
      );
      return;
    }
  }

  final target = ad.targetUrl;
  if (target == null || target.isEmpty) return;

  if (target.startsWith('/')) {
    final parts = target
        .split('?')
        .first
        .split('/')
        .where((p) => p.isNotEmpty)
        .toList();

    if (parts.isEmpty) return;

    if (parts[0] == 'subscription') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const SubscriptionScreen(),
        ),
      );
      return;
    }

    if (parts[0] == 'explore') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => HomeScreen(
            initialIndex: 1,
            initialCity: city,
            initialCountry: country,
          ),
        ),
      );
      return;
    }

    if (parts[0] == 'merchant' && parts.length >= 2) {
      final id = int.tryParse(parts[1]);
      if (id != null) {
        final merchant = merchantById(id);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => MerchantDetailScreen(merchant: merchant),
          ),
        );
        return;
      }
    }

    if (parts[0] == 'offer' && parts.length >= 2) {
      final id = int.tryParse(parts[1]);
      if (id != null) {
        Offer? offer;
        try {
          offer = offers.firstWhere((o) => o.id == id);
        } catch (_) {
          offer = null;
        }
        if (offer != null) {
          final merchant = merchantById(offer.merchantId);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => OfferDetailScreen(
                offer: offer!,
                merchant: merchant,
              ),
            ),
          );
          return;
        }
      }
    }
  }

  final uri = Uri.tryParse(target);
  if (uri == null) return;
  launchUrl(uri, mode: LaunchMode.externalApplication);
}
