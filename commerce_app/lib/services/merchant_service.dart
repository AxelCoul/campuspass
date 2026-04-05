import '../models/merchant.dart';
import 'api_client.dart';

class MerchantService {
  MerchantService._();
  static final MerchantService _instance = MerchantService._();
  static MerchantService get instance => _instance;

  Future<List<Merchant>> getByOwnerId(int ownerId) async {
    final res = await ApiClient.instance.dio.get<List<dynamic>>(
      '/merchants',
      queryParameters: {'ownerId': ownerId},
    );
    final list = res.data ?? [];
    return list.map((e) => Merchant.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Merchant> getById(int id) async {
    final res = await ApiClient.instance.dio.get<Map<String, dynamic>>('/merchants/$id');
    return Merchant.fromJson(res.data!);
  }

  Future<Merchant> update(int id, Map<String, dynamic> body) async {
    final res = await ApiClient.instance.dio.put<Map<String, dynamic>>(
      '/merchants/$id',
      data: body,
    );
    return Merchant.fromJson(res.data!);
  }
}
