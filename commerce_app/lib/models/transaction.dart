class Transaction {
  final int id;
  final int couponId;
  final int userId;
  final int merchantId;
  final int offerId;
  final double? originalAmount;
  final double? discountAmount;
  final double? finalAmount;
  final String status;
  final String? transactionDate;

  Transaction({
    required this.id,
    required this.couponId,
    required this.userId,
    required this.merchantId,
    required this.offerId,
    this.originalAmount,
    this.discountAmount,
    this.finalAmount,
    required this.status,
    this.transactionDate,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as int,
      couponId: json['couponId'] as int,
      userId: json['userId'] as int,
      merchantId: json['merchantId'] as int,
      offerId: json['offerId'] as int,
      originalAmount: (json['originalAmount'] as num?)?.toDouble(),
      discountAmount: (json['discountAmount'] as num?)?.toDouble(),
      finalAmount: (json['finalAmount'] as num?)?.toDouble(),
      status: json['status'] as String? ?? 'SUCCESS',
      transactionDate: json['transactionDate'] as String?,
    );
  }
}
