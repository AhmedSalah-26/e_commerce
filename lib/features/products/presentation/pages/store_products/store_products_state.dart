import 'package:flutter/material.dart';
import '../../../domain/entities/product_entity.dart';

/// State class for store products screen
class StoreProductsState {
  List<ProductEntity> products = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  bool hasMore = true;
  String? error;

  // Store info
  String? storeName;
  String? storeDescription;
  String? storeAddress;
  String? storePhone;
  String? storeLogo;

  // Pagination
  int currentPage = 0;
  static const int pageSize = 20;

  // Filter state
  String searchQuery = '';
  String? selectedCategoryId;
  RangeValues priceRange = const RangeValues(0, 10000);
  double minPrice = 0;
  double maxPrice = 10000;

  List<ProductEntity> get filteredProducts {
    var filtered = products;

    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered
          .where((p) =>
              p.name.toLowerCase().contains(query) ||
              p.description.toLowerCase().contains(query))
          .toList();
    }

    if (selectedCategoryId != null) {
      filtered =
          filtered.where((p) => p.categoryId == selectedCategoryId).toList();
    }

    filtered = filtered.where((p) {
      final price = p.effectivePrice;
      return price >= priceRange.start && price <= priceRange.end;
    }).toList();

    return filtered;
  }

  bool get hasActiveFilters =>
      selectedCategoryId != null ||
      priceRange.start > minPrice ||
      priceRange.end < maxPrice;

  void updateStoreInfo(List<ProductEntity> products) {
    if (products.isNotEmpty) {
      storeName ??= products.first.storeName;
      storeDescription ??= products.first.storeDescription;
      storeAddress ??= products.first.storeAddress;
      storePhone ??= products.first.storePhone;
      storeLogo ??= products.first.storeLogo;
    }
  }

  void updatePriceRange(List<ProductEntity> products) {
    if (products.isNotEmpty) {
      final prices = products.map((p) => p.effectivePrice).toList();
      minPrice = prices.reduce((a, b) => a < b ? a : b);
      maxPrice = prices.reduce((a, b) => a > b ? a : b);
      priceRange = RangeValues(minPrice, maxPrice);
    }
  }

  void clearFilters(TextEditingController searchController) {
    searchController.clear();
    searchQuery = '';
    selectedCategoryId = null;
    priceRange = RangeValues(minPrice, maxPrice);
  }
}
