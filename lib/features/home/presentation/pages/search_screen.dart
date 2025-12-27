import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../products/data/repositories/product_repository_impl.dart';
import '../../../products/domain/repositories/product_repository.dart';
import '../widgets/home_filter_sheet.dart';
import '../widgets/home_search_content.dart';
import '../logic/home_search_logic.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with HomeSearchLogic {
  final ScrollController _scrollController = ScrollController();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      final repository = sl<ProductRepository>();
      if (repository is ProductRepositoryImpl) {
        repository.setLocale(context.locale.languageCode);
      }
      initializeSearchManager(repository);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        enterSearchMode();
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    disposeSearch();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom &&
        (searchState.currentQuery.isNotEmpty ||
            searchState.searchResults.isNotEmpty)) {
      loadMoreSearchResults();
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll - 200);
  }

  void _handleBackPress() {
    context.go('/home');
  }

  Future<bool> _handleSystemBack() async {
    context.go('/home');
    return true;
  }

  void _showFilterSheet() {
    showFilterSheet(
      context,
      HomeFilterSheet(
        initialCategoryId: filterState.categoryId,
        initialPriceRange: filterState.priceRange,
        minPrice: filterState.minPrice,
        maxPrice: filterState.maxPrice,
        initialSortOption: filterState.sortOption,
        onApply: (categoryId, priceRange, sortOption) {
          applyFilters(
            categoryId: categoryId,
            priceRange: priceRange,
            sortOption: sortOption,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BackButtonListener(
      onBackButtonPressed: _handleSystemBack,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          bottom: false,
          child: RefreshIndicator(
            onRefresh: refreshSearch,
            color: theme.colorScheme.primary,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildSearchBar()),
                SliverToBoxAdapter(
                  child: HomeSearchContent(
                    isSearching: searchState.isSearching,
                    currentQuery: searchState.currentQuery,
                    searchResults: searchState.searchResults,
                    isLoadingMore: searchState.isLoadingMore,
                    hasMore: searchState.hasMore,
                    hasActiveFilters: filterState.hasActiveFilters,
                    onCategoryTap: (categoryId, categoryName) {
                      searchByCategory(categoryId, categoryName);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_forward, color: theme.colorScheme.primary),
            onPressed: _handleBackPress,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Container(
                height: 45,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
                child: TextField(
                  controller: searchController,
                  focusNode: searchFocusNode,
                  onChanged: onSearchChanged,
                  textAlign: TextAlign.right,
                  textDirection: ui.TextDirection.rtl,
                  textInputAction: TextInputAction.search,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: 'search'.tr(),
                    hintStyle: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.5),
                              size: 20,
                            ),
                            onPressed: () {
                              searchController.clear();
                              onSearchChanged('');
                            },
                          )
                        : null,
                    prefixIcon:
                        Icon(Icons.search, color: theme.colorScheme.primary),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: _showFilterSheet,
            child: Container(
              height: 45,
              width: 45,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border:
                    Border.all(color: theme.colorScheme.primary, width: 1.5),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(Icons.filter_list,
                      color: theme.colorScheme.primary, size: 24),
                  if (filterState.hasActiveFilters)
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
