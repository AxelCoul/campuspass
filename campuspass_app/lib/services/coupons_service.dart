import 'package:dio/dio.dart';

import 'api_client.dart';

class CouponsService {
  CouponsService._();
  static final CouponsService instance = CouponsService._();

  Future<CouponCreated> createCoupon({required int offerId}) async {
    final Dio dio = ApiClient.instance.dio;
    final res = await dio.post('/coupons/generate', data: {
      'offerId': offerId,
    });
    final data = res.data as Map<String, dynamic>;
    return CouponCreated(
      id: (data['id'] as num).toInt(),
      qrCodeData: data['qrCodeData'] as String? ?? '',
      code: data['couponCode'] as String? ?? '',
    );
  }
}

class CouponCreated {
  CouponCreated({
    required this.id,
    required this.qrCodeData,
    required this.code,
  });

  final int id;
  final String qrCodeData;
  final String code;
}

