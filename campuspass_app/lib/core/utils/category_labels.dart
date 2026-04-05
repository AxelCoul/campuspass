import '../../models/category.dart';
import '../../models/merchant.dart';
import '../../models/offer.dart';

/// Catégorie du commerce : d’abord `merchant.categoryId`, sinon la 1re offre qui en a une
/// (même logique que l’onglet Commerces dans Explorer).
int? resolveMerchantCategoryId(Merchant merchant, List<Offer> offers) {
  if (merchant.categoryId != null) {
    return merchant.categoryId;
  }
  for (final offer in offers) {
    if (offer.categoryId != null) {
      return offer.categoryId;
    }
  }
  return null;
}

Category? categoryById(List<Category> categories, int? id) {
  if (id == null) return null;
  try {
    return categories.firstWhere((c) => c.id == id);
  } catch (_) {
    return null;
  }
}

/// Libellé filtre / badge commerce (emoji + nom), comme les puces Explorer.
String formatCategoryChipLabel(Category? category) {
  if (category == null) return '🏪 Catégorie non renseignée';
  if (category.icon != null && category.icon!.isNotEmpty) {
    return '${category.icon} ${category.name}';
  }

  switch (category.name.toLowerCase()) {
    case 'restaurant':
      return '🍔 Restaurant';
    case 'café':
    case 'cafe':
      return '☕ Café';
    case 'shopping':
      return '🛍️ Shopping';
    case 'sport':
      return '⚽ Sport';
    case 'culture':
      return '🎭 Culture';
    case 'transport':
      return '🚌 Transport';
    default:
      return '🏪 ${category.name}';
  }
}

/// Libellé sur les cartes **offre** (onglet Offres) : défaut historique si pas de catégorie.
String formatOfferCategoryLabel(Category? category) {
  if (category == null) return '🍔 RESTAURANT';
  final icon = category.icon ?? '🍔';
  return '$icon ${category.name}';
}
