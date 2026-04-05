class Offer {
  final int id;
  final int merchantId;
  final int? categoryId;
  final String title;
  final String? description;
  final double? originalPrice;
  final double? discountPercentage;
  final double? discountAmount;
  final double? finalPrice;
  final String? imageUrl;
  /// Galerie d'images pour cette offre (limitée côté UI à 3).
  ///
  /// Fallback : si l'API n'envoie qu'un `imageUrl`, on le convertit en liste.
  final List<String>? imageUrls;
  final int? maxCoupons;
  final int? usedCoupons;
  final String? startDate;
  final String? endDate;
  final String status;
  final double? distanceMeters;
  final int? maxPassesPerDayPerUser;
  final int? maxQuantityPerPass;
  final int? remainingPassesTodayForCurrentUser;
  final String? targetUniversities;

  Offer({
    required this.id,
    required this.merchantId,
    this.categoryId,
    required this.title,
    this.description,
    this.originalPrice,
    this.discountPercentage,
    this.discountAmount,
    this.finalPrice,
    this.imageUrl,
    this.imageUrls,
    this.maxCoupons,
    this.usedCoupons,
    this.startDate,
    this.endDate,
    required this.status,
    this.distanceMeters,
    this.maxPassesPerDayPerUser,
    this.maxQuantityPerPass,
    this.remainingPassesTodayForCurrentUser,
    this.targetUniversities,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    // Support de plusieurs champs selon backend (snake_case ou camelCase).
    List<String>? asStringList(dynamic v) {
      if (v == null) return null;
      if (v is List) {
        return v
            .map((e) => e?.toString())
            .whereType<String>()
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
      }
      return null;
    }

    // `imageUrls` sera parsée si le backend l'envoie.
    final parsedImageUrls =
        asStringList(json['imageUrls'] ?? json['image_urls'] ?? json['images']);

    return Offer(
      id: (json['id'] as num).toInt(),
      merchantId: (json['merchantId'] as num).toInt(),
      categoryId: (json['categoryId'] as num?)?.toInt(),
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      originalPrice: (json['originalPrice'] as num?)?.toDouble(),
      discountPercentage: (json['discountPercentage'] as num?)?.toDouble(),
      discountAmount: (json['discountAmount'] as num?)?.toDouble(),
      finalPrice: (json['finalPrice'] as num?)?.toDouble(),
      imageUrl: json['imageUrl'] as String?,
      imageUrls: parsedImageUrls ??
          (json['imageUrl'] != null
              ? [json['imageUrl'].toString()]
              : (json['image_url'] != null
                  ? [json['image_url'].toString()]
                  : null)),
      maxCoupons: (json['maxCoupons'] as num?)?.toInt(),
      usedCoupons: (json['usedCoupons'] as num?)?.toInt(),
      startDate: json['startDate']?.toString(),
      endDate: json['endDate']?.toString(),
      status: json['status'] as String? ?? 'ACTIVE',
      distanceMeters: (json['distanceMeters'] as num?)?.toDouble(),
      maxPassesPerDayPerUser:
          (json['maxPassesPerDayPerUser'] as num?)?.toInt(),
      maxQuantityPerPass: (json['maxQuantityPerPass'] as num?)?.toInt(),
      remainingPassesTodayForCurrentUser:
          (json['remainingPassesTodayForCurrentUser'] as num?)?.toInt(),
      targetUniversities: json['targetUniversities'] as String?,
    );
  }
}

