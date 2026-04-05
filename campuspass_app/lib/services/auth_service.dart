import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/api_constants.dart';
import 'api_client.dart';

class AuthService {
  AuthService._();
  static final AuthService _instance = AuthService._();
  static AuthService get instance => _instance;

  String? _token;
  int? _userId;
  String? _email;
  String? _firstName;
  String? _lastName;
  String? _role;

  String? get token => _token;
  int? get userId => _userId;
  String? get email => _email;
  String? get firstName => _firstName;
  String? get lastName => _lastName;
  String? get role => _role;
  bool get isLoggedIn => _token != null && _userId != null;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(kTokenKey);
    _userId = prefs.getInt(kUserIdKey);
    _email = prefs.getString('student_email');
    _firstName = prefs.getString('student_firstName');
    _lastName = prefs.getString('student_lastName');
    _role = prefs.getString('student_role');
    if (_token != null) ApiClient.instance.setToken(_token);
  }

  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String password,
    String? email,
    String? phoneNumber,
    String? university,
    String? matricule,
    String? referralCode,
  }) async {
    final res = await ApiClient.instance.dio.post<Map<String, dynamic>>(
      '/auth/register',
      data: {
        'firstName': firstName,
        'lastName': lastName,
        'password': password,
        if (email != null) 'email': email,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        if (university != null) 'university': university,
        if (matricule != null) 'matricule': matricule,
        if (referralCode != null && referralCode.trim().isNotEmpty)
          'referralCode': referralCode.trim(),
        'role': 'STUDENT',
      },
    );
    final data = res.data!;
    await _saveSession(
      token: data['token'] as String,
      userId: (data['id'] as num).toInt(),
      email: data['email'] as String?,
      firstName: data['firstName'] as String?,
      lastName: data['lastName'] as String?,
      role: data['role'] as String?,
    );
    return data;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await ApiClient.instance.dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    final data = res.data!;
    if (data['role'] != 'STUDENT') throw Exception('Accès réservé aux étudiants.');
    await _saveSession(
      token: data['token'] as String,
      userId: (data['id'] as num).toInt(),
      email: data['email'] as String?,
      firstName: data['firstName'] as String?,
      lastName: data['lastName'] as String?,
      role: data['role'] as String?,
    );
    return data;
  }

  Future<void> _saveSession({
    required String token,
    required int userId,
    String? email,
    String? firstName,
    String? lastName,
    String? role,
  }) async {
    _token = token;
    _userId = userId;
    _email = email;
    _firstName = firstName;
    _lastName = lastName;
    _role = role;
    ApiClient.instance.setToken(token);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kTokenKey, token);
    await prefs.setInt(kUserIdKey, userId);
    if (email != null) await prefs.setString('student_email', email);
    if (firstName != null) await prefs.setString('student_firstName', firstName);
    if (lastName != null) await prefs.setString('student_lastName', lastName);
    if (role != null) await prefs.setString('student_role', role);
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _email = _firstName = _lastName = _role = null;
    ApiClient.instance.setToken(null);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(kTokenKey);
    await prefs.remove(kUserIdKey);
    await prefs.remove('student_email');
    await prefs.remove('student_firstName');
    await prefs.remove('student_lastName');
    await prefs.remove('student_role');
  }
}
