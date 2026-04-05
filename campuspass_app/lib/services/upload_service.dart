import 'dart:io';

import 'package:dio/dio.dart';

import '../core/constants/api_constants.dart';
import 'api_client.dart';

class UploadService {
  UploadService._();
  static final UploadService _instance = UploadService._();
  static UploadService get instance => _instance;

  /// Upload d'un document étudiant (carte ou attestation).
  /// Retourne l'URL complète (base + /uploads/...).
  Future<String> uploadStudentDocument(File file) async {
    final fileName = file.path.split(RegExp(r'[/\\]')).last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: fileName),
    });
    try {
      final res = await ApiClient.instance.dio.post<Map<String, dynamic>>(
        '/upload/student-card',
        data: formData,
        options: Options(
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );
      final url = res.data?['url'] as String?;
      if (url == null || url.isEmpty) {
        throw Exception('Réponse upload invalide');
      }
      if (url.startsWith('http')) return url;
      return kServerBaseUrl + (url.startsWith('/') ? url : '/$url');
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final body = e.response?.data;
      final msg = body is Map ? (body['message'] ?? body['error'] ?? body) : body?.toString();
      throw Exception(
        status != null
            ? 'Upload échoué ($status)${msg != null && msg.toString().isNotEmpty ? ': $msg' : ''}'
            : 'Upload échoué: ${e.message ?? e.type.toString()}',
      );
    }
  }
}

