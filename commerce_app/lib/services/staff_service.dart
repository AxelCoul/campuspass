import '../models/staff_member.dart';
import 'api_client.dart';
import '../core/constants/api_constants.dart';
import 'auth_service.dart';

class StaffService {
  StaffService._();
  static final StaffService instance = StaffService._();

  Future<List<StaffMember>> getTeam() async {
    final merchantId = AuthService.instance.merchantId;
    if (merchantId == null) return [];
    final res = await ApiClient.instance.dio.get<List<dynamic>>('/merchants/$merchantId/team');
    final data = res.data ?? const [];
    return data.map((e) => StaffMember.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<StaffMember> createStaff({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? phoneNumber,
    String merchantRole = 'STAFF',
  }) async {
    final merchantId = AuthService.instance.merchantId;
    if (merchantId == null) {
      throw Exception('Aucun commerce associé à ce compte.');
    }
    final res = await ApiClient.instance.dio.post<Map<String, dynamic>>(
      '/merchants/$merchantId/team',
      data: {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
        'phoneNumber': phoneNumber,
        'merchantRole': merchantRole,
      },
    );
    final data = res.data ?? const {};
    return StaffMember.fromJson(data);
  }
}

