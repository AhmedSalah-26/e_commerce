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

  const FavoritesLoaded({
    required this.favorites,
    required this.favoriteProductIds,
  });

  @override
  List<Object?> get props => [favorites, favoriteProductIds];

  bool isFavorite(String productId) => favoriteProductIds.contains(productId);
}

class FavoritesError extends FavoritesState {
  final String message;

  const FavoritesError(this.message);

  @override
  List<Object?> get props => [message];
}
