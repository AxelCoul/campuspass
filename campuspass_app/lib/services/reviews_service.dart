import 'package:dio/dio.dart';

import 'api_client.dart';

class ReviewsService {
  ReviewsService._();
  static final ReviewsService instance = ReviewsService._();

  Future<void> createReview({
    required int merchantId,
    required int rating,
    String? comment,
  }) async {
    final Dio dio = ApiClient.instance.dio;
    await dio.post('/reviews', data: {
      'merchantId': merchantId,
      'rating': rating,
      if (comment != null && comment.isNotEmpty) 'comment': comment,
    });
  }
}

