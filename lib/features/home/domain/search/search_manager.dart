import 'dart:async';
import 'package:flutter/material.dart';
import '../../../products/domain/repositories/product_repository.dart';
import 'search_state.dart';
import 'filter_state.dart';

/// Search manager to handle all search logic with caching
class SearchManager {
  final ProductRepository repository;
  final VoidCallback onStateChanged;

  static const int pageSize = 10;
  static const Duration debounceDuration = Duration(seconds: 1);
  static const int _maxCacheSize = 20;

  SearchState _searchState = const SearchState();
  FilterState _filterState = const FilterState();
  Timer? _debounceTimer;

  // Simple LRU cache for search results
  final Map<String, List<dynamic>> _searchCache = {};
  final List<String> _cacheKeys = [];

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

      // If there are active filters, reload filtered results
      if (_filterState.hasActiveFilters) {
        _performFilteredSearch();
      }
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

    // Check cache first
    final cacheKey = _buildCacheKey(query, _filterState);
    if (_searchCache.containsKey(cacheKey)) {
      _searchState = _searchState.copyWith(
        isSearching: false,
        searchResults: _searchCache[cacheKey]!.cast(),
        hasMore: _searchCache[cacheKey]!.length >= pageSize,
        currentPage: 0,
      );
      onStateChanged();
      return;
    }

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
        // Cache the results
        _addToCache(cacheKey, products);

        _searchState = _searchState.copyWith(
          isSearching: false,
          searchResults: products,
          hasMore: products.length >= pageSize,
        );
        onStateChanged();
      },
    );
  }

  String _buildCacheKey(String query, FilterState filter) {
    return '${query}_${filter.categoryId ?? ''}_${filter.priceRange.start}_${filter.priceRange.end}';
  }

  void _addToCache(String key, List<dynamic> results) {
    if (_cacheKeys.length >= _maxCacheSize) {
      final oldestKey = _cacheKeys.removeAt(0);
      _searchCache.remove(oldestKey);
    }
    _searchCache[key] = results;
    _cacheKeys.add(key);
  }

  void clearCache() {
    _searchCache.clear();
    _cacheKeys.clear();
  }

  // Load more search results
  Future<void> loadMoreResults() async {
    if (_searchState.isLoadingMore || !_searchState.hasMore) {
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
    final currentQuery = _searchState.currentQuery;
    final hasFilters = categoryId != null ||
        (priceRange != null &&
            (priceRange.start > _filterState.minPrice ||
                priceRange.end < _filterState.maxPrice));

    _filterState = FilterState(
      categoryId: categoryId,
      priceRange: priceRange ??
          RangeValues(_filterState.minPrice, _filterState.maxPrice),
      minPrice: _filterState.minPrice,
      maxPrice: _filterState.maxPrice,
    );

    // If no filters and no query, show categories
    if (!hasFilters && currentQuery.isEmpty) {
      _searchState = const SearchState(
        isSearchMode: true,
        currentQuery: '',
        searchResults: [],
        isSearching: false,
      );
      onStateChanged();
      return;
    }

    // Keep the query and perform filtered search
    _searchState = SearchState(
      isSearchMode: true,
      currentQuery: currentQuery,
      searchResults: const [],
      isSearching: true,
    );
    onStateChanged();

    // Perform filtered search
    _performFilteredSearch();
  }

  // Perform filtered search (with or without query)
  Future<void> _performFilteredSearch() async {
    _searchState = _searchState.copyWith(
      isSearching: true,
      currentPage: 0,
    );
    onStateChanged();

    final result = await repository.searchProducts(
      _searchState.currentQuery, // Can be empty
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

  // Search by category (loads all products in category)
  Future<void> searchByCategory(String categoryId, String categoryName) async {
    // Clear old results immediately
    _searchState = const SearchState(
      isSearchMode: true,
      isSearching: true,
      currentQuery: '',
      searchResults: [],
    );
    _filterState = FilterState(
      categoryId: categoryId,
      priceRange: RangeValues(_filterState.minPrice, _filterState.maxPrice),
      minPrice: _filterState.minPrice,
      maxPrice: _filterState.maxPrice,
    );
    onStateChanged();

    final result = await repository.searchProducts(
      '', // Empty query to get all products
      page: 0,
      limit: pageSize,
      categoryId: categoryId,
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

  // Clear filters - reset to show categories
  void clearFilters() {
    _filterState = _filterState.clear();
    _searchState = const SearchState(
      isSearchMode: true,
      currentQuery: '',
      searchResults: [],
      isSearching: false,
    );
    onStateChanged();
  }

  // Dispose
  void dispose() {
    _debounceTimer?.cancel();
    clearCache();
  }
}
