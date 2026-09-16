import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/shared_widgets/network_error_widget.dart';
import '../../../../core/shared_widgets/skeleton_widgets.dart';
import '../../../../core/shared_widgets/empty_states/empty_state_widget.dart';
import '../../../../core/shared_widgets/product_card/product_grid_card.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../../products/presentation/cubit/products_cubit.dart';
import '../../../products/presentation/cubit/products_state.dart';

/// Dedicated full-screen page for displaying products belonging to a category
class CategoryProductsPage extends StatefulWidget {
  final String? categoryId;
  final String? categoryName;

  const CategoryProductsPage({
    super.key,
    this.categoryId,
    this.categoryName,
  });

  @override
  State<CategoryProductsPage> createState() => _CategoryProductsPageState();
}

class _CategoryProductsPageState extends State<CategoryProductsPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _sortBy = 'default'; // 'default', 'price_low', 'price_high', 'rating'

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
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    if (currentScroll >= (maxScroll - 200)) {
      context.read<ProductsCubit>().loadMoreProducts();
    }
  }

  void _loadProducts() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.categoryId != null && widget.categoryId!.isNotEmpty) {
        context.read<ProductsCubit>().loadProductsByCategory(widget.categoryId!);
      } else {
        context.read<ProductsCubit>().loadProducts(forceReload: true);
      }
    });
  }

  List<ProductEntity> _getFilteredAndSortedProducts(List<ProductEntity> products) {
    var list = products.toList();

    // Filter by search query
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase().trim();
      list = list.where((p) => p.name.toLowerCase().contains(q)).toList();
    }

    // Sort products
    switch (_sortBy) {
      case 'price_low':
        list.sort((a, b) => a.effectivePrice.compareTo(b.effectivePrice));
        break;
      case 'price_high':
        list.sort((a, b) => b.effectivePrice.compareTo(a.effectivePrice));
        break;
      case 'rating':
        list.sort((a, b) => (b.rating).compareTo(a.rating));
        break;
      default:
        break;
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = widget.categoryName ?? 'all_products'.tr();
    final isArabic = context.locale.languageCode == 'ar';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            isArabic ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
            size: 20,
            color: theme.colorScheme.onSurface,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.shopping_bag_outlined,
              color: theme.colorScheme.onSurface,
            ),
            onPressed: () => context.push('/cart'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val),
                      decoration: InputDecoration(
                        hintText: 'search'.tr(),
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          size: 20,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Sort popup button
                PopupMenuButton<String>(
                  icon: Container(
                    height: 44,
                    width: 44,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Icon(
                      Icons.sort_rounded,
                      color: theme.colorScheme.primary,
                      size: 22,
                    ),
                  ),
                  onSelected: (val) => setState(() => _sortBy = val),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'default',
                      child: Text('default'.tr()),
                    ),
                    PopupMenuItem(
                      value: 'price_low',
                      child: Text('price_low_to_high'.tr()),
                    ),
                    PopupMenuItem(
                      value: 'price_high',
                      child: Text('price_high_to_low'.tr()),
                    ),
                    PopupMenuItem(
                      value: 'rating',
                      child: Text('top_rated'.tr()),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Products Body
          Expanded(
            child: BlocBuilder<ProductsCubit, ProductsState>(
              builder: (context, state) {
                if (state is ProductsError) {
                  return NetworkErrorWidget(
                    message: state.message,
                    onRetry: _loadProducts,
                  );
                }

                if (state is ProductsLoading || state is ProductsInitial) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: ProductsGridSkeleton(itemCount: 6),
                  );
                }

                if (state is ProductsLoaded) {
                  final products = _getFilteredAndSortedProducts(state.products);

                  if (products.isEmpty) {
                    return EmptyStates.noProducts(context);
                  }

                  return RefreshIndicator(
                    onRefresh: () async => _loadProducts(),
                    color: theme.colorScheme.primary,
                    child: GridView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      physics: const AlwaysScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.68,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        return ProductGridCard(product: products[index]);
                      },
                    ),
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
}
