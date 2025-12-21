import 'package:equatable/equatable.dart';
import '../../domain/entities/category_entity.dart';

/// Base class for all categories states
abstract class CategoriesState extends Equatable {
  const CategoriesState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class CategoriesInitial extends CategoriesState {
  const CategoriesInitial();
}

/// Loading state
class CategoriesLoading extends CategoriesState {
  const CategoriesLoading();
}

/// Loaded state with categories
class CategoriesLoaded extends CategoriesState {
  final List<CategoryEntity> categories;

  const CategoriesLoaded(this.categories);

  @override
  List<Object?> get props => [categories];
}

/// Error state
class CategoriesError extends CategoriesState {
  final String message;

  const CategoriesError(this.message);

  @override
  List<Object?> get props => [message];
}
