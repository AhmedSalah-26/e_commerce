import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
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
import '../widgets/product_form_dialog.dart';

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
      filtered = filtered.where((p) {
        return p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            p.description.toLowerCase().contains(_searchQuery.toLowerCase());
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

    return Directionality(
      textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColours.white,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(isRtl),
              _buildFilters(isRtl),
              Expanded(child: _buildProductsList(isRtl)),
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

  Widget _buildProductsList(bool isRtl) {
    return BlocBuilder<MerchantProductsCubit, MerchantProductsState>(
      builder: (context, state) {
        if (state is MerchantProductsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is MerchantProductsError) {
          return Center(
            child: Text(state.message, style: AppTextStyle.normal_16_greyDark),
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
            return _buildNoResultsState(isRtl);
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
                  onDelete: () =>
                      _showDeleteConfirmation(context, product, isRtl),
                );
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildNoResultsState(bool isRtl) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 64, color: AppColours.greyLight),
          const SizedBox(height: 16),
          Text(
            isRtl ? 'لا توجد نتائج' : 'No results found',
            style: AppTextStyle.semiBold_16_dark_brown,
          ),
          const SizedBox(height: 8),
          Text(
            isRtl ? 'جرب البحث بكلمات أخرى' : 'Try different search terms',
            style: AppTextStyle.normal_14_greyDark,
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
              final success = await context
                  .read<MerchantProductsCubit>()
                  .createProduct(productData, authState.user.id);
              _showResultSnackBar(context, success, isRtl, isAdd: true);
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
            final success = await context
                .read<MerchantProductsCubit>()
                .updateProduct(product.id, productData);
            _showResultSnackBar(context, success, isRtl, isAdd: false);
            return success;
          },
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, ProductEntity product, bool isRtl) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isRtl ? 'حذف المنتج' : 'Delete Product'),
        content: Text(
          isRtl
              ? 'هل أنت متأكد من حذف "${product.name}"؟'
              : 'Are you sure you want to delete "${product.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(isRtl ? 'إلغاء' : 'Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final success = await context
                  .read<MerchantProductsCubit>()
                  .deleteProduct(product.id);
              _showDeleteSnackBar(context, success, isRtl);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(isRtl ? 'حذف' : 'Delete'),
          ),
        ],
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

  void _showDeleteSnackBar(BuildContext context, bool success, bool isRtl) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? (isRtl ? 'تم حذف المنتج بنجاح' : 'Product deleted successfully')
              : (isRtl ? 'فشل في حذف المنتج' : 'Failed to delete product'),
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }
}
