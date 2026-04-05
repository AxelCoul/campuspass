import '../models/transaction.dart';
import 'api_client.dart';

class TransactionService {
  TransactionService._();
  static final TransactionService _instance = TransactionService._();
  static TransactionService get instance => _instance;

  Future<List<Transaction>> getByMerchantId(int merchantId) async {
    final res = await ApiClient.instance.dio.get<List<dynamic>>(
      '/merchants/$merchantId/transactions',
    );
    final list = res.data ?? [];
    return list.map((e) => Transaction.fromJson(e as Map<String, dynamic>)).toList();
  }
}
