class Merchant {
  final int id;
  final int? categoryId;
  final String name;
  final String? logoUrl;
  final String? city;
  final String? neighborhood;
  final String? address;
  final String? country;
  final String? status;
  final String? openingHours;
  final double? rating;
  /// Nombre d'avis pris en compte pour la moyenne (API).
  final int? reviewCount;

  Merchant({
    required this.id,
    this.categoryId,
    required this.name,
    this.logoUrl,
    this.city,
    this.neighborhood,
    this.address,
    this.country,
    this.status,
    this.openingHours,
    this.rating,
    this.reviewCount,
  });

  factory Merchant.fromJson(Map<String, dynamic> json) {
    return Merchant(
      id: (json['id'] as num).toInt(),
      categoryId: (json['categoryId'] as num?)?.toInt(),
      name: json['name'] as String? ?? '',
      logoUrl: json['logoUrl'] as String?,
      city: json['city'] as String?,
      neighborhood: json['neighborhood'] as String?,
      address: json['address'] as String?,
      country: json['country'] as String?,
      status: (json['status'] as String?) ?? (json['status']?.toString()),
      openingHours: json['openingHours'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      reviewCount: (json['reviewCount'] as num?)?.toInt(),
    );
  }
}

