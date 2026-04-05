class Merchant {
  final int id;
  final int ownerId;
  final String name;
  final String? description;
  final String? email;
  final String? phone;
  final String? logoUrl;
  final String? address;
  final String? city;
  final String? country;
  final int? categoryId;
  final String status;
  final bool? verified;
  final String? createdAt;
  final double? latitude;
  final double? longitude;
  final String? openingHours;

  Merchant({
    required this.id,
    required this.ownerId,
    required this.name,
    this.description,
    this.email,
    this.phone,
    this.logoUrl,
    this.address,
    this.city,
    this.country,
    this.categoryId,
    required this.status,
    this.verified,
    this.createdAt,
    this.latitude,
    this.longitude,
    this.openingHours,
  });

  factory Merchant.fromJson(Map<String, dynamic> json) {
    return Merchant(
      id: (json['id'] as num).toInt(),
      ownerId: (json['ownerId'] as num).toInt(),
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      logoUrl: json['logoUrl'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      categoryId: (json['categoryId'] as num?)?.toInt(),
      status: json['status'] as String? ?? 'PENDING',
      verified: json['verified'] as bool?,
      createdAt: json['createdAt'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      openingHours: json['openingHours'] as String?,
    );
  }
}
