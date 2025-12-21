import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../../../favorites/data/datasources/favorites_remote_datasource.dart';
import 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  final FavoritesRepository _repository;
  final FavoritesRemoteDataSource _dataSource;
  final _logger = Logger();
  String? _userId;
  String _locale = 'ar';

  FavoritesCubit(this._repository, this._dataSource)
      : super(FavoritesInitial());

  void setLocale(String locale) {
    _locale = locale;
    _repository.setLocale(locale);
  }

  void setUserId(String userId) {
    if (_userId == userId) return; // Already set
    _userId = userId;
    loadFavorites(userId);
  }

  Future<void> loadFavorites(String userId) async {
    emit(FavoritesLoading());

    final result = await _repository.getFavorites(userId, locale: _locale);

    result.fold(
      (failure) {
        _logger.e('❌ Failed to load favorites: ${failure.message}');
        emit(FavoritesError(failure.message));
      },
      (favorites) {
        final productIds = favorites.map((f) => f.productId).toSet();
        _logger.d('✅ Loaded ${favorites.length} favorites');
        emit(FavoritesLoaded(
          favorites: favorites,
          favoriteProductIds: productIds,
        ));
      },
    );
  }

  Future<void> toggleFavorite(String productId) async {
    if (_userId == null) {
      _logger.w('⚠️ No user ID set for favorites');
      return;
    }

    final currentState = state;
    if (currentState is FavoritesLoaded) {
      final isFav = currentState.isFavorite(productId);

      if (isFav) {
        await _removeFromFavorites(productId, currentState);
      } else {
        await _addToFavorites(productId, currentState);
      }
    }
  }

  Future<void> _addToFavorites(
      String productId, FavoritesLoaded currentState) async {
    // Optimistic update
    final newProductIds = {...currentState.favoriteProductIds, productId};
    emit(FavoritesLoaded(
      favorites: currentState.favorites,
      favoriteProductIds: newProductIds,
    ));

    final result = await _repository.addToFavorites(_userId!, productId);

    result.fold(
      (failure) {
        _logger.e('❌ Failed to add to favorites: ${failure.message}');
        // Revert on failure
        emit(currentState);
      },
      (_) {
        _logger.d('✅ Added to favorites: $productId');
        // Don't reload - optimistic update is enough for UI
      },
    );
  }

  Future<void> _removeFromFavorites(
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
    } catch (e) {
      _logger.e('❌ Failed to remove from favorites: $e');
      // Revert on failure
      emit(currentState);
    }
  }

  bool isFavorite(String productId) {
    final currentState = state;
    if (currentState is FavoritesLoaded) {
      return currentState.isFavorite(productId);
    }
    return false;
  }
}
