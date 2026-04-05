import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/api_constants.dart';
import '../models/user.dart';
import 'api_client.dart';
import 'feature_flags_service.dart';
import 'merchant_service.dart';

class AuthService {
  AuthService._();
  static final AuthService _instance = AuthService._();
  static AuthService get instance => _instance;

  User? _user;
  int? _merchantId;
  String? _token;

  User? get user => _user;
  int? get merchantId => _merchantId;
  String? get token => _token;
  bool get isLoggedIn => _token != null && _token!.isNotEmpty;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(kTokenKey);
    _merchantId = prefs.getInt(kMerchantIdKey);
    if (_token != null) {
      ApiClient.instance.setToken(_token);
      final userId = prefs.getInt(kUserIdKey);
      if (userId != null && _merchantId == null) {
        await _fetchMerchantId(userId);
      }
    }
  }

  Future<void> _fetchMerchantId(int ownerId) async {
    try {
      final list = await MerchantService.instance.getByOwnerId(ownerId);
      if (list.isNotEmpty) {
        _merchantId = list.first.id;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(kMerchantIdKey, _merchantId!);
      }
    } catch (_) {}
  }

  Future<void> login(String email, String password) async {
    final res = await ApiClient.instance.dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    final data = res.data!;
    final role = data['role'] as String?;
    if (role != 'MERCHANT') {
      throw Exception('Accès réservé aux comptes commerçants.');
    }
    _token = data['token'] as String;
    _user = User.fromJson(data);
    ApiClient.instance.setToken(_token);
    _merchantId = _parseOptionalInt(data['merchantId']);
    if (_merchantId == null) {
      await _fetchMerchantId(_user!.id);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kTokenKey, _token!);
    await prefs.setInt(kUserIdKey, _user!.id);
    if (_merchantId != null) await prefs.setInt(kMerchantIdKey, _merchantId!);
    await FeatureFlagsService.instance.refresh();
  }

  static int? _parseOptionalInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return null;
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    _merchantId = null;
    ApiClient.instance.setToken(null);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(kTokenKey);
    await prefs.remove(kUserIdKey);
    await prefs.remove(kMerchantIdKey);
    FeatureFlagsService.instance.clear();
  }
}
