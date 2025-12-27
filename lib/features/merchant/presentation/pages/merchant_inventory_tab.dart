import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../categories/presentation/cubit/categories_cubit.dart';
import '../../../categories/presentation/cubit/categories_state.dart';
import '../../../categories/domain/entities/category_entity.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../cubit/merchant_products_cubit.dart';
import '../widgets/inventory_header.dart';
import '../widgets/inventory_filters.dart';
import '../widgets/category_search_dialog.dart';
import '../widgets/merchant_product_card.dart';
import '../widgets/merchant_empty_state.dart';
import '../widgets/product_form/product_form_dialog.dart';

class MerchantInventoryTab extends StatefulWidget {
  const MerchantInventoryTab({super.key});

  @override
  State<MerchantInventoryTab> createState() => _MerchantInventoryTabState();
}

class _MerchantInventoryTabState extends State<MerchantInventoryTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategoryId;
  String _activityFilter = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      context
          .read<MerchantProductsCubit>()
          .loadMerchantProducts(authState.user.id);
      context.read<CategoriesCubit>().loadCategories();
    }
  }

  List<ProductEntity> _filterProducts(List<ProductEntity> products) {
    var filtered = products;

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((p) {
        // Search by name, description, or product ID
        return p.name.toLowerCase().contains(query) ||
            p.description.toLowerCase().contains(query) ||
            p.id.toLowerCase().contains(query);
      }).toList();
    }

    if (_selectedCategoryId != null) {
      filtered =
          filtered.where((p) => p.categoryId == _selectedCategoryId).toList();
    }

    if (_activityFilter == 'active') {
      filtered = filtered.where((p) => p.isActive).toList();
    } else if (_activityFilter == 'inactive') {
      filtered = filtered.where((p) => !p.isActive).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = context.locale.languageCode == 'ar';
    final theme = Theme.of(context);

    return Directionality(
      textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(isRtl),
              _buildFilters(isRtl),
              Expanded(child: _buildProductsList(isRtl, theme)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isRtl) {
    return BlocBuilder<MerchantProductsCubit, MerchantProductsState>(
      builder: (context, state) {
        final products = state is MerchantProductsLoaded
            ? state.products
            : <ProductEntity>[];
        final activeCount = products.where((p) => p.isActive).length;

        return InventoryHeader(
          isRtl: isRtl,
          totalProducts: products.length,
          activeProducts: activeCount,
          onAddProduct: () => _showAddProductDialog(context, isRtl),
        );
      },
    );
  }

  Widget _buildFilters(bool isRtl) {
    return BlocBuilder<CategoriesCubit, CategoriesState>(
      builder: (context, state) {
        final categories =
            state is CategoriesLoaded ? state.categories : <CategoryEntity>[];

        return InventoryFilters(
          isRtl: isRtl,
          searchController: _searchController,
          searchQuery: _searchQuery,
          activityFilter: _activityFilter,
          selectedCategoryId: _selectedCategoryId,
          categories: categories,
          onSearchChanged: (value) => setState(() => _searchQuery = value),
          onClearSearch: () {
            _searchController.clear();
            setState(() => _searchQuery = '');
          },
          onActivityFilterChanged: (value) =>
              setState(() => _activityFilter = value),
          onCategoryTap: () => _showCategoryDialog(context, categories, isRtl),
        );
      },
    );
  }

  Widget _buildProductsList(bool isRtl, ThemeData theme) {
    return BlocBuilder<MerchantProductsCubit, MerchantProductsState>(
      builder: (context, state) {
        if (state is MerchantProductsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is MerchantProductsError) {
          return Center(
            child: Text(state.message,
                style: TextStyle(
                  fontSize: 16,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                )),
          );
        }

        if (state is MerchantProductsLoaded) {
          final filteredProducts = _filterProducts(state.products);

          if (state.products.isEmpty) {
            return MerchantEmptyState(
              icon: Icons.inventory_2_outlined,
              title: isRtl ? 'لا توجد منتجات' : 'No products yet',
              subtitle: isRtl
                  ? 'ابدأ بإضافة منتجاتك الأولى'
                  : 'Start by adding your first product',
              actionLabel: isRtl ? 'إضافة منتج' : 'Add Product',
              onAction: () => _showAddProductDialog(context, isRtl),
            );
          }

          if (filteredProducts.isEmpty) {
            return _buildNoResultsState(isRtl, theme);
          }

          return RefreshIndicator(
            onRefresh: () async {
              final authState = context.read<AuthCubit>().state;
              if (authState is AuthAuthenticated) {
                context
                    .read<MerchantProductsCubit>()
                    .loadMerchantProducts(authState.user.id);
              }
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
                return MerchantProductCard(
                  product: product,
                  onEdit: () => _showEditProductDialog(context, product, isRtl),
                  onToggleActive: () =>
                      _toggleProductActive(context, product, isRtl),
                );
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildNoResultsState(bool isRtl, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: theme.colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            isRtl ? 'لا توجد نتائج' : 'No results found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isRtl ? 'جرب البحث بكلمات أخرى' : 'Try different search terms',
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  void _showCategoryDialog(
      BuildContext context, List<CategoryEntity> categories, bool isRtl) {
    CategorySearchDialog.show(
      context: context,
      isRtl: isRtl,
      categories: categories,
      selectedCategoryId: _selectedCategoryId,
      onCategorySelected: (id) => setState(() => _selectedCategoryId = id),
    );
  }

  void _showAddProductDialog(BuildContext context, bool isRtl) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<CategoriesCubit>(),
        child: ProductFormDialog(
          isRtl: isRtl,
          onSave: (productData) async {
            final authState = context.read<AuthCubit>().state;
            if (authState is AuthAuthenticated) {
              final cubit = context.read<MerchantProductsCubit>();
              final success =
                  await cubit.createProduct(productData, authState.user.id);
              if (context.mounted) {
                _showResultSnackBar(context, success, isRtl, isAdd: true);
              }
              return success;
            }
            return false;
          },
        ),
      ),
    );
  }

  void _showEditProductDialog(
      BuildContext context, ProductEntity product, bool isRtl) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<CategoriesCubit>()),
          BlocProvider.value(value: context.read<MerchantProductsCubit>()),
        ],
        child: ProductFormDialog(
          product: product,
          isRtl: isRtl,
          onSave: (productData) async {
            final cubit = context.read<MerchantProductsCubit>();
            final success = await cubit.updateProduct(product.id, productData);
            if (context.mounted) {
              _showResultSnackBar(context, success, isRtl, isAdd: false);
            }
            return success;
          },
        ),
      ),
    );
  }

  Future<void> _toggleProductActive(
      BuildContext context, ProductEntity product, bool isRtl) async {
    final cubit = context.read<MerchantProductsCubit>();
    final success =
        await cubit.toggleProductActive(product.id, !product.isActive);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? (product.isActive
                  ? (isRtl ? 'تم إلغاء تنشيط المنتج' : 'Product deactivated')
                  : (isRtl ? 'تم تنشيط المنتج' : 'Product activated'))
              : (isRtl ? 'فشل في تحديث المنتج' : 'Failed to update product'),
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  void _showResultSnackBar(BuildContext context, bool success, bool isRtl,
      {required bool isAdd}) {
    if (!context.mounted) return;
    final message = isAdd
        ? (success
            ? (isRtl ? 'تم إضافة المنتج بنجاح' : 'Product added successfully')
            : (isRtl ? 'فشل في إضافة المنتج' : 'Failed to add product'))
        : (success
            ? (isRtl ? 'تم تحديث المنتج بنجاح' : 'Product updated successfully')
            : (isRtl ? 'فشل في تحديث المنتج' : 'Failed to update product'));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }
}
