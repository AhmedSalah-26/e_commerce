import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/shared_widgets/network_error_widget.dart';
import '../../../../core/shared_widgets/skeleton_widgets.dart';
import '../../../../core/utils/error_helper.dart';
import '../../../categories/domain/entities/category_entity.dart';
import '../../../categories/presentation/cubit/categories_cubit.dart';
import '../../../categories/presentation/cubit/categories_state.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../../products/presentation/cubit/products_cubit.dart';
import '../../../products/presentation/cubit/products_state.dart';
import '../widgets/all_categories/categories_header.dart';
import '../widgets/all_categories/categories_search_bar.dart';
import '../widgets/all_categories/filter_sort_bar.dart';
import '../widgets/all_categories/category_products_grid.dart';
import '../widgets/all_categories/filter_sheet.dart';

class AllCategoriesPage extends StatefulWidget {
  final String? initialCategoryId;

  const AllCategoriesPage({super.key, this.initialCategoryId});

  @override
  State<AllCategoriesPage> createState() => _AllCategoriesPageState();
}

class _AllCategoriesPageState extends State<AllCategoriesPage> {
  String? _selectedCategoryId;
  SortOption _sortOption = SortOption.newest;
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingProducts = false;

  static const double _minPrice = 0;
  static const double _maxPrice = 10000;
  RangeValues _priceRange = const RangeValues(_minPrice, _maxPrice);

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.initialCategoryId;
    _scrollController.addListener(_onScroll);
    _loadProducts();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) context.read<ProductsCubit>().loadMoreProducts();
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    return _scrollController.offset >= (maxScroll - 200);
  }

  void _loadProducts() {
    setState(() => _isLoadingProducts = true);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_selectedCategoryId != null) {
        await context
            .read<ProductsCubit>()
            .loadProductsByCategory(_selectedCategoryId!);
      } else {
        await context.read<ProductsCubit>().loadProducts(forceReload: true);
      }
      if (mounted) setState(() => _isLoadingProducts = false);
    });
  }

  void _onCategorySelected(String? categoryId) {
    setState(() => _selectedCategoryId = categoryId);
    _loadProducts();
  }

  void _onSortChanged(SortOption option) {
    setState(() => _sortOption = option);
  }

  List<ProductEntity> _sortProducts(List<ProductEntity> products) {
    // Apply search filter first
    var filtered = products.where((p) {
      final price = p.effectivePrice;
      final priceMatch = price >= _priceRange.start && price <= _priceRange.end;

      if (_searchQuery.isEmpty) return priceMatch;

      final searchLower = _searchQuery.toLowerCase();
      return priceMatch && p.name.toLowerCase().contains(searchLower);
    }).toList();

    switch (_sortOption) {
      case SortOption.newest:
        filtered.sort((a, b) => (b.createdAt ?? DateTime.now())
            .compareTo(a.createdAt ?? DateTime.now()));
        break;
      case SortOption.priceLowToHigh:
        filtered.sort((a, b) => a.effectivePrice.compareTo(b.effectivePrice));
        break;
      case SortOption.priceHighToLow:
        filtered.sort((a, b) => b.effectivePrice.compareTo(a.effectivePrice));
        break;
      case SortOption.topRated:
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case SortOption.bestSelling:
        filtered.sort((a, b) => b.ratingCount.compareTo(a.ratingCount));
        break;
    }
    return filtered;
  }

  int get _activeFilterCount {
    int count = 0;
    if (_selectedCategoryId != null) count++;
    if (_priceRange.start > _minPrice || _priceRange.end < _maxPrice) count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        automaticallyImplyLeading: false,
        title: Text(
          'all_categories'.tr(),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          CategoriesSearchBar(
            controller: _searchController,
            searchQuery: _searchQuery,
            onChanged: (value) => setState(() => _searchQuery = value),
            onClear: () {
              _searchController.clear();
              setState(() => _searchQuery = '');
            },
          ),
          _buildCategoriesHeader(isDark),
          FilterSortBar(
            sortOption: _sortOption,
            onSortChanged: _onSortChanged,
            onFilterTap: () => _showFilterSheet(context),
            activeFilterCount: _activeFilterCount,
            darkMode: isDark,
          ),
          Expanded(child: _buildProductsGrid()),
        ],
      ),
    );
  }

  Widget _buildCategoriesHeader(bool isDark) {
    return BlocBuilder<CategoriesCubit, CategoriesState>(
      builder: (context, state) {
        if (state is CategoriesLoading) {
          return const SizedBox(height: 100, child: CategoriesRowSkeleton());
        }
        if (state is CategoriesLoaded) {
          return CategoriesHeader(
            categories: state.categories,
            selectedCategoryId: _selectedCategoryId,
            onCategorySelected: _onCategorySelected,
            darkMode: isDark,
          );
        }
        if (state is CategoriesError) {
          return SizedBox(
            height: 100,
            child: Center(
              child: TextButton.icon(
                onPressed: () =>
                    context.read<CategoriesCubit>().loadCategories(),
                icon: const Icon(Icons.refresh),
                label: Text('retry'.tr()),
              ),
            ),
          );
        }
        return const SizedBox(height: 100);
      },
    );
  }

  Widget _buildProductsGrid() {
    if (_isLoadingProducts) {
      return const ProductsGridSkeleton(itemCount: 6);
    }

    return BlocBuilder<ProductsCubit, ProductsState>(
      builder: (context, state) {
        if (state is ProductsLoading || state is ProductsInitial) {
          return const ProductsGridSkeleton(itemCount: 6);
        }

        if (state is ProductsError) {
          return NetworkErrorWidget(
            message: ErrorHelper.getUserFriendlyMessage(state.message),
            onRetry: _loadProducts,
          );
        }

        if (state is ProductsLoaded) {
          final sortedProducts = _sortProducts(state.products);

          if (sortedProducts.isEmpty) {
            return EmptyStates.noProducts(context);
          }

          return CategoryProductsGrid(
            products: sortedProducts,
            scrollController: _scrollController,
            isLoadingMore: state.isLoadingMore,
          );
        }

        return const ProductsGridSkeleton(itemCount: 6);
      },
    );
  }

  void _showFilterSheet(BuildContext context) {
    final categoriesState = context.read<CategoriesCubit>().state;
    final categories = categoriesState is CategoriesLoaded
        ? categoriesState.categories
        : <CategoryEntity>[];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AllCategoriesFilterSheet(
        categories: categories,
        selectedCategoryId: _selectedCategoryId,
        priceRange: _priceRange,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        onApply: (categoryId, priceRange) {
          Navigator.pop(context);
          setState(() => _priceRange = priceRange);
          _onCategorySelected(categoryId);
        },
      ),
    );
  }
}
