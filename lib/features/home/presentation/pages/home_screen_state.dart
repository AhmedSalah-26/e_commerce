import 'dart:async';
import 'package:flutter/material.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../../products/domain/repositories/product_repository.dart';

/// Mixin for managing home screen search state
mixin HomeScreenSearchState<T extends StatefulWidget> on State<T> {
  // Search state
  bool isSearchMode = false;
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();
  Timer? debounceTimer;
  List<ProductEntity> searchResults = [];
  bool isSearching = false;
  bool isLoadingMoreSearch = false;
  bool hasMoreSearch = true;
  int searchPage = 0;
  String currentQuery = '';
  static const int pageSize = 10;

  // Filter state
  String? filterCategoryId;
  final double minPrice = 0;
  final double maxPrice = 10000;
  RangeValues priceRange = const RangeValues(0, 10000);
  bool hasActiveFilters = false;

  void enterSearchMode() {
    setState(() {
      isSearchMode = true;
    });
    searchFocusNode.requestFocus();
  }

  void exitSearchMode() {
    setState(() {
      isSearchMode = false;
      searchController.clear();
      searchResults = [];
      currentQuery = '';
      isSearching = false;
      hasMoreSearch = true;
      searchPage = 0;
    });
    searchFocusNode.unfocus();
  }

  void onSearchChanged(String query) {
    debounceTimer?.cancel();
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
        currentQuery = '';
        isSearching = false;
      });
      return;
    }

    setState(() {
      isSearching = true;
      currentQuery = query;
    });

    debounceTimer = Timer(const Duration(milliseconds: 500), () {
      performSearch(query);
    });
  }

  Future<void> performSearch(String query) async {
    if (query.isEmpty) return;

    setState(() {
      isSearching = true;
      searchPage = 0;
      hasMoreSearch = true;
    });

    final repository = getProductRepository();

    final result = await repository.searchProducts(
      query,
      page: 0,
      limit: pageSize,
      categoryId: filterCategoryId,
      minPrice: priceRange.start > minPrice ? priceRange.start : null,
      maxPrice: priceRange.end < maxPrice ? priceRange.end : null,
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          isSearching = false;
          searchResults = [];
        });
      },
      (products) {
        setState(() {
          isSearching = false;
          searchResults = products;
          hasMoreSearch = products.length >= pageSize;
        });
      },
    );
  }

  Future<void> loadMoreSearchResults() async {
    if (isLoadingMoreSearch || !hasMoreSearch || currentQuery.isEmpty) return;

    setState(() {
      isLoadingMoreSearch = true;
    });

    final repository = getProductRepository();
    final nextPage = searchPage + 1;

    final result = await repository.searchProducts(
      currentQuery,
      page: nextPage,
      limit: pageSize,
      categoryId: filterCategoryId,
      minPrice: priceRange.start > minPrice ? priceRange.start : null,
      maxPrice: priceRange.end < maxPrice ? priceRange.end : null,
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          isLoadingMoreSearch = false;
        });
      },
      (newProducts) {
        setState(() {
          isLoadingMoreSearch = false;
          searchResults = [...searchResults, ...newProducts];
          searchPage = nextPage;
          hasMoreSearch = newProducts.length >= pageSize;
        });
      },
    );
  }

  void applyFilters({
    String? categoryId,
    RangeValues? priceRangeValue,
  }) {
    setState(() {
      filterCategoryId = categoryId;
      if (priceRangeValue != null) {
        priceRange = priceRangeValue;
      }
      hasActiveFilters = categoryId != null ||
          priceRange.start > minPrice ||
          priceRange.end < maxPrice;
    });

    if (isSearchMode && currentQuery.isNotEmpty) {
      performSearch(currentQuery);
    }
  }

  void clearFilters() {
    setState(() {
      filterCategoryId = null;
      priceRange = RangeValues(minPrice, maxPrice);
      hasActiveFilters = false;
    });

    if (isSearchMode && currentQuery.isNotEmpty) {
      performSearch(currentQuery);
    }
  }

  void disposeSearch() {
    searchController.dispose();
    searchFocusNode.dispose();
    debounceTimer?.cancel();
  }

  // Abstract method to be implemented by the widget
  ProductRepository getProductRepository();
}
