import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/shared_widgets/network_error_widget.dart';
import '../../../../core/utils/error_helper.dart';
import '../../../categories/presentation/cubit/categories_cubit.dart';
import '../../../categories/presentation/cubit/categories_state.dart';
import '../../../categories/domain/entities/category_entity.dart';
import '../widgets/merchant_empty_state.dart';
import '../widgets/category_form_dialog.dart';
import '../widgets/categories_search_bar.dart';
import '../widgets/category_list_item.dart';

class MerchantCategoriesTab extends StatelessWidget {
  const MerchantCategoriesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CategoriesCubit>()..loadCategories(),
      child: const _MerchantCategoriesContent(),
    );
  }
}

class _MerchantCategoriesContent extends StatefulWidget {
  const _MerchantCategoriesContent();

  @override
  State<_MerchantCategoriesContent> createState() =>
      _MerchantCategoriesContentState();
}

class _MerchantCategoriesContentState extends State<_MerchantCategoriesContent>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = context.locale.languageCode == 'ar';
    final theme = Theme.of(context);

    return Directionality(
      textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.colorScheme.surface,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            isRtl ? 'إدارة التصنيفات' : 'Manage Categories',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.add, color: theme.colorScheme.primary),
              onPressed: () => _showAddCategoryDialog(context, isRtl),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
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
              BlocBuilder<CategoriesCubit, CategoriesState>(
                builder: (context, state) {
                  final categories = state is CategoriesLoaded
                      ? state.categories
                      : <CategoryEntity>[];
                  final activeCount =
                      categories.where((c) => c.isActive).length;
                  final inactiveCount =
                      categories.where((c) => !c.isActive).length;

                  return _buildTabBar(activeCount, inactiveCount, theme, isRtl);
                },
              ),
              Expanded(
                child: BlocBuilder<CategoriesCubit, CategoriesState>(
                  builder: (context, state) {
                    if (state is CategoriesLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is CategoriesError) {
                      return NetworkErrorWidget(
                        message:
                            ErrorHelper.getUserFriendlyMessage(state.message),
                        onRetry: () =>
                            context.read<CategoriesCubit>().loadCategories(),
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

                      final activeCategories =
                          state.categories.where((c) => c.isActive).toList();
                      final inactiveCategories =
                          state.categories.where((c) => !c.isActive).toList();

                      return TabBarView(
                        controller: _tabController,
                        children: [
                          _buildCategoriesList(
                              activeCategories, isRtl, theme, true),
                          _buildCategoriesList(
                              inactiveCategories, isRtl, theme, false),
                        ],
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

  Widget _buildTabBar(
      int activeCount, int inactiveCount, ThemeData theme, bool isRtl) {
    return Container(
      color: theme.colorScheme.surface,
      child: TabBar(
        controller: _tabController,
        labelColor: theme.colorScheme.primary,
        unselectedLabelColor:
            theme.colorScheme.onSurface.withValues(alpha: 0.6),
        indicatorColor: theme.colorScheme.primary,
        tabs: [
          Tab(text: '${isRtl ? 'نشط' : 'Active'} ($activeCount)'),
          Tab(text: '${isRtl ? 'غير نشط' : 'Inactive'} ($inactiveCount)'),
        ],
      ),
    );
  }

  Widget _buildCategoriesList(List<CategoryEntity> categories, bool isRtl,
      ThemeData theme, bool isActive) {
    // Filter by search query
    final filteredCategories = _searchQuery.isEmpty
        ? categories
        : categories
            .where((c) =>
                c.name.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

    if (filteredCategories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? Icons.category_outlined : Icons.block,
              size: 64,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? (isRtl ? 'لا توجد نتائج' : 'No results found')
                  : (isActive
                      ? (isRtl
                          ? 'لا توجد تصنيفات نشطة'
                          : 'No active categories')
                      : (isRtl
                          ? 'لا توجد تصنيفات غير نشطة'
                          : 'No inactive categories')),
              style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
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
            onEdit: () => _showEditCategoryDialog(context, category, isRtl),
          );
        },
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context, bool isRtl) {
    final categoriesCubit = context.read<CategoriesCubit>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BlocProvider.value(
        value: categoriesCubit,
        child: CategoryFormDialog(
          isRtl: isRtl,
          onSave: (categoryData) async {
            final success = await categoriesCubit.createCategory(categoryData);

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
      ),
    );
  }

  void _showEditCategoryDialog(
      BuildContext context, CategoryEntity category, bool isRtl) {
    final categoriesCubit = context.read<CategoriesCubit>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BlocProvider.value(
        value: categoriesCubit,
        child: CategoryFormDialog(
          category: category,
          isRtl: isRtl,
          onSave: (categoryData) async {
            final success =
                await categoriesCubit.updateCategory(category.id, categoryData);

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
      ),
    );
  }
}
