import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../categories/presentation/cubit/categories_cubit.dart';
import '../../../home/presentation/widgets/home_filter_sheet.dart';
import '../widgets/store_header_card.dart';
import '../widgets/store_search_bar.dart';
import 'store_products/store_products_body.dart';
import 'store_products/store_products_logic.dart';

class StoreProductsScreen extends StatefulWidget {
  final String merchantId;
  final String? storeName;

  const StoreProductsScreen({
    super.key,
    required this.merchantId,
    this.storeName,
  });

  @override
  State<StoreProductsScreen> createState() => _StoreProductsScreenState();
}

class _StoreProductsScreenState extends State<StoreProductsScreen>
    with StoreProductsLogic {
  @override
  void initState() {
    super.initState();
    initLogic(widget.merchantId, widget.storeName);
  }

  @override
  void dispose() {
    disposeLogic();
    super.dispose();
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: sl<CategoriesCubit>()..loadCategories(),
        child: HomeFilterSheet(
          initialCategoryId: storeState.selectedCategoryId,
          initialPriceRange: storeState.priceRange,
          minPrice: storeState.minPrice,
          maxPrice: storeState.maxPrice,
          initialSortOption: storeState.sortOption,
          onApply: applyFilters,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(theme),
      body: Column(
        children: [
          _buildHeader(),
          _buildSearchBar(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios,
            color: theme.colorScheme.primary, size: 20),
        onPressed: () => context.pop(),
      ),
    );
  }

  Widget _buildHeader() {
    return StoreHeaderCard(
      storeName: storeState.storeName,
      storeDescription: storeState.storeDescription,
      storeAddress: storeState.storeAddress,
      storePhone: storeState.storePhone,
      storeLogo: storeState.storeLogo,
    );
  }

  Widget _buildSearchBar() {
    return StoreSearchBar(
      controller: searchController,
      searchQuery: storeState.searchQuery,
      hasActiveFilters: storeState.hasActiveFilters,
      onSearchChanged: updateSearchQuery,
      onClearSearch: clearSearch,
      onFilterTap: _showFilterSheet,
    );
  }

  Widget _buildBody() {
    return RefreshIndicator(
      onRefresh: loadProducts,
      child: StoreProductsBody(
        isLoading: storeState.isLoading,
        isLoadingMore: storeState.isLoadingMore,
        error: storeState.error,
        products: storeState.products,
        filteredProducts: storeState.filteredProducts,
        hasActiveFilters: storeState.hasActiveFilters,
        scrollController: scrollController,
        onRetry: loadProducts,
        onClearFilters: clearAllFilters,
      ),
    );
  }
}
