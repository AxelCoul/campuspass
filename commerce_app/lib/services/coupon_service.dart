import '../models/coupon.dart';
import 'api_client.dart';

class CouponService {
  CouponService._();
  static final CouponService _instance = CouponService._();
  static CouponService get instance => _instance;

  /// Valide un coupon scanné. merchantId = ID du commerce connecté.
  Future<Coupon> validate(String couponCode, int merchantId) async {
    final res = await ApiClient.instance.dio.post<Map<String, dynamic>>(
      '/coupons/validate',
      queryParameters: {'merchantId': merchantId},
      data: {'couponCode': couponCode},
    );
    return Coupon.fromJson(res.data!);
  }
}
