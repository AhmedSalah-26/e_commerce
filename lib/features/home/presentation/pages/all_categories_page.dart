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
import '../widgets/all_categories/filter_sort_bar.dart';
import '../widgets/all_categories/category_products_grid.dart';

/// صفحة جميع الأقسام - مشابهة لتطبيق Kenzz
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

  // Price filter
  static const double _minPrice = 0;
  static const double _maxPrice = 10000;
  RangeValues _priceRange = const RangeValues(_minPrice, _maxPrice);

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
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<ProductsCubit>().loadMoreProducts();
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll - 200);
  }

  void _loadProducts() {
    if (_selectedCategoryId != null) {
      context
          .read<ProductsCubit>()
          .loadProductsByCategory(_selectedCategoryId!);
    } else {
      context.read<ProductsCubit>().loadProducts(forceReload: true);
    }
  }

  void _onCategorySelected(String? categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
    });
    _loadProducts();
  }

  void _onSortChanged(SortOption option) {
    setState(() {
      _sortOption = option;
    });
  }

  List<ProductEntity> _sortProducts(List<ProductEntity> products) {
    // First filter by price
    var filtered = products.where((p) {
      final price = p.effectivePrice;
      return price >= _priceRange.start && price <= _priceRange.end;
    }).toList();

    // Then sort
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
        // Sort by rating count as a proxy for best selling
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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
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
          // Categories horizontal list
          BlocBuilder<CategoriesCubit, CategoriesState>(
            builder: (context, state) {
              if (state is CategoriesLoading) {
                return const SizedBox(
                  height: 100,
                  child: CategoriesRowSkeleton(),
                );
              }
              if (state is CategoriesLoaded) {
                return CategoriesHeader(
                  categories: state.categories,
                  selectedCategoryId: _selectedCategoryId,
                  onCategorySelected: _onCategorySelected,
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
          ),

          // Filter & Sort bar
          FilterSortBar(
            sortOption: _sortOption,
            onSortChanged: _onSortChanged,
            onFilterTap: () => _showFilterSheet(context),
            activeFilterCount: _activeFilterCount,
          ),

          // Products grid
          Expanded(
            child: BlocBuilder<ProductsCubit, ProductsState>(
              builder: (context, state) {
                if (state is ProductsLoading) {
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

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    // Get categories before opening the sheet
    final categoriesState = context.read<CategoriesCubit>().state;
    final categories = categoriesState is CategoriesLoaded
        ? categoriesState.categories
        : <CategoryEntity>[];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterSheet(
        categories: categories,
        selectedCategoryId: _selectedCategoryId,
        priceRange: _priceRange,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        onApply: (categoryId, priceRange) {
          Navigator.pop(context);
          setState(() {
            _priceRange = priceRange;
          });
          _onCategorySelected(categoryId);
        },
      ),
    );
  }
}

/// Filter sheet widget - same style as search filter
class _FilterSheet extends StatefulWidget {
  final List<CategoryEntity> categories;
  final String? selectedCategoryId;
  final RangeValues priceRange;
  final double minPrice;
  final double maxPrice;
  final Function(String?, RangeValues) onApply;

  const _FilterSheet({
    required this.categories,
    this.selectedCategoryId,
    required this.priceRange,
    required this.minPrice,
    required this.maxPrice,
    required this.onApply,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late String? _selectedCategoryId;
  late RangeValues _priceRange;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.selectedCategoryId;
    _priceRange = widget.priceRange;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHandle(theme),
            const SizedBox(height: 20),
            _buildHeader(theme),
            const SizedBox(height: 20),
            _buildCategoryFilter(theme),
            const SizedBox(height: 24),
            _buildPriceFilter(theme),
            const SizedBox(height: 24),
            _buildApplyButton(theme),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle(ThemeData theme) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'filters'.tr(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        TextButton(
          onPressed: () => setState(() {
            _selectedCategoryId = null;
            _priceRange = RangeValues(widget.minPrice, widget.maxPrice);
          }),
          child: Text(
            'clear_all'.tr(),
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilter(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'categories'.tr(),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.categories.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildCategoryChip(
                  'all'.tr(),
                  _selectedCategoryId == null,
                  () => setState(() => _selectedCategoryId = null),
                  theme,
                );
              }
              final category = widget.categories[index - 1];
              return _buildCategoryChip(
                category.name,
                _selectedCategoryId == category.id,
                () => setState(() => _selectedCategoryId = category.id),
                theme,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(
      String label, bool isSelected, VoidCallback onTap, ThemeData theme) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: theme.colorScheme.primary),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : theme.colorScheme.primary,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildApplyButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => widget.onApply(_selectedCategoryId, _priceRange),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'apply'.tr(),
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildPriceFilter(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'price'.tr(),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${_priceRange.start.toInt()} ${'egp'.tr()}'),
            Text('${_priceRange.end.toInt()} ${'egp'.tr()}'),
          ],
        ),
        RangeSlider(
          values: _priceRange,
          min: widget.minPrice,
          max: widget.maxPrice,
          divisions: 100,
          activeColor: theme.colorScheme.primary,
          inactiveColor: theme.colorScheme.outline.withValues(alpha: 0.3),
          onChanged: (values) {
            setState(() => _priceRange = values);
          },
        ),
      ],
    );
  }
}
