import 'api_client.dart';

class MerchantStats {
  final int couponsUsedToday;
  final double revenueToday;
  final int activeOffersCount;
  final double totalSalesViaApp;
  final double totalDiscountsGiven;
  final int uniqueClientsCount;
  final String? topOfferTitle;
  final int topOfferUsageCount;

  MerchantStats({
    required this.couponsUsedToday,
    required this.revenueToday,
    required this.activeOffersCount,
    this.totalSalesViaApp = 0,
    this.totalDiscountsGiven = 0,
    this.uniqueClientsCount = 0,
    this.topOfferTitle,
    this.topOfferUsageCount = 0,
  });

  factory MerchantStats.fromJson(Map<String, dynamic> json) {
    return MerchantStats(
      couponsUsedToday: (json['couponsUsedToday'] as num?)?.toInt() ?? 0,
      revenueToday: (json['revenueToday'] as num?)?.toDouble() ?? 0.0,
      activeOffersCount: (json['activeOffersCount'] as num?)?.toInt() ?? 0,
      totalSalesViaApp: (json['totalSalesViaApp'] as num?)?.toDouble() ?? 0.0,
      totalDiscountsGiven: (json['totalDiscountsGiven'] as num?)?.toDouble() ?? 0.0,
      uniqueClientsCount: (json['uniqueClientsCount'] as num?)?.toInt() ?? 0,
      topOfferTitle: json['topOfferTitle'] as String?,
      topOfferUsageCount: (json['topOfferUsageCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class MerchantStatsService {
  MerchantStatsService._();
  static final MerchantStatsService _instance = MerchantStatsService._();
  static MerchantStatsService get instance => _instance;

  Future<MerchantStats> getByMerchantId(int merchantId) async {
    final res = await ApiClient.instance.dio.get<Map<String, dynamic>>(
      '/merchants/$merchantId/stats',
    );
    return MerchantStats.fromJson(res.data!);
  }
}
