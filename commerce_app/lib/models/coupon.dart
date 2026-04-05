class Coupon {
  final int id;
  final int userId;
  final int offerId;
  final String couponCode;
  final String? qrCodeData;
  final String status;
  final String? generatedAt;
  final String? expiresAt;
  final String? usedAt;

  Coupon({
    required this.id,
    required this.userId,
    required this.offerId,
    required this.couponCode,
    this.qrCodeData,
    required this.status,
    this.generatedAt,
    this.expiresAt,
    this.usedAt,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: (json['id'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
      offerId: (json['offerId'] as num).toInt(),
      couponCode: json['couponCode'] as String,
      qrCodeData: json['qrCodeData'] as String?,
      status: json['status'] as String? ?? 'GENERATED',
      generatedAt: json['generatedAt'] as String?,
      expiresAt: json['expiresAt'] as String?,
      usedAt: json['usedAt'] as String?,
    );
  }

  bool get isValid => status == 'USED'; // après validation côté commerce
}
