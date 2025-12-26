import 'package:flutter/material.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../domain/repositories/product_repository.dart';
import 'store_products_state.dart';

/// Mixin containing business logic for store products
mixin StoreProductsLogic<T extends StatefulWidget> on State<T> {
  late final StoreProductsState storeState;
  late final TextEditingController searchController;
  late final ScrollController scrollController;
  late String merchantId;

  void initLogic(String merchantId, String? initialStoreName) {
    this.merchantId = merchantId;
    storeState = StoreProductsState();
    storeState.storeName = initialStoreName;
    searchController = TextEditingController();
    scrollController = ScrollController();
    scrollController.addListener(_onScroll);
    loadProducts();
  }

  void disposeLogic() {
    searchController.dispose();
    scrollController.dispose();
  }

  void _onScroll() {
    if (_isBottom && !storeState.isLoadingMore && storeState.hasMore) {
      loadMoreProducts();
    }
  }

  bool get _isBottom {
    if (!scrollController.hasClients) return false;
    final maxScroll = scrollController.position.maxScrollExtent;
    return scrollController.offset >= (maxScroll - 200);
  }

  Future<void> loadProducts() async {
    setState(() {
      storeState.isLoading = true;
      storeState.error = null;
      storeState.currentPage = 0;
      storeState.hasMore = true;
    });

    try {
      final result = await sl<ProductRepository>().getProductsByMerchant(
        merchantId,
        page: 0,
        limit: StoreProductsState.pageSize,
      );

      result.fold(
        (failure) {
          if (mounted) {
            setState(() {
              storeState.error = failure.message;
              storeState.isLoading = false;
            });
          }
        },
        (products) {
          if (mounted) {
            storeState.updateStoreInfo(products);
            storeState.updatePriceRange(products);
            setState(() {
              storeState.products = products;
              storeState.isLoading = false;
              storeState.hasMore =
                  products.length >= StoreProductsState.pageSize;
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          storeState.error = e.toString();
          storeState.isLoading = false;
        });
      }
    }
  }

  Future<void> loadMoreProducts() async {
    if (storeState.isLoadingMore || !storeState.hasMore) return;
    setState(() => storeState.isLoadingMore = true);

    try {
      final result = await sl<ProductRepository>().getProductsByMerchant(
        merchantId,
        page: storeState.currentPage + 1,
        limit: StoreProductsState.pageSize,
      );

      result.fold(
        (_) {
          if (mounted) setState(() => storeState.isLoadingMore = false);
        },
        (newProducts) {
          if (mounted) {
            if (newProducts.isNotEmpty) {
              final allProducts = [...storeState.products, ...newProducts];
              final prices = allProducts.map((p) => p.effectivePrice).toList();
              storeState.minPrice = prices.reduce((a, b) => a < b ? a : b);
              storeState.maxPrice = prices.reduce((a, b) => a > b ? a : b);
            }
            setState(() {
              storeState.products.addAll(newProducts);
              storeState.currentPage++;
              storeState.isLoadingMore = false;
              storeState.hasMore =
                  newProducts.length >= StoreProductsState.pageSize;
            });
          }
        },
      );
    } catch (_) {
      if (mounted) setState(() => storeState.isLoadingMore = false);
    }
  }

  void updateSearchQuery(String value) {
    setState(() => storeState.searchQuery = value);
  }

  void clearSearch() {
    searchController.clear();
    setState(() => storeState.searchQuery = '');
  }

  void applyFilters(String? categoryId, RangeValues priceRange) {
    setState(() {
      storeState.selectedCategoryId = categoryId;
      storeState.priceRange = priceRange;
    });
  }

  void clearAllFilters() {
    setState(() => storeState.clearFilters(searchController));
  }
}
