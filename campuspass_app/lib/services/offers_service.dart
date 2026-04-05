import '../models/offer.dart';
import 'api_client.dart';

class OffersService {
  OffersService._();
  static final OffersService instance = OffersService._();

  Future<List<Offer>> getActiveOffers({String? university}) async {
    final params = <String, dynamic>{};
    if (university != null && university.isNotEmpty) {
      params['university'] = university;
    }
    final res = await ApiClient.instance.dio.get<List<dynamic>>(
      '/offers',
      queryParameters: params.isEmpty ? null : params,
    );
    final data = res.data ?? const [];
    return data.map((e) => Offer.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Offer>> getNearbyOffers({
    required double latitude,
    required double longitude,
    double radiusKm = 2.0,
  }) async {
    try {
      final res = await ApiClient.instance.dio.get<List<dynamic>>(
        '/offers/nearby',
        queryParameters: {
          'lat': latitude,
          'lng': longitude,
          'radiusKm': radiusKm,
        },
      );
      final data = res.data ?? const [];
      final list = data.map((e) => Offer.fromJson(e as Map<String, dynamic>)).toList();
      if (list.isNotEmpty) return list;
    } catch (_) {
      // ignore and fallback
    }
    // Fallback : renvoyer toutes les offres actives si nearby ne renvoie rien / échoue
    return getActiveOffers();
  }

  Future<List<Offer>> getByMerchantId(int merchantId) async {
    final res = await ApiClient.instance.dio.get<List<dynamic>>(
      '/offers',
      queryParameters: {'merchantId': merchantId},
    );
    final data = res.data ?? const [];
    return data.map((e) => Offer.fromJson(e as Map<String, dynamic>)).toList();
  }
}

