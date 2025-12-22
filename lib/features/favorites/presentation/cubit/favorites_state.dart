import 'package:equatable/equatable.dart';
import '../../domain/entities/favorite_entity.dart';

abstract class FavoritesState extends Equatable {
  const FavoritesState();

  @override
  List<Object?> get props => [];
}

class FavoritesInitial extends FavoritesState {}

class FavoritesLoading extends FavoritesState {}

class FavoritesLoaded extends FavoritesState {
  final List<FavoriteEntity> favorites;
  final Set<String> favoriteProductIds;
  final bool hasMore;
  final int currentPage;
  final bool isLoadingMore;

  const FavoritesLoaded({
    required this.favorites,
    required this.favoriteProductIds,
    this.hasMore = true,
    this.currentPage = 0,
    this.isLoadingMore = false,
  });

  @override
  List<Object?> get props =>
      [favorites, favoriteProductIds, hasMore, currentPage, isLoadingMore];

  bool isFavorite(String productId) => favoriteProductIds.contains(productId);

  FavoritesLoaded copyWith({
    List<FavoriteEntity>? favorites,
    Set<String>? favoriteProductIds,
    bool? hasMore,
    int? currentPage,
    bool? isLoadingMore,
  }) {
    return FavoritesLoaded(
      favorites: favorites ?? this.favorites,
      favoriteProductIds: favoriteProductIds ?? this.favoriteProductIds,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class FavoritesError extends FavoritesState {
  final String message;

  const FavoritesError(this.message);

  @override
  List<Object?> get props => [message];
}
