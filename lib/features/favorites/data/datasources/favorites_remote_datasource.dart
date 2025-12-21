import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/favorite_model.dart';

abstract class FavoritesRemoteDataSource {
  Future<List<FavoriteModel>> getFavorites(String userId);
  Future<void> addToFavorites(String userId, String productId);
  Future<void> removeFromFavorites(String favoriteId);
  Future<bool> isFavorite(String userId, String productId);
  Future<void> removeByProductId(String userId, String productId);
}

class FavoritesRemoteDataSourceImpl implements FavoritesRemoteDataSource {
  final SupabaseClient _client;
  final _logger = Logger();

  FavoritesRemoteDataSourceImpl(this._client);

  @override
  Future<List<FavoriteModel>> getFavorites(String userId) async {
    try {
      _logger.d('🔍 Getting favorites for user: $userId');

      final response = await _client
          .from('favorites')
          .select('*, products(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final favorites = (response as List)
          .map((json) => FavoriteModel.fromJson(json))
          .toList();

      _logger.d('✅ Found ${favorites.length} favorites');
      return favorites;
    } catch (e) {
      _logger.e('❌ Error getting favorites: $e');
      rethrow;
    }
  }

  @override
  Future<void> addToFavorites(String userId, String productId) async {
    try {
      _logger.d('➕ Adding to favorites: product $productId for user $userId');

      await _client.from('favorites').insert({
        'user_id': userId,
        'product_id': productId,
      });

      _logger.d('✅ Added to favorites successfully');
    } catch (e) {
      _logger.e('❌ Error adding to favorites: $e');
      rethrow;
    }
  }

  @override
  Future<void> removeFromFavorites(String favoriteId) async {
    try {
      _logger.d('➖ Removing favorite: $favoriteId');

      await _client.from('favorites').delete().eq('id', favoriteId);

      _logger.d('✅ Removed from favorites successfully');
    } catch (e) {
      _logger.e('❌ Error removing from favorites: $e');
      rethrow;
    }
  }

  @override
  Future<void> removeByProductId(String userId, String productId) async {
    try {
      _logger.d('➖ Removing favorite by product: $productId for user $userId');

      await _client
          .from('favorites')
          .delete()
          .eq('user_id', userId)
          .eq('product_id', productId);

      _logger.d('✅ Removed from favorites successfully');
    } catch (e) {
      _logger.e('❌ Error removing from favorites: $e');
      rethrow;
    }
  }

  @override
  Future<bool> isFavorite(String userId, String productId) async {
    try {
      final response = await _client
          .from('favorites')
          .select('id')
          .eq('user_id', userId)
          .eq('product_id', productId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      _logger.e('❌ Error checking favorite: $e');
      return false;
    }
  }
}
