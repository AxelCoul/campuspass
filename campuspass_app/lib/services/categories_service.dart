import '../models/category.dart';
import 'api_client.dart';

class CategoriesService {
  CategoriesService._();
  static final CategoriesService instance = CategoriesService._();

  Future<List<Category>> getAll() async {
    final res = await ApiClient.instance.dio.get<List<dynamic>>('/categories');
    final data = res.data ?? const [];
    return data.map((e) => Category.fromJson(e as Map<String, dynamic>)).toList();
  }
}

