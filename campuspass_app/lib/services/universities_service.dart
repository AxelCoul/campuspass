import 'package:dio/dio.dart';
import 'api_client.dart';

class University {
  final int id;
  final String name;
  final String? code;
  final String? city;
  final String? country;
  final bool active;

  University({
    required this.id,
    required this.name,
    this.code,
    this.city,
    this.country,
    required this.active,
  });

  factory University.fromJson(Map<String, dynamic> json) {
    return University(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      code: json['code'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      active: (json['active'] as bool?) ?? true,
    );
  }
}

class UniversitiesService {
  UniversitiesService._();
  static final UniversitiesService instance = UniversitiesService._();

  Future<List<University>> getActive() async {
    final Response<List<dynamic>> res = await ApiClient.instance.dio.get('/universities');
    final data = res.data ?? const [];
    return data.map((e) => University.fromJson(e as Map<String, dynamic>)).toList();
  }
}

