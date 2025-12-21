import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/review_model.dart';

abstract class ReviewRemoteDataSource {
  Future<List<ReviewModel>> getProductReviews(String productId);
  Future<ReviewModel?> getUserReview(String productId, String userId);
  Future<void> addReview(
      String productId, String userId, int rating, String? comment);
  Future<void> updateReview(String reviewId, int rating, String? comment);
  Future<void> deleteReview(String reviewId);
}

class ReviewRemoteDataSourceImpl implements ReviewRemoteDataSource {
  final SupabaseClient _client;

  ReviewRemoteDataSourceImpl(this._client);

  @override
  Future<List<ReviewModel>> getProductReviews(String productId) async {
    try {
      final response = await _client
          .rpc('get_product_reviews', params: {'p_product_id': productId});

      return (response as List)
          .map((json) => ReviewModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException('فشل في جلب التقييمات: ${e.toString()}');
    }
  }

  @override
  Future<ReviewModel?> getUserReview(String productId, String userId) async {
    try {
      final response = await _client
          .from('reviews')
          .select('*, profiles(name)')
          .eq('product_id', productId)
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) return null;

      return ReviewModel(
        id: response['id'],
        productId: response['product_id'],
        userId: response['user_id'],
        userName: response['profiles']?['name'] ?? 'مستخدم',
        rating: response['rating'],
        comment: response['comment'],
        createdAt: DateTime.parse(response['created_at']),
      );
    } catch (e) {
      throw ServerException('فشل في جلب تقييمك: ${e.toString()}');
    }
  }

  @override
  Future<void> addReview(
      String productId, String userId, int rating, String? comment) async {
    try {
      await _client.from('reviews').insert({
        'product_id': productId,
        'user_id': userId,
        'rating': rating,
        'comment': comment,
      });
    } catch (e) {
      throw ServerException('فشل في إضافة التقييم: ${e.toString()}');
    }
  }

  @override
  Future<void> updateReview(
      String reviewId, int rating, String? comment) async {
    try {
      await _client.from('reviews').update({
        'rating': rating,
        'comment': comment,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', reviewId);
    } catch (e) {
      throw ServerException('فشل في تحديث التقييم: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteReview(String reviewId) async {
    try {
      await _client.from('reviews').delete().eq('id', reviewId);
    } catch (e) {
      throw ServerException('فشل في حذف التقييم: ${e.toString()}');
    }
  }
}
