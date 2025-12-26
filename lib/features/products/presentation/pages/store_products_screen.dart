import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
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
          onApply: applyFilters,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColours.greyLighter,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildHeader(),
          _buildSearchBar(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColours.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios,
            color: AppColours.brownMedium, size: 20),
        onPressed: () => context.pop(),
      ),
      title: Text(
        storeState.storeName ?? 'store_products'.tr(),
        style: AppTextStyle.semiBold_16_dark_brown,
      ),
      centerTitle: true,
    );
  }

  Widget _buildHeader() {
    return StoreHeaderCard(
      storeName: storeState.storeName,
      storeAddress: storeState.storeAddress,
      storePhone: storeState.storePhone,
      storeLogo: storeState.storeLogo,
      productCount: storeState.products.length,
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
