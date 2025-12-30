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

      // Update product rating and rating_count
      await _updateProductRating(productId);
    } catch (e) {
      throw ServerException('فشل في إضافة التقييم: ${e.toString()}');
    }
  }

  @override
  Future<void> updateReview(
      String reviewId, int rating, String? comment) async {
    try {
      // Get product_id before update
      final review = await _client
          .from('reviews')
          .select('product_id')
          .eq('id', reviewId)
          .single();

      await _client.from('reviews').update({
        'rating': rating,
        'comment': comment,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', reviewId);

      // Update product rating
      await _updateProductRating(review['product_id']);
    } catch (e) {
      throw ServerException('فشل في تحديث التقييم: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteReview(String reviewId) async {
    try {
      // Get product_id before delete
      final review = await _client
          .from('reviews')
          .select('product_id')
          .eq('id', reviewId)
          .single();

      await _client.from('reviews').delete().eq('id', reviewId);

      // Update product rating
      await _updateProductRating(review['product_id']);
    } catch (e) {
      throw ServerException('فشل في حذف التقييم: ${e.toString()}');
    }
  }

  Future<void> _updateProductRating(String productId) async {
    try {
      // Calculate average rating and count
      final result = await _client
          .from('reviews')
          .select('rating')
          .eq('product_id', productId);

      final reviews = List<Map<String, dynamic>>.from(result);

      if (reviews.isEmpty) {
        await _client.from('products').update({
          'rating': 0.0,
          'rating_count': 0,
        }).eq('id', productId);
      } else {
        final totalRating =
            reviews.fold<int>(0, (sum, r) => sum + (r['rating'] as int));
        final avgRating = totalRating / reviews.length;

        await _client.from('products').update({
          'rating': double.parse(avgRating.toStringAsFixed(1)),
          'rating_count': reviews.length,
        }).eq('id', productId);
      }
    } catch (e) {
      // Log error but don't throw - review was already added
      print('Failed to update product rating: $e');
    }
  }
}
