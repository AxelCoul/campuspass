import '../models/offer.dart';
import 'api_client.dart';

class OfferService {
  OfferService._();
  static final OfferService _instance = OfferService._();
  static OfferService get instance => _instance;

  /// Filtre: active | scheduled | expired | history
  Future<List<Offer>> getByMerchantIdWithFilter(int merchantId, String filter) async {
    final res = await ApiClient.instance.dio.get<List<dynamic>>(
      '/offers',
      queryParameters: {'merchantId': merchantId, 'filter': filter},
    );
    final list = res.data ?? [];
    return list.map((e) => Offer.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Offer>> getByMerchantId(int merchantId) async {
    final res = await ApiClient.instance.dio.get<List<dynamic>>(
      '/offers',
      queryParameters: {'merchantId': merchantId},
    );
    final list = res.data ?? [];
    return list.map((e) => Offer.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Offer> getById(int id) async {
    final res = await ApiClient.instance.dio.get<Map<String, dynamic>>('/offers/$id');
    return Offer.fromJson(res.data!);
  }

  Future<Offer> create(Map<String, dynamic> body) async {
    final res = await ApiClient.instance.dio.post<Map<String, dynamic>>('/offers', data: body);
    return Offer.fromJson(res.data!);
  }

  Future<Offer> update(int id, Map<String, dynamic> body) async {
    final res = await ApiClient.instance.dio.put<Map<String, dynamic>>('/offers/$id', data: body);
    return Offer.fromJson(res.data!);
  }

  Future<void> delete(int id) async {
    await ApiClient.instance.dio.delete('/offers/$id');
  }
}
