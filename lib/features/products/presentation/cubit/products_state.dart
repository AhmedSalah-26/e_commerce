import 'package:equatable/equatable.dart';
import '../../domain/entities/product_entity.dart';

/// Base class for all products states
abstract class ProductsState extends Equatable {
  const ProductsState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ProductsInitial extends ProductsState {
  const ProductsInitial();
}

/// Loading state (first load)
class ProductsLoading extends ProductsState {
  const ProductsLoading();
}

/// Loaded state with products
class ProductsLoaded extends ProductsState {
  final List<ProductEntity> products;
  final String? selectedCategoryId;
  final String? searchQuery;
  final bool hasMore;
  final int currentPage;
  final bool isLoadingMore;
  final bool isOffersMode;

  const ProductsLoaded({
    required this.products,
    this.selectedCategoryId,
    this.searchQuery,
    this.hasMore = true,
    this.currentPage = 0,
    this.isLoadingMore = false,
    this.isOffersMode = false,
  });

  @override
  List<Object?> get props => [
        products,
        selectedCategoryId,
        searchQuery,
        hasMore,
        currentPage,
        isLoadingMore,
        isOffersMode,
      ];

  ProductsLoaded copyWith({
    List<ProductEntity>? products,
    String? selectedCategoryId,
    String? searchQuery,
    bool? hasMore,
    int? currentPage,
    bool? isLoadingMore,
    bool? isOffersMode,
  }) {
    return ProductsLoaded(
      products: products ?? this.products,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      searchQuery: searchQuery ?? this.searchQuery,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isOffersMode: isOffersMode ?? this.isOffersMode,
    );
  }

  /// Create a copy with cleared search
  ProductsLoaded clearSearch() {
    return ProductsLoaded(
      products: products,
      selectedCategoryId: selectedCategoryId,
      searchQuery: null,
      hasMore: hasMore,
      currentPage: currentPage,
      isLoadingMore: isLoadingMore,
      isOffersMode: isOffersMode,
    );
  }
}

/// Error state
class ProductsError extends ProductsState {
  final String message;

  const ProductsError(this.message);

  @override
  List<Object?> get props => [message];
}
