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

  ProductsCubit({required ProductRepository repository})
      : _repository = repository,
        super(const ProductsInitial());

  /// Set the locale for fetching products
  void setLocale(String locale) {
    if (_repository is ProductRepositoryImpl) {
      _repository.setLocale(locale);
    }
  }

  /// Minimum loading duration for shimmer visibility
  static const Duration _minLoadingDuration = Duration(milliseconds: 400);

  /// Helper to ensure minimum loading time for shimmer visibility
  Future<T> _withMinLoadingTime<T>(Future<T> Function() operation) async {
    final stopwatch = Stopwatch()..start();
    final result = await operation();
    final elapsed = stopwatch.elapsed;
    if (elapsed < _minLoadingDuration) {
      await Future.delayed(_minLoadingDuration - elapsed);
    }
    return result;
  }

  /// Load all products (first page)
  Future<void> loadProducts({bool forceReload = false}) async {
    // Skip if already loaded and not forcing reload
    if (!forceReload && state is ProductsLoaded) {
      final loaded = state as ProductsLoaded;
      if (loaded.selectedCategoryId == null &&
          loaded.searchQuery == null &&
          !loaded.isOffersMode &&
          !loaded.isBestSellersMode &&
          !loaded.isTopRatedMode) {
        return;
      }
    }

    emit(const ProductsLoading());

    final result = await _withMinLoadingTime(
      () => _repository.getProducts(page: 0, limit: _pageSize),
    );

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

    final result = await _withMinLoadingTime(
      () => _repository.getProductsByCategory(
        categoryId,
        page: 0,
        limit: _pageSize,
      ),
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

    final result = await _withMinLoadingTime(
      () => _repository.searchProducts(
        query,
        page: 0,
        limit: _pageSize,
        categoryId: categoryId,
      ),
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

  /// Load products with discount (offers) - sorted by highest discount
  Future<void> loadDiscountedProducts() async {
    emit(const ProductsLoading());

    final result = await _withMinLoadingTime(
      () => _repository.getDiscountedProducts(
        page: 0,
        limit: _pageSize,
      ),
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

  /// Load flash sale products only (is_flash_sale = true)
  Future<void> loadFlashSaleProducts() async {
    emit(const ProductsLoading());

    final result = await _withMinLoadingTime(
      () => _repository.getFlashSaleProducts(limit: _pageSize),
    );

    result.fold(
      (failure) => emit(ProductsError(failure.message)),
      (products) => emit(ProductsLoaded(
        products: products,
        hasMore: false, // Flash sale doesn't have pagination
        currentPage: 0,
        isFlashSaleMode: true,
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

  /// Load best selling products
  Future<void> loadBestSellingProducts() async {
    emit(const ProductsLoading());

    final result = await _withMinLoadingTime(
      () => _repository.getBestSellingProducts(
        page: 0,
        limit: _pageSize,
      ),
    );

    result.fold(
      (failure) => emit(ProductsError(failure.message)),
      (products) => emit(ProductsLoaded(
        products: products,
        hasMore: products.length >= _pageSize,
        currentPage: 0,
        isBestSellersMode: true,
      )),
    );
  }

  /// Load more best selling products (pagination)
  Future<void> loadMoreBestSellingProducts() async {
    final currentState = state;
    if (currentState is! ProductsLoaded) return;
    if (currentState.isLoadingMore || !currentState.hasMore) return;
    if (!currentState.isBestSellersMode) return;

    emit(currentState.copyWith(isLoadingMore: true));

    final nextPage = currentState.currentPage + 1;

    final result = await _repository.getBestSellingProducts(
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

  /// Load top rated products
  Future<void> loadTopRatedProducts() async {
    emit(const ProductsLoading());

    final result = await _withMinLoadingTime(
      () => _repository.getTopRatedProducts(
        page: 0,
        limit: _pageSize,
      ),
    );

    result.fold(
      (failure) => emit(ProductsError(failure.message)),
      (products) => emit(ProductsLoaded(
        products: products,
        hasMore: products.length >= _pageSize,
        currentPage: 0,
        isTopRatedMode: true,
      )),
    );
  }

  /// Load more top rated products (pagination)
  Future<void> loadMoreTopRatedProducts() async {
    final currentState = state;
    if (currentState is! ProductsLoaded) return;
    if (currentState.isLoadingMore || !currentState.hasMore) return;
    if (!currentState.isTopRatedMode) return;

    emit(currentState.copyWith(isLoadingMore: true));

    final nextPage = currentState.currentPage + 1;

    final result = await _repository.getTopRatedProducts(
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
        await loadProducts(forceReload: true);
      }
    } else {
      await loadProducts(forceReload: true);
    }
  }

  /// Reset state and force reload - used when language changes
  Future<void> reset() async {
    emit(const ProductsInitial());
    await loadProducts(forceReload: true);
  }

  /// Get a single product by ID with full details (including store info)
  Future<ProductEntity?> getProductById(String productId) async {
    print('🔍 ProductsCubit.getProductById: $productId');
    final result = await _repository.getProductById(productId);
    return result.fold(
      (failure) {
        print('❌ getProductById failed: ${failure.message}');
        return null;
      },
      (product) {
        print('✅ getProductById success: ${product.name}');
        return product;
      },
    );
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
