import '../models/advertisement.dart';
import 'api_client.dart';

class AdsService {
  AdsService._();
  static final AdsService instance = AdsService._();

  /// Récupère les publicités actives, éventuellement filtrées par position.
  ///
  /// Côté backend : GET /advertisements?position=HOME_BANNER
  Future<List<Advertisement>> getActiveAds({
    String? position,
    String? city,
    String? country,
    String? university,
    String? segment,
  }) async {
    final params = <String, dynamic>{};
    if (position != null) params['position'] = position;
    if (city != null && city.isNotEmpty) params['city'] = city;
    if (country != null && country.isNotEmpty) params['country'] = country;
    if (university != null && university.isNotEmpty) params['university'] = university;
    if (segment != null && segment.isNotEmpty) params['segment'] = segment;
    final res = await ApiClient.instance.dio.get<List<dynamic>>('/advertisements',
        queryParameters: params.isEmpty ? null : params);
    final data = res.data ?? const [];
    return data.map((e) => Advertisement.fromJson(e as Map<String, dynamic>)).toList();
  }
}

