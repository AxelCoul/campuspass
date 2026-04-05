import '../../models/offer.dart';

/// Texte sous le **nom du commerce** sur les cartes d’offre (ligne en couleur primaire).
///
/// - Affiche d’abord le **titre** de l’offre (accroche type « promo sur les panini »).
/// - Ajoute **-X%** devant si `discountPercentage` est renseigné, ou si on peut
///   le déduire des prix (prix initial + prix réduit), et que le texte ne contient
///   pas déjà un pourcentage (évite « -30% 30% … »).
/// - Si le titre est vide, utilise la **description**.
String buildOfferCardPromoLine(Offer offer) {
  final title = offer.title.trim();
  final desc = offer.description?.trim() ?? '';

  final text = title.isNotEmpty ? title : desc;
  if (text.isEmpty) return '';

  final alreadyHasPercent =
      title.contains('%') || desc.contains('%');

  int? pct;
  if (offer.discountPercentage != null && offer.discountPercentage! > 0) {
    pct = offer.discountPercentage!.round();
  } else if (!alreadyHasPercent &&
      offer.originalPrice != null &&
      offer.finalPrice != null &&
      offer.originalPrice! > 0 &&
      offer.finalPrice! < offer.originalPrice!) {
    pct = (((offer.originalPrice! - offer.finalPrice!) / offer.originalPrice!) * 100)
        .round();
    if (pct <= 0) pct = null;
  }

  if (pct != null && !alreadyHasPercent) {
    return '-$pct% $text'.trim();
  }
  return text;
}
