import 'package:flutter/material.dart';
import '../../domain/search/search_manager.dart';
import '../../domain/search/search_state.dart';
import '../../domain/search/filter_state.dart';
import '../../../products/domain/repositories/product_repository.dart';

/// Mixin to add search logic to home screen
mixin HomeSearchLogic<T extends StatefulWidget> on State<T> {
  late SearchManager _searchManager;

  // Controllers
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();

  // Getters
  SearchState get searchState => _searchManager.searchState;
  FilterState get filterState => _searchManager.filterState;

  // Initialize search manager
  void initializeSearchManager(ProductRepository repository) {
    _searchManager = SearchManager(
      repository: repository,
      onStateChanged: () {
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  // Enter search mode
  void enterSearchMode() {
    _searchManager.enterSearchMode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      searchFocusNode.requestFocus();
    });
  }

  // Exit search mode
  void exitSearchMode() {
    searchController.clear();
    searchFocusNode.unfocus();
    _searchManager.exitSearchMode();
  }

  // Handle search query change
  void onSearchChanged(String query) {
    _searchManager.onSearchChanged(query);
  }

  // Load more search results
  Future<void> loadMoreSearchResults() async {
    await _searchManager.loadMoreResults();
  }

  // Show filter sheet
  void showFilterSheet(BuildContext context, Widget filterSheet) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => filterSheet,
    );
  }

  // Apply filters
  void applyFilters({
    String? categoryId,
    RangeValues? priceRange,
  }) {
    _searchManager.applyFilters(
      categoryId: categoryId,
      priceRange: priceRange,
    );
  }

  // Search by category
  Future<void> searchByCategory(String categoryId, String categoryName) async {
    await _searchManager.searchByCategory(categoryId, categoryName);
  }

  // Clear filters
  void clearFilters() {
    _searchManager.clearFilters();
  }

  // Refresh search
  Future<void> refreshSearch() async {
    if (searchState.currentQuery.isNotEmpty) {
      await _searchManager.performSearch(searchState.currentQuery);
    }
  }

  // Dispose search
  void disposeSearch() {
    searchController.dispose();
    searchFocusNode.dispose();
    _searchManager.dispose();
  }
}
