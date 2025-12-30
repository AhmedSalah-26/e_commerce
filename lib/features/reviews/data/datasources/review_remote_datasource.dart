import 'package:flutter/foundation.dart';
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
      debugPrint('📝 Getting reviews for product: $productId');
      final response = await _client
          .rpc('get_product_reviews', params: {'p_product_id': productId});

      debugPrint('✅ Got ${(response as List).length} reviews');
      return (response)
          .map((json) => ReviewModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      debugPrint('❌ Error getting reviews: $e');
      debugPrint('Stack: $stackTrace');
      throw ServerException('فشل في جلب التقييمات: ${e.toString()}');
    }
  }

  @override
  Future<ReviewModel?> getUserReview(String productId, String userId) async {
    try {
      debugPrint('📝 Getting user review - product: $productId, user: $userId');
      final response = await _client
          .from('reviews')
          .select('*, profiles(name)')
          .eq('product_id', productId)
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) {
        debugPrint('ℹ️ No existing review found');
        return null;
      }

      debugPrint('✅ Found user review: ${response['id']}');
      return ReviewModel(
        id: response['id'],
        productId: response['product_id'],
        userId: response['user_id'],
        userName: response['profiles']?['name'] ?? 'مستخدم',
        rating: response['rating'],
        comment: response['comment'],
        createdAt: DateTime.parse(response['created_at']),
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Error getting user review: $e');
      debugPrint('Stack: $stackTrace');
      throw ServerException('فشل في جلب تقييمك: ${e.toString()}');
    }
  }

  @override
  Future<void> addReview(
      String productId, String userId, int rating, String? comment) async {
    try {
      debugPrint('📝 Adding review...');
      debugPrint('  Product: $productId');
      debugPrint('  User: $userId');
      debugPrint('  Rating: $rating');
      debugPrint('  Comment: ${comment ?? "(no comment)"}');

      await _client.from('reviews').insert({
        'product_id': productId,
        'user_id': userId,
        'rating': rating,
        'comment': comment,
      });

      debugPrint('✅ Review inserted successfully');

      // Update product rating and rating_count
      debugPrint('📊 Updating product rating...');
      await _updateProductRating(productId);
      debugPrint('✅ Product rating updated');
    } catch (e, stackTrace) {
      debugPrint('❌ Error adding review: $e');
      debugPrint('Stack: $stackTrace');
      throw ServerException('فشل في إضافة التقييم: ${e.toString()}');
    }
  }

  @override
  Future<void> updateReview(
      String reviewId, int rating, String? comment) async {
    try {
      debugPrint('📝 Updating review: $reviewId');
      debugPrint('  Rating: $rating');
      debugPrint('  Comment: ${comment ?? "(no comment)"}');

      // Get product_id before update
      final review = await _client
          .from('reviews')
          .select('product_id')
          .eq('id', reviewId)
          .single();

      debugPrint('  Product ID: ${review['product_id']}');

      await _client.from('reviews').update({
        'rating': rating,
        'comment': comment,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', reviewId);

      debugPrint('✅ Review updated successfully');

      // Update product rating
      debugPrint('📊 Updating product rating...');
      await _updateProductRating(review['product_id']);
      debugPrint('✅ Product rating updated');
    } catch (e, stackTrace) {
      debugPrint('❌ Error updating review: $e');
      debugPrint('Stack: $stackTrace');
      throw ServerException('فشل في تحديث التقييم: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteReview(String reviewId) async {
    try {
      debugPrint('🗑️ Deleting review: $reviewId');

      // Get product_id before delete
      final review = await _client
          .from('reviews')
          .select('product_id')
          .eq('id', reviewId)
          .single();

      debugPrint('  Product ID: ${review['product_id']}');

      await _client.from('reviews').delete().eq('id', reviewId);

      debugPrint('✅ Review deleted successfully');

      // Update product rating
      debugPrint('📊 Updating product rating...');
      await _updateProductRating(review['product_id']);
      debugPrint('✅ Product rating updated');
    } catch (e, stackTrace) {
      debugPrint('❌ Error deleting review: $e');
      debugPrint('Stack: $stackTrace');
      throw ServerException('فشل في حذف التقييم: ${e.toString()}');
    }
  }

  Future<void> _updateProductRating(String productId) async {
    try {
      debugPrint('📊 Calculating new rating for product: $productId');

      // Calculate average rating and count
      final result = await _client
          .from('reviews')
          .select('rating')
          .eq('product_id', productId);

      final reviews = List<Map<String, dynamic>>.from(result);
      debugPrint('  Total reviews: ${reviews.length}');

      if (reviews.isEmpty) {
        debugPrint('  No reviews, setting rating to 0');
        await _client.from('products').update({
          'rating': 0.0,
          'rating_count': 0,
        }).eq('id', productId);
      } else {
        final totalRating =
            reviews.fold<int>(0, (sum, r) => sum + (r['rating'] as int));
        final avgRating = totalRating / reviews.length;
        debugPrint('  Average rating: ${avgRating.toStringAsFixed(1)}');

        await _client.from('products').update({
          'rating': double.parse(avgRating.toStringAsFixed(1)),
          'rating_count': reviews.length,
        }).eq('id', productId);
      }

      debugPrint('✅ Product rating calculation complete');
    } catch (e, stackTrace) {
      // Log error but don't throw - review was already added
      debugPrint('⚠️ Failed to update product rating: $e');
      debugPrint('Stack: $stackTrace');
    }
  }
}
