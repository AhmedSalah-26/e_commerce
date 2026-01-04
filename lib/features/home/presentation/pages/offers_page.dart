import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/shared_widgets/network_error_widget.dart';
import '../../../../core/shared_widgets/skeleton_widgets.dart';
import '../../../../core/utils/error_helper.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../../products/presentation/cubit/products_cubit.dart';
import '../../../products/presentation/cubit/products_state.dart';
import '../widgets/all_categories/filter_sort_bar.dart';
import '../widgets/all_categories/category_products_grid.dart';

/// نوع العروض
enum OfferType {
  flashSale,
  bestDeals,
  newArrivals,
}

/// صفحة العروض - تعرض منتجات حسب نوع العرض
class OffersPage extends StatefulWidget {
  final OfferType offerType;

  const OffersPage({super.key, required this.offerType});

  @override
  State<OffersPage> createState() => _OffersPageState();
}

class _OffersPageState extends State<OffersPage> {
  SortOption _sortOption = SortOption.newest;
  final ScrollController _scrollController = ScrollController();

  // Price filter
  static const double _minPrice = 0;
  static const double _maxPrice = 10000;
  RangeValues _priceRange = const RangeValues(_minPrice, _maxPrice);

  @override
  void initState() {
    super.initState();
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
      _loadMoreProducts();
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll - 200);
  }

  void _loadProducts() {
    final cubit = context.read<ProductsCubit>();
    switch (widget.offerType) {
      case OfferType.flashSale:
        cubit.loadFlashSaleProducts();
        break;
      case OfferType.bestDeals:
        cubit.loadDiscountedProducts();
        break;
      case OfferType.newArrivals:
        cubit.loadProducts(forceReload: true);
        break;
    }
  }

  void _loadMoreProducts() {
    final cubit = context.read<ProductsCubit>();
    switch (widget.offerType) {
      case OfferType.flashSale:
        // Flash sale doesn't have pagination
        break;
      case OfferType.bestDeals:
        cubit.loadMoreDiscountedProducts();
        break;
      case OfferType.newArrivals:
        cubit.loadMoreProducts();
        break;
    }
  }

  String get _title {
    switch (widget.offerType) {
      case OfferType.flashSale:
        return 'flash_sale'.tr();
      case OfferType.bestDeals:
        return 'best_deals'.tr();
      case OfferType.newArrivals:
        return 'new_arrivals'.tr();
    }
  }

  String get _subtitle {
    final isArabic = context.locale.languageCode == 'ar';
    switch (widget.offerType) {
      case OfferType.flashSale:
        return isArabic ? 'عروض لفترة محدودة' : 'Limited time offers';
      case OfferType.bestDeals:
        return isArabic
            ? 'خصومات مميزة على منتجات مختارة'
            : 'Special discounts on selected products';
      case OfferType.newArrivals:
        return isArabic
            ? 'أحدث المنتجات في متجرنا'
            : 'Latest products in our store';
    }
  }

  Color get _headerColor {
    switch (widget.offerType) {
      case OfferType.flashSale:
        return const Color(0xFFE53935);
      case OfferType.bestDeals:
        return const Color(0xFF4FC3F7);
      case OfferType.newArrivals:
        return const Color(0xFFAED581);
    }
  }

  IconData get _headerIcon {
    switch (widget.offerType) {
      case OfferType.flashSale:
        return Icons.flash_on;
      case OfferType.bestDeals:
        return Icons.local_offer;
      case OfferType.newArrivals:
        return Icons.new_releases;
    }
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
        filtered.sort((a, b) => b.ratingCount.compareTo(a.ratingCount));
        break;
    }
    return filtered;
  }

  int get _activeFilterCount {
    int count = 0;
    if (_priceRange.start > _minPrice || _priceRange.end < _maxPrice) {
      count++;
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: _headerColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_headerIcon, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  _title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              _subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.9),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        toolbarHeight: 70,
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
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
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
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
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Header
              Row(
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
                    onPressed: () {
                      setState(() {
                        _priceRange = const RangeValues(_minPrice, _maxPrice);
                      });
                      Navigator.pop(context);
                    },
                    child: Text(
                      'clear_all'.tr(),
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Price filter
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
              StatefulBuilder(
                builder: (context, setSheetState) {
                  return RangeSlider(
                    values: _priceRange,
                    min: _minPrice,
                    max: _maxPrice,
                    divisions: 100,
                    activeColor: theme.colorScheme.primary,
                    inactiveColor:
                        theme.colorScheme.outline.withValues(alpha: 0.3),
                    onChanged: (values) {
                      setSheetState(() {});
                      setState(() => _priceRange = values);
                    },
                  );
                },
              ),
              const SizedBox(height: 24),

              // Apply button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
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
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
