import 'dart:io';

import 'package:dio/dio.dart';

import '../core/constants/api_constants.dart';
import 'api_client.dart';

class UploadService {
  UploadService._();
  static final UploadService _instance = UploadService._();
  static UploadService get instance => _instance;

  /// Envoie une image et retourne l'URL complète pour l'afficher (ex: http://10.0.2.2:8081/uploads/offers/xxx.jpg).
  Future<String> uploadOfferImage(File file) async {
    final fileName = file.path.split(RegExp(r'[/\\]')).last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: fileName),
    });
    try {
      final res = await ApiClient.instance.dio.post<Map<String, dynamic>>(
        '/upload/offer-image',
        data: formData,
        options: Options(
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 10),
          // Ne pas fixer contentType : Dio doit envoyer multipart/form-data avec boundary
        ),
      );
      final url = res.data?['url'] as String?;
      if (url == null || url.isEmpty) {
        throw Exception('Réponse upload invalide');
      }
      if (url.startsWith('http')) {
        return url;
      }
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
