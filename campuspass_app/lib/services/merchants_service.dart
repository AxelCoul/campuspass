import 'package:dio/dio.dart';
import '../models/merchant.dart';
import 'api_client.dart';

class MerchantsService {
  MerchantsService._();
  static final MerchantsService instance = MerchantsService._();

  Future<List<Merchant>> getAll() async {
    final Response<List<dynamic>> res = await ApiClient.instance.dio.get('/merchants');
    final data = res.data ?? const [];
    return data.map((e) => Merchant.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Merchant> getById(int id) async {
    final Response<Map<String, dynamic>> res = await ApiClient.instance.dio.get('/merchants/$id');
    final data = res.data ?? const {};
    return Merchant.fromJson(data);
  }
}

