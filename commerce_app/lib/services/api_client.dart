import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';

class ApiClient {
  ApiClient._();
  static final ApiClient _instance = ApiClient._();
  static ApiClient get instance => _instance;

  late final Dio _dio;

  void setToken(String? token) {
    _dio.options.headers['Authorization'] = token != null ? 'Bearer $token' : null;
  }

  void init() {
    _dio = Dio(BaseOptions(
      baseUrl: kApiBaseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
    ));
  }

  Dio get dio => _dio;
}
