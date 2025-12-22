import '../../../products/domain/entities/product_entity.dart';

/// Search state model
class SearchState {
  final bool isSearchMode;
  final String currentQuery;
  final List<ProductEntity> searchResults;
  final bool isSearching;
  final bool isLoadingMore;
  final bool hasMore;
  final int currentPage;

  const SearchState({
    this.isSearchMode = false,
    this.currentQuery = '',
    this.searchResults = const [],
    this.isSearching = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.currentPage = 0,
  });

  SearchState copyWith({
    bool? isSearchMode,
    String? currentQuery,
    List<ProductEntity>? searchResults,
    bool? isSearching,
    bool? isLoadingMore,
    bool? hasMore,
    int? currentPage,
  }) {
    return SearchState(
      isSearchMode: isSearchMode ?? this.isSearchMode,
      currentQuery: currentQuery ?? this.currentQuery,
      searchResults: searchResults ?? this.searchResults,
      isSearching: isSearching ?? this.isSearching,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  bool get isEmpty => searchResults.isEmpty && !isSearching;
  bool get hasResults => searchResults.isNotEmpty;
}
