import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../Core/Theme/app_text_style.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../categories/presentation/cubit/categories_cubit.dart';
import '../../../categories/presentation/cubit/categories_state.dart';
import '../../../categories/domain/entities/category_entity.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../cubit/merchant_products_cubit.dart';
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
  String _activityFilter = 'all'; // 'all', 'active', 'inactive'

  @override
  void initState() {
    super.initState();
  }

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

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((p) {
        return p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            p.description.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Filter by category
    if (_selectedCategoryId != null) {
      filtered =
          filtered.where((p) => p.categoryId == _selectedCategoryId).toList();
    }

    // Filter by activity status
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
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColours.primary,
                      AppColours.brownLight,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isRtl ? 'إدارة المخزون' : 'Manage Inventory',
                          style: AppTextStyle.semiBold_22_white,
                        ),
                        IconButton(
                          onPressed: () {
                            _showAddProductDialog(context, isRtl);
                          },
                          icon: const Icon(
                            Icons.add_circle_outline,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    BlocBuilder<MerchantProductsCubit, MerchantProductsState>(
                      builder: (context, state) {
                        if (state is MerchantProductsLoaded) {
                          final activeProducts =
                              state.products.where((p) => p.isActive).length;
                          return Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  isRtl ? 'المنتجات' : 'Products',
                                  state.products.length.toString(),
                                  Icons.inventory_2,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  isRtl ? 'المنتجات النشطة' : 'Active',
                                  activeProducts.toString(),
                                  Icons.check_circle,
                                ),
                              ),
                            ],
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
              // Search and Filter
              Container(
                padding: const EdgeInsets.all(16),
                color: AppColours.greyLighter,
                child: Column(
                  children: [
                    // Search Bar
                    TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText:
                            isRtl ? 'البحث عن منتج...' : 'Search products...',
                        prefixIcon:
                            Icon(Icons.search, color: AppColours.greyDark),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear,
                                    color: AppColours.greyDark),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Activity Filter
                    Row(
                      children: [
                        _buildActivityChip(
                            isRtl ? 'الكل' : 'All', 'all', isRtl),
                        const SizedBox(width: 8),
                        _buildActivityChip(
                            isRtl ? 'نشط' : 'Active', 'active', isRtl),
                        const SizedBox(width: 8),
                        _buildActivityChip(
                            isRtl ? 'غير نشط' : 'Inactive', 'inactive', isRtl),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Category Filter - Dropdown with Search
                    BlocBuilder<CategoriesCubit, CategoriesState>(
                      builder: (context, state) {
                        if (state is CategoriesLoaded) {
                          return GestureDetector(
                            onTap: () => _showCategorySearchDialog(
                                context, state.categories, isRtl),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColours.primary),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.category_outlined,
                                      color: AppColours.primary, size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _selectedCategoryId == null
                                          ? (isRtl
                                              ? 'جميع التصنيفات'
                                              : 'All Categories')
                                          : state.categories
                                              .firstWhere((c) =>
                                                  c.id == _selectedCategoryId)
                                              .name,
                                      style:
                                          TextStyle(color: AppColours.greyDark),
                                    ),
                                  ),
                                  Icon(Icons.keyboard_arrow_down,
                                      color: AppColours.primary),
                                ],
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
              // Products list
              Expanded(
                child:
                    BlocBuilder<MerchantProductsCubit, MerchantProductsState>(
                  builder: (context, state) {
                    if (state is MerchantProductsLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is MerchantProductsError) {
                      return Center(
                        child: Text(
                          state.message,
                          style: AppTextStyle.normal_16_greyDark,
                        ),
                      );
                    } else if (state is MerchantProductsLoaded) {
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
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: AppColours.greyLight,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                isRtl ? 'لا توجد نتائج' : 'No results found',
                                style: AppTextStyle.semiBold_16_dark_brown,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                isRtl
                                    ? 'جرب البحث بكلمات أخرى'
                                    : 'Try different search terms',
                                style: AppTextStyle.normal_14_greyDark,
                              ),
                            ],
                          ),
                        );
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
                            return MerchantProductCard(
                              product: filteredProducts[index],
                              onEdit: () {
                                _showEditProductDialog(
                                    context, filteredProducts[index], isRtl);
                              },
                              onDelete: () {
                                _showDeleteProductConfirmation(
                                    context, filteredProducts[index], isRtl);
                              },
                            );
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
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityChip(String label, String value, bool isRtl) {
    final isSelected = _activityFilter == value;
    Color chipColor;
    if (value == 'active') {
      chipColor = Colors.green;
    } else if (value == 'inactive') {
      chipColor = Colors.grey;
    } else {
      chipColor = AppColours.primary;
    }

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _activityFilter = value;
        });
      },
      selectedColor: chipColor,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColours.greyDark,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: Colors.white,
      side: BorderSide(
        color: Colors.black,
        width: isSelected ? 2 : 1,
      ),
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

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? (isRtl
                              ? 'تم إضافة المنتج بنجاح'
                              : 'Product added successfully')
                          : (isRtl
                              ? 'فشل في إضافة المنتج'
                              : 'Failed to add product'),
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
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
            final authState = context.read<AuthCubit>().state;
            if (authState is AuthAuthenticated) {
              final success = await context
                  .read<MerchantProductsCubit>()
                  .updateProduct(product.id, productData);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? (isRtl
                              ? 'تم تحديث المنتج بنجاح'
                              : 'Product updated successfully')
                          : (isRtl
                              ? 'فشل في تحديث المنتج'
                              : 'Failed to update product'),
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
              return success;
            }
            return false;
          },
        ),
      ),
    );
  }

  void _showDeleteProductConfirmation(
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

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? (isRtl
                              ? 'تم حذف المنتج بنجاح'
                              : 'Product deleted successfully')
                          : (isRtl
                              ? 'فشل في حذف المنتج'
                              : 'Failed to delete product'),
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(isRtl ? 'حذف' : 'Delete'),
          ),
        ],
      ),
    );
  }

  void _showCategorySearchDialog(
      BuildContext context, List<CategoryEntity> categories, bool isRtl) {
    String searchQuery = '';
    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final filteredCategories = searchQuery.isEmpty
                ? categories
                : categories
                    .where((c) => c.name
                        .toLowerCase()
                        .contains(searchQuery.toLowerCase()))
                    .toList();

            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Container(
                constraints:
                    const BoxConstraints(maxHeight: 400, maxWidth: 400),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColours.primary,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16)),
                      ),
                      child: Row(
                        children: [
                          Text(
                            isRtl ? 'اختر التصنيف' : 'Select Category',
                            style: AppTextStyle.semiBold_18_white,
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.pop(dialogContext),
                          ),
                        ],
                      ),
                    ),
                    // Search
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: TextField(
                        onChanged: (value) {
                          setDialogState(() {
                            searchQuery = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: isRtl
                              ? 'البحث عن تصنيف...'
                              : 'Search category...',
                          prefixIcon:
                              Icon(Icons.search, color: AppColours.primary),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColours.primary),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColours.primary),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: AppColours.primary, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    // Categories List
                    Flexible(
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          // All Categories option
                          ListTile(
                            leading: Icon(Icons.all_inclusive,
                                color: AppColours.primary),
                            title: Text(
                              isRtl ? 'جميع التصنيفات' : 'All Categories',
                              style: TextStyle(
                                color: _selectedCategoryId == null
                                    ? AppColours.primary
                                    : AppColours.greyDark,
                                fontWeight: _selectedCategoryId == null
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            trailing: _selectedCategoryId == null
                                ? Icon(Icons.check, color: AppColours.primary)
                                : null,
                            onTap: () {
                              setState(() {
                                _selectedCategoryId = null;
                              });
                              Navigator.pop(dialogContext);
                            },
                          ),
                          const Divider(height: 1),
                          // Category items
                          ...filteredCategories.map((category) {
                            final isSelected =
                                _selectedCategoryId == category.id;
                            return ListTile(
                              leading: Icon(Icons.category,
                                  color: isSelected
                                      ? AppColours.primary
                                      : AppColours.greyDark),
                              title: Text(
                                category.name,
                                style: TextStyle(
                                  color: isSelected
                                      ? AppColours.primary
                                      : AppColours.greyDark,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              trailing: isSelected
                                  ? Icon(Icons.check, color: AppColours.primary)
                                  : null,
                              onTap: () {
                                setState(() {
                                  _selectedCategoryId = category.id;
                                });
                                Navigator.pop(dialogContext);
                              },
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
