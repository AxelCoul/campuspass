import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';

/// Client HTTP singleton pour les appels API (Dio + baseUrl + token).
class ApiClient {
  ApiClient._() {
    _dio = Dio(BaseOptions(
      baseUrl: kApiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
    ));
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_token != null && _token!.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $_token';
        }
        return handler.next(options);
      },
      onError: (e, handler) {
        final uri = e.requestOptions.uri;
        final status = e.response?.statusCode;
        // On affiche un maximum d'infos pour diagnostiquer (sans casser le flux).
        // ignore: avoid_print
        print('[API] ERREUR Dio: ${e.type} ${e.requestOptions.method} $uri status=$status');
        if (e.response?.data != null) {
          // ignore: avoid_print
          print('[API] Response data: ${e.response?.data}');
        }
        return handler.next(e);
      },
    ));
  }

  static final ApiClient _instance = ApiClient._();
  static ApiClient get instance => _instance;

  String? _token;
  late final Dio _dio;
  Dio get dio => _dio;

  void init() {
    // Déjà initialisé dans le constructeur ; peut servir pour reconfig plus tard
  }

  void setToken(String? token) {
    _token = token;
  }
}
