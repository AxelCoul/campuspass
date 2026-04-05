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
  final int? maxCoupons;
  final int? usedCoupons;
  final String? startDate;
  final String? endDate;
  final String status;
  final String? createdAt;

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
    this.maxCoupons,
    this.usedCoupons,
    this.startDate,
    this.endDate,
    required this.status,
    this.createdAt,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: json['id'] as int,
      merchantId: json['merchantId'] as int,
      categoryId: json['categoryId'] as int?,
      title: json['title'] as String,
      description: json['description'] as String?,
      originalPrice: (json['originalPrice'] as num?)?.toDouble(),
      discountPercentage: (json['discountPercentage'] as num?)?.toDouble(),
      discountAmount: (json['discountAmount'] as num?)?.toDouble(),
      finalPrice: (json['finalPrice'] as num?)?.toDouble(),
      imageUrl: json['imageUrl'] as String?,
      maxCoupons: json['maxCoupons'] as int?,
      usedCoupons: json['usedCoupons'] as int?,
      startDate: json['startDate'] as String?,
      endDate: json['endDate'] as String?,
      status: json['status'] as String? ?? 'ACTIVE',
      createdAt: json['createdAt'] as String?,
    );
  }

  String get discountLabel {
    if (discountPercentage != null && discountPercentage! > 0) {
      return '-${discountPercentage!.toInt()}%';
    }
    if (discountAmount != null && discountAmount! > 0) {
      return '-${discountAmount!.toStringAsFixed(0)} FCFA';
    }
    if (originalPrice != null && finalPrice != null && finalPrice! < originalPrice!) {
      return '${originalPrice!.toInt()} → ${finalPrice!.toInt()} FCFA';
    }
    return '-';
  }

  /// Pour affichage type prix barré + promo (produit précis).
  String? get priceDisplay {
    if (originalPrice != null && finalPrice != null && finalPrice! < originalPrice!) {
      return '${originalPrice!.toInt()} FCFA'; // prix barré
    }
    return null;
  }

  String get promoPriceDisplay {
    if (finalPrice != null && finalPrice! > 0) return '${finalPrice!.toInt()} FCFA';
    if (discountPercentage != null && discountPercentage! > 0) return '-${discountPercentage!.toInt()}%';
    return discountLabel;
  }
}
