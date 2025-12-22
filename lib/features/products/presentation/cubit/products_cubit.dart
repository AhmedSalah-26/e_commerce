import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import 'products_state.dart';

/// Cubit for managing products state
class ProductsCubit extends Cubit<ProductsState> {
  final ProductRepository _repository;
  static const int _pageSize = 10;
  Timer? _debounceTimer;
  bool _isLoading = false;

  ProductsCubit({required ProductRepository repository})
      : _repository = repository,
        super(const ProductsInitial());

  /// Set the locale for fetching products
  void setLocale(String locale) {
    if (_repository is ProductRepositoryImpl) {
      _repository.setLocale(locale);
    }
  }

  /// Load all products (first page)
  Future<void> loadProducts({bool forceReload = false}) async {
    // Prevent duplicate loading
    if (_isLoading) return;

    // Skip if already loaded and not forcing reload
    if (!forceReload && state is ProductsLoaded) {
      final loaded = state as ProductsLoaded;
      if (loaded.selectedCategoryId == null &&
          loaded.searchQuery == null &&
          !loaded.isOffersMode) {
        return;
      }
    }

    _isLoading = true;
    emit(const ProductsLoading());

    final result = await _repository.getProducts(page: 0, limit: _pageSize);

    _isLoading = false;
    result.fold(
      (failure) => emit(ProductsError(failure.message)),
      (products) => emit(ProductsLoaded(
        products: products,
        hasMore: products.length >= _pageSize,
        currentPage: 0,
      )),
    );
  }

  /// Load more products (pagination)
  Future<void> loadMoreProducts() async {
    final currentState = state;
    if (currentState is! ProductsLoaded) return;
    if (currentState.isLoadingMore || !currentState.hasMore) return;

    emit(currentState.copyWith(isLoadingMore: true));

    final nextPage = currentState.currentPage + 1;

    final result = currentState.searchQuery != null
        ? await _repository.searchProducts(
            currentState.searchQuery!,
            page: nextPage,
            limit: _pageSize,
            categoryId: currentState.selectedCategoryId,
          )
        : currentState.selectedCategoryId != null
            ? await _repository.getProductsByCategory(
                currentState.selectedCategoryId!,
                page: nextPage,
                limit: _pageSize,
              )
            : await _repository.getProducts(page: nextPage, limit: _pageSize);

    result.fold(
      (failure) => emit(currentState.copyWith(isLoadingMore: false)),
      (newProducts) => emit(currentState.copyWith(
        products: [...currentState.products, ...newProducts],
        hasMore: newProducts.length >= _pageSize,
        currentPage: nextPage,
        isLoadingMore: false,
      )),
    );
  }

  /// Load products by category
  Future<void> loadProductsByCategory(String categoryId) async {
    emit(const ProductsLoading());

    final result = await _repository.getProductsByCategory(
      categoryId,
      page: 0,
      limit: _pageSize,
    );

    result.fold(
      (failure) => emit(ProductsError(failure.message)),
      (products) => emit(ProductsLoaded(
        products: products,
        selectedCategoryId: categoryId,
        hasMore: products.length >= _pageSize,
        currentPage: 0,
      )),
    );
  }

  /// Search products with debounce (1 second delay)
  void searchProducts(String query) {
    _debounceTimer?.cancel();

    if (query.isEmpty) {
      // Clear search immediately
      final currentState = state;
      if (currentState is ProductsLoaded &&
          currentState.selectedCategoryId != null) {
        loadProductsByCategory(currentState.selectedCategoryId!);
      } else {
        loadProducts();
      }
      return;
    }

    _debounceTimer = Timer(const Duration(seconds: 1), () {
      _executeSearch(query);
    });
  }

  /// Execute search immediately (without debounce)
  Future<void> _executeSearch(String query) async {
    final currentState = state;
    String? categoryId;
    if (currentState is ProductsLoaded) {
      categoryId = currentState.selectedCategoryId;
    }

    emit(const ProductsLoading());

    final result = await _repository.searchProducts(
      query,
      page: 0,
      limit: _pageSize,
      categoryId: categoryId,
    );

    result.fold(
      (failure) => emit(ProductsError(failure.message)),
      (products) => emit(ProductsLoaded(
        products: products,
        selectedCategoryId: categoryId,
        searchQuery: query,
        hasMore: products.length >= _pageSize,
        currentPage: 0,
      )),
    );
  }

  /// Clear search and reload products
  Future<void> clearSearch() async {
    _debounceTimer?.cancel();
    final currentState = state;
    if (currentState is ProductsLoaded &&
        currentState.selectedCategoryId != null) {
      await loadProductsByCategory(currentState.selectedCategoryId!);
    } else {
      await loadProducts();
    }
  }

  /// Clear category filter and load all products
  Future<void> clearCategoryFilter() async {
    await loadProducts();
  }

  /// Load products with discount (offers)
  Future<void> loadDiscountedProducts() async {
    emit(const ProductsLoading());

    final result = await _repository.getDiscountedProducts(
      page: 0,
      limit: _pageSize,
    );

    result.fold(
      (failure) => emit(ProductsError(failure.message)),
      (products) => emit(ProductsLoaded(
        products: products,
        hasMore: products.length >= _pageSize,
        currentPage: 0,
        isOffersMode: true,
      )),
    );
  }

  /// Load more discounted products (pagination for offers)
  Future<void> loadMoreDiscountedProducts() async {
    final currentState = state;
    if (currentState is! ProductsLoaded) return;
    if (currentState.isLoadingMore || !currentState.hasMore) return;
    if (!currentState.isOffersMode) return;

    emit(currentState.copyWith(isLoadingMore: true));

    final nextPage = currentState.currentPage + 1;

    final result = await _repository.getDiscountedProducts(
      page: nextPage,
      limit: _pageSize,
    );

    result.fold(
      (failure) => emit(currentState.copyWith(isLoadingMore: false)),
      (newProducts) => emit(currentState.copyWith(
        products: [...currentState.products, ...newProducts],
        hasMore: newProducts.length >= _pageSize,
        currentPage: nextPage,
        isLoadingMore: false,
      )),
    );
  }

  /// Refresh products
  Future<void> refresh() async {
    final currentState = state;
    if (currentState is ProductsLoaded) {
      if (currentState.searchQuery != null) {
        await _executeSearch(currentState.searchQuery!);
      } else if (currentState.selectedCategoryId != null) {
        await loadProductsByCategory(currentState.selectedCategoryId!);
      } else {
        await loadProducts();
      }
    } else {
      await loadProducts();
    }
  }

  /// Get a single product by ID with full details (including store info)
  Future<ProductEntity?> getProductById(String productId) async {
    final result = await _repository.getProductById(productId);
    return result.fold(
      (failure) => null,
      (product) => product,
    );
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
