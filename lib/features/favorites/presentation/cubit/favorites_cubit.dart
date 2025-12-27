import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import '../../../../core/services/network_error_handler.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../../../favorites/data/datasources/favorites_remote_datasource.dart';
import 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  final FavoritesRepository _repository;
  final FavoritesRemoteDataSource _dataSource;
  final _logger = Logger();
  String? _userId;
  String _locale = 'ar';
  bool _isLoading = false;
  static const int _pageSize = 10;

  FavoritesCubit(this._repository, this._dataSource)
      : super(FavoritesInitial());

  void setLocale(String locale) {
    _locale = locale;
    _repository.setLocale(locale);
  }

  void setUserId(String userId) {
    if (_userId == userId && state is FavoritesLoaded) return; // Already loaded
    _userId = userId;
    loadFavorites(userId);
  }

  Future<void> loadFavorites(String userId, {bool showLoading = true}) async {
    // Prevent duplicate loading
    if (_isLoading) return;
    _isLoading = true;

    _userId = userId;

    // Only show loading if not already loaded
    if (showLoading && state is! FavoritesLoaded) {
      emit(FavoritesLoading());
    }

    final result = await _repository.getFavorites(userId,
        locale: _locale, page: 0, limit: _pageSize);

    _isLoading = false;

    result.fold(
      (failure) {
        _logger.e('❌ Failed to load favorites: ${failure.message}');
        NetworkErrorHandler.handleError(failure.message);
        emit(FavoritesError(failure.message));
      },
      (favorites) {
        final productIds = favorites.map((f) => f.productId).toSet();
        _logger.d('✅ Loaded ${favorites.length} favorites');
        emit(FavoritesLoaded(
          favorites: favorites,
          favoriteProductIds: productIds,
          hasMore: favorites.length >= _pageSize,
          currentPage: 0,
        ));
      },
    );
  }

  /// Load more favorites (pagination)
  Future<void> loadMoreFavorites() async {
    if (_userId == null) return;

    final currentState = state;
    if (currentState is! FavoritesLoaded) return;
    if (currentState.isLoadingMore || !currentState.hasMore) return;

    emit(currentState.copyWith(isLoadingMore: true));

    final nextPage = currentState.currentPage + 1;

    final result = await _repository.getFavorites(_userId!,
        locale: _locale, page: nextPage, limit: _pageSize);

    result.fold(
      (failure) {
        emit(currentState.copyWith(isLoadingMore: false));
      },
      (newFavorites) {
        final allFavorites = [...currentState.favorites, ...newFavorites];
        final productIds = allFavorites.map((f) => f.productId).toSet();
        emit(currentState.copyWith(
          favorites: allFavorites,
          favoriteProductIds: productIds,
          hasMore: newFavorites.length >= _pageSize,
          currentPage: nextPage,
          isLoadingMore: false,
        ));
      },
    );
  }

  Future<bool> toggleFavorite(String productId) async {
    if (_userId == null) {
      _logger.w('⚠️ No user ID set for favorites');
      return false;
    }

    final currentState = state;
    if (currentState is FavoritesLoaded) {
      final isFav = currentState.isFavorite(productId);

      if (isFav) {
        return await _removeFromFavorites(productId, currentState);
      } else {
        return await _addToFavorites(productId, currentState);
      }
    }
    return false;
  }

  Future<bool> _addToFavorites(
      String productId, FavoritesLoaded currentState) async {
    // Optimistic update - just update the product IDs for now
    final newProductIds = {...currentState.favoriteProductIds, productId};
    emit(FavoritesLoaded(
      favorites: currentState.favorites,
      favoriteProductIds: newProductIds,
    ));

    final result = await _repository.addToFavorites(_userId!, productId);

    return result.fold(
      (failure) {
        _logger.e('❌ Failed to add to favorites: ${failure.message}');
        NetworkErrorHandler.handleError(failure.message);
        // Revert on failure
        emit(currentState);
        return false;
      },
      (_) {
        _logger.d('✅ Added to favorites: $productId');
        // Reload to get the full favorite with product data (without showing loading)
        loadFavorites(_userId!, showLoading: false);
        return true;
      },
    );
  }

  Future<bool> _removeFromFavorites(
      String productId, FavoritesLoaded currentState) async {
    // Optimistic update
    final newFavorites =
        currentState.favorites.where((f) => f.productId != productId).toList();
    final newProductIds = {...currentState.favoriteProductIds}
      ..remove(productId);

    emit(FavoritesLoaded(
      favorites: newFavorites,
      favoriteProductIds: newProductIds,
    ));

    // Remove by product ID
    try {
      await _dataSource.removeByProductId(_userId!, productId);
      _logger.d('✅ Removed from favorites: $productId');
      return true;
    } catch (e) {
      _logger.e('❌ Failed to remove from favorites: $e');
      NetworkErrorHandler.handleError(e);
      // Revert on failure
      emit(currentState);
      return false;
    }
  }

  bool isFavorite(String productId) {
    final currentState = state;
    if (currentState is FavoritesLoaded) {
      return currentState.isFavorite(productId);
    }
    return false;
  }

  /// Reset state and force reload - used when language changes
  Future<void> reset() async {
    _isLoading = false;
    emit(FavoritesInitial());
    if (_userId != null) {
      await loadFavorites(_userId!);
    }
  }
}
