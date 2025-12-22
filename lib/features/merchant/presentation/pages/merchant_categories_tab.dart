import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../Core/Theme/app_text_style.dart';
import '../../../categories/presentation/cubit/categories_cubit.dart';
import '../../../categories/presentation/cubit/categories_state.dart';
import '../../../categories/domain/entities/category_entity.dart';
import '../widgets/merchant_empty_state.dart';
import '../widgets/category_form_dialog.dart';
import '../widgets/categories_header.dart';
import '../widgets/categories_search_bar.dart';
import '../widgets/category_list_item.dart';

class MerchantCategoriesTab extends StatefulWidget {
  const MerchantCategoriesTab({super.key});

  @override
  State<MerchantCategoriesTab> createState() => _MerchantCategoriesTabState();
}

class _MerchantCategoriesTabState extends State<MerchantCategoriesTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<CategoriesCubit>().loadCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
              CategoriesHeader(
                title: isRtl ? 'إدارة التصنيفات' : 'Manage Categories',
                onAdd: () => _showAddCategoryDialog(context, isRtl),
              ),
              CategoriesSearchBar(
                controller: _searchController,
                hintText: isRtl ? 'البحث عن تصنيف...' : 'Search categories...',
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                onClear: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                  });
                },
                showClearButton: _searchQuery.isNotEmpty,
              ),
              // Categories list
              Expanded(
                child: BlocBuilder<CategoriesCubit, CategoriesState>(
                  builder: (context, state) {
                    if (state is CategoriesLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is CategoriesError) {
                      return Center(
                        child: Text(
                          state.message,
                          style: AppTextStyle.normal_16_greyDark,
                        ),
                      );
                    } else if (state is CategoriesLoaded) {
                      if (state.categories.isEmpty) {
                        return MerchantEmptyState(
                          icon: Icons.category_outlined,
                          title:
                              isRtl ? 'لا توجد تصنيفات' : 'No categories yet',
                          subtitle: isRtl
                              ? 'ابدأ بإضافة تصنيفاتك'
                              : 'Start by adding categories',
                          actionLabel: isRtl ? 'إضافة تصنيف' : 'Add Category',
                          onAction: () =>
                              _showAddCategoryDialog(context, isRtl),
                        );
                      }

                      // Filter categories by search query
                      final filteredCategories = _searchQuery.isEmpty
                          ? state.categories
                          : state.categories
                              .where((c) => c.name
                                  .toLowerCase()
                                  .contains(_searchQuery.toLowerCase()))
                              .toList();

                      if (filteredCategories.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
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
                          context.read<CategoriesCubit>().loadCategories();
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredCategories.length,
                          itemBuilder: (context, index) {
                            final category = filteredCategories[index];
                            return CategoryListItem(
                              category: category,
                              onEdit: () => _showEditCategoryDialog(
                                  context, category, isRtl),
                              onDelete: () => _showDeleteConfirmation(
                                  context, isRtl, category.id),
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

  void _showAddCategoryDialog(BuildContext context, bool isRtl) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => CategoryFormDialog(
        isRtl: isRtl,
        onSave: (categoryData) async {
          final success = await context
              .read<CategoriesCubit>()
              .createCategory(categoryData);

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  success
                      ? (isRtl
                          ? 'تم إضافة التصنيف بنجاح'
                          : 'Category added successfully')
                      : (isRtl
                          ? 'فشل في إضافة التصنيف'
                          : 'Failed to add category'),
                ),
                backgroundColor: success ? Colors.green : Colors.red,
              ),
            );
          }
          return success;
        },
      ),
    );
  }

  void _showEditCategoryDialog(
      BuildContext context, CategoryEntity category, bool isRtl) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => CategoryFormDialog(
        category: category,
        isRtl: isRtl,
        onSave: (categoryData) async {
          final success = await context
              .read<CategoriesCubit>()
              .updateCategory(category.id, categoryData);

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  success
                      ? (isRtl
                          ? 'تم تحديث التصنيف بنجاح'
                          : 'Category updated successfully')
                      : (isRtl
                          ? 'فشل في تحديث التصنيف'
                          : 'Failed to update category'),
                ),
                backgroundColor: success ? Colors.green : Colors.red,
              ),
            );
          }
          return success;
        },
      ),
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, bool isRtl, String categoryId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isRtl ? 'حذف التصنيف' : 'Delete Category'),
        content: Text(
          isRtl
              ? 'هل أنت متأكد من حذف هذا التصنيف؟'
              : 'Are you sure you want to delete this category?',
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
                  .read<CategoriesCubit>()
                  .deleteCategory(categoryId);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? (isRtl
                              ? 'تم حذف التصنيف بنجاح'
                              : 'Category deleted successfully')
                          : (isRtl
                              ? 'فشل في حذف التصنيف'
                              : 'Failed to delete category'),
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
}
