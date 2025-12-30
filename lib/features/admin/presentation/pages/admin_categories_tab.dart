import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/shared_widgets/network_error_widget.dart';
import '../../../../core/utils/error_helper.dart';
import '../../../categories/presentation/cubit/categories_cubit.dart';
import '../../../categories/presentation/cubit/categories_state.dart';
import '../../../categories/domain/entities/category_entity.dart';
import '../../../merchant/presentation/widgets/category_form_dialog.dart';
import '../../../merchant/presentation/widgets/category_list_item.dart';

class AdminCategoriesTab extends StatelessWidget {
  final bool isRtl;
  const AdminCategoriesTab({super.key, required this.isRtl});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CategoriesCubit>()..loadAllCategories(),
      child: _AdminCategoriesContent(isRtl: isRtl),
    );
  }
}

class _AdminCategoriesContent extends StatefulWidget {
  final bool isRtl;
  const _AdminCategoriesContent({required this.isRtl});

  @override
  State<_AdminCategoriesContent> createState() =>
      _AdminCategoriesContentState();
}

class _AdminCategoriesContentState extends State<_AdminCategoriesContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryDialog(context),
        backgroundColor: theme.colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          _buildHeader(theme, isMobile),
          _buildSearchBar(theme, isMobile),
          BlocBuilder<CategoriesCubit, CategoriesState>(
            builder: (context, state) {
              final categories = state is CategoriesLoaded
                  ? state.categories
                  : <CategoryEntity>[];
              final activeCount = categories.where((c) => c.isActive).length;
              final inactiveCount = categories.where((c) => !c.isActive).length;
              return _buildTabBar(activeCount, inactiveCount, theme);
            },
          ),
          Expanded(child: _buildContent(theme)),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, bool isMobile) {
    return Padding(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      child: Center(
        child: Text(
          widget.isRtl ? 'إدارة التصنيفات' : 'Manage Categories',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme, bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: widget.isRtl ? 'البحث عن تصنيف...' : 'Search categories...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          isDense: isMobile,
        ),
        onChanged: (value) => setState(() => _searchQuery = value),
      ),
    );
  }

  Widget _buildTabBar(int activeCount, int inactiveCount, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      color: theme.colorScheme.surface,
      child: TabBar(
        controller: _tabController,
        labelColor: theme.colorScheme.primary,
        unselectedLabelColor:
            theme.colorScheme.onSurface.withValues(alpha: 0.6),
        indicatorColor: theme.colorScheme.primary,
        tabs: [
          Tab(text: '${widget.isRtl ? 'نشط' : 'Active'} ($activeCount)'),
          Tab(
              text:
                  '${widget.isRtl ? 'غير نشط' : 'Inactive'} ($inactiveCount)'),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    return BlocBuilder<CategoriesCubit, CategoriesState>(
      builder: (context, state) {
        if (state is CategoriesLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is CategoriesError) {
          return NetworkErrorWidget(
            message: ErrorHelper.getUserFriendlyMessage(state.message),
            onRetry: () => context.read<CategoriesCubit>().loadAllCategories(),
          );
        }
        if (state is CategoriesLoaded) {
          if (state.categories.isEmpty) {
            return _buildEmptyState(theme);
          }

          final activeCategories =
              state.categories.where((c) => c.isActive).toList();
          final inactiveCategories =
              state.categories.where((c) => !c.isActive).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildCategoriesList(activeCategories, theme, true),
              _buildCategoriesList(inactiveCategories, theme, false),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.category_outlined,
              size: 64,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(
            widget.isRtl ? 'لا توجد تصنيفات' : 'No categories yet',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _showAddCategoryDialog(context),
            icon: const Icon(Icons.add),
            label: Text(widget.isRtl ? 'إضافة تصنيف' : 'Add Category'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesList(
      List<CategoryEntity> categories, ThemeData theme, bool isActive) {
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
                  ? (widget.isRtl ? 'لا توجد نتائج' : 'No results found')
                  : (isActive
                      ? (widget.isRtl
                          ? 'لا توجد تصنيفات نشطة'
                          : 'No active categories')
                      : (widget.isRtl
                          ? 'لا توجد تصنيفات غير نشطة'
                          : 'No inactive categories')),
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async =>
          context.read<CategoriesCubit>().loadAllCategories(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredCategories.length,
        itemBuilder: (context, index) {
          final category = filteredCategories[index];
          return CategoryListItem(
            category: category,
            onEdit: () => _showEditCategoryDialog(context, category),
          );
        },
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final categoriesCubit = context.read<CategoriesCubit>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BlocProvider.value(
        value: categoriesCubit,
        child: CategoryFormDialog(
          isRtl: widget.isRtl,
          onSave: (categoryData) async {
            final success = await categoriesCubit.createCategory(categoryData);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(success
                      ? (widget.isRtl
                          ? 'تم إضافة التصنيف بنجاح'
                          : 'Category added successfully')
                      : (widget.isRtl
                          ? 'فشل في إضافة التصنيف'
                          : 'Failed to add category')),
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

  void _showEditCategoryDialog(BuildContext context, CategoryEntity category) {
    final categoriesCubit = context.read<CategoriesCubit>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BlocProvider.value(
        value: categoriesCubit,
        child: CategoryFormDialog(
          category: category,
          isRtl: widget.isRtl,
          onSave: (categoryData) async {
            final success =
                await categoriesCubit.updateCategory(category.id, categoryData);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(success
                      ? (widget.isRtl
                          ? 'تم تحديث التصنيف بنجاح'
                          : 'Category updated successfully')
                      : (widget.isRtl
                          ? 'فشل في تحديث التصنيف'
                          : 'Failed to update category')),
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
