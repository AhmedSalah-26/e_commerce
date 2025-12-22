import 'dart:async';
import 'package:flutter/material.dart';
import '../../../products/domain/repositories/product_repository.dart';
import 'search_state.dart';
import 'filter_state.dart';

/// Search manager to handle all search logic
class SearchManager {
  final ProductRepository repository;
  final VoidCallback onStateChanged;

  static const int pageSize = 10;
  static const Duration debounceDuration = Duration(seconds: 1);

  SearchState _searchState = const SearchState();
  FilterState _filterState = const FilterState();
  Timer? _debounceTimer;

  SearchManager({
    required this.repository,
    required this.onStateChanged,
  });

  // Getters
  SearchState get searchState => _searchState;
  FilterState get filterState => _filterState;

  // Enter search mode
  void enterSearchMode() {
    _searchState = _searchState.copyWith(isSearchMode: true);
    onStateChanged();
  }

  // Exit search mode
  void exitSearchMode() {
    _debounceTimer?.cancel();
    _searchState = const SearchState();
    _filterState = _filterState.clear();
    onStateChanged();
  }

  // Handle search query change
  void onSearchChanged(String query) {
    _debounceTimer?.cancel();

    if (query.isEmpty) {
      _searchState = _searchState.copyWith(
        currentQuery: '',
        searchResults: [],
        isSearching: false,
      );
      onStateChanged();
      return;
    }

    _searchState = _searchState.copyWith(
      currentQuery: query,
      isSearching: true,
    );
    onStateChanged();

    _debounceTimer = Timer(debounceDuration, () {
      performSearch(query);
    });
  }

  // Perform search
  Future<void> performSearch(String query) async {
    if (query.isEmpty) return;

    _searchState = _searchState.copyWith(
      isSearching: true,
      currentPage: 0,
    );
    onStateChanged();

    final result = await repository.searchProducts(
      query,
      page: 0,
      limit: pageSize,
      categoryId: _filterState.categoryId,
      minPrice: _filterState.priceRange.start > _filterState.minPrice
          ? _filterState.priceRange.start
          : null,
      maxPrice: _filterState.priceRange.end < _filterState.maxPrice
          ? _filterState.priceRange.end
          : null,
    );

    result.fold(
      (failure) {
        _searchState = _searchState.copyWith(
          isSearching: false,
          searchResults: [],
        );
        onStateChanged();
      },
      (products) {
        _searchState = _searchState.copyWith(
          isSearching: false,
          searchResults: products,
          hasMore: products.length >= pageSize,
        );
        onStateChanged();
      },
    );
  }

  // Load more search results
  Future<void> loadMoreResults() async {
    if (_searchState.isLoadingMore ||
        !_searchState.hasMore ||
        _searchState.currentQuery.isEmpty) {
      return;
    }

    _searchState = _searchState.copyWith(isLoadingMore: true);
    onStateChanged();

    final nextPage = _searchState.currentPage + 1;

    final result = await repository.searchProducts(
      _searchState.currentQuery,
      page: nextPage,
      limit: pageSize,
      categoryId: _filterState.categoryId,
      minPrice: _filterState.priceRange.start > _filterState.minPrice
          ? _filterState.priceRange.start
          : null,
      maxPrice: _filterState.priceRange.end < _filterState.maxPrice
          ? _filterState.priceRange.end
          : null,
    );

    result.fold(
      (failure) {
        _searchState = _searchState.copyWith(isLoadingMore: false);
        onStateChanged();
      },
      (newProducts) {
        _searchState = _searchState.copyWith(
          isLoadingMore: false,
          searchResults: [..._searchState.searchResults, ...newProducts],
          currentPage: nextPage,
          hasMore: newProducts.length >= pageSize,
        );
        onStateChanged();
      },
    );
  }

  // Apply filters
  void applyFilters({
    String? categoryId,
    RangeValues? priceRange,
  }) {
    _filterState = _filterState.copyWith(
      categoryId: categoryId,
      priceRange: priceRange,
    );
    onStateChanged();

    if (_searchState.isSearchMode && _searchState.currentQuery.isNotEmpty) {
      performSearch(_searchState.currentQuery);
    }
  }

  // Clear filters
  void clearFilters() {
    _filterState = _filterState.clear();
    onStateChanged();

    if (_searchState.isSearchMode && _searchState.currentQuery.isNotEmpty) {
      performSearch(_searchState.currentQuery);
    }
  }

  // Dispose
  void dispose() {
    _debounceTimer?.cancel();
  }
}
