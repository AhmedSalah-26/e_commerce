import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
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
    return true; // Handled
  }

  void _showFilterSheet() {
    showFilterSheet(
      context,
      HomeFilterSheet(
        initialCategoryId: filterState.categoryId,
        initialPriceRange: filterState.priceRange,
        minPrice: filterState.minPrice,
        maxPrice: filterState.maxPrice,
        onApply: (categoryId, priceRange) {
          applyFilters(categoryId: categoryId, priceRange: priceRange);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BackButtonListener(
      onBackButtonPressed: _handleSystemBack,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: AppColours.white,
          body: RefreshIndicator(
            onRefresh: refreshSearch,
            color: AppColours.brownLight,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Search bar
                SliverToBoxAdapter(child: _buildSearchBar()),
                // Search content
                SliverToBoxAdapter(
                  child: HomeSearchContent(
                    isSearching: searchState.isSearching,
                    currentQuery: searchState.currentQuery,
                    searchResults: searchState.searchResults,
                    isLoadingMore: searchState.isLoadingMore,
                    hasMore: searchState.hasMore,
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
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Back button
          IconButton(
            icon:
                const Icon(Icons.arrow_forward, color: AppColours.brownMedium),
            onPressed: _handleBackPress,
          ),
          // Search bar
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Container(
                height: 45,
                decoration: BoxDecoration(
                  color: AppColours.greyLighter,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: searchController,
                  focusNode: searchFocusNode,
                  onChanged: onSearchChanged,
                  textAlign: TextAlign.right,
                  textDirection: ui.TextDirection.rtl,
                  textInputAction: TextInputAction.search,
                  style: AppTextStyle.normal_12_black,
                  decoration: InputDecoration(
                    hintText: 'search'.tr(),
                    hintStyle: AppTextStyle.normal_12_greyDark,
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear,
                                color: AppColours.greyMedium, size: 20),
                            onPressed: () {
                              searchController.clear();
                              onSearchChanged('');
                            },
                          )
                        : null,
                    prefixIcon: const Icon(Icons.search,
                        color: AppColours.primaryColor),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                ),
              ),
            ),
          ),
          // Filter button
          GestureDetector(
            onTap: _showFilterSheet,
            child: Container(
              height: 45,
              width: 45,
              decoration: BoxDecoration(
                color: AppColours.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColours.primaryColor, width: 1.5),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.filter_list,
                      color: AppColours.primaryColor, size: 24),
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
