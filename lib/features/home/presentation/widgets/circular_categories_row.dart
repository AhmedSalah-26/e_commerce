import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../categories/domain/entities/category_entity.dart';
import '../../../categories/presentation/cubit/categories_cubit.dart';
import '../../../categories/presentation/cubit/categories_state.dart';

/// Circular categories horizontal bar placed directly under the banner slider
class CircularCategoriesRow extends StatelessWidget {
  final String? selectedCategoryId;
  final Function(String?)? onCategorySelected;
  final VoidCallback? onAllSelected;

  const CircularCategoriesRow({
    super.key,
    this.selectedCategoryId,
    this.onCategorySelected,
    this.onAllSelected,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoriesCubit, CategoriesState>(
      builder: (context, state) {
        if (state is CategoriesLoading) {
          return _buildSkeleton(context);
        }
        if (state is CategoriesLoaded) {
          if (state.categories.isEmpty) {
            return const SizedBox.shrink();
          }
          return _buildCategoriesList(context, state.categories);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildCategoriesList(
      BuildContext context, List<CategoryEntity> categories) {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      height: 98,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length + 1, // +1 for "الكل" (All) button
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          if (index == 0) {
            // "الكل" (All) Category Item
            final isAllActive = selectedCategoryId == null;
            return _buildCategoryItem(
              context: context,
              title: 'all'.tr(),
              isSelected: isAllActive,
              iconWidget: Icon(
                Icons.grid_view_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 28,
              ),
              onTap: () {
                if (onAllSelected != null) {
                  onAllSelected!();
                } else if (onCategorySelected != null) {
                  onCategorySelected!(null);
                } else {
                  context.push('/category-products');
                }
              },
            );
          }

          final category = categories[index - 1];
          final isSelected = selectedCategoryId == category.id;

          return _buildCategoryItem(
            context: context,
            title: category.name,
            imageUrl: category.imageUrl,
            isSelected: isSelected,
            onTap: () {
              if (onCategorySelected != null) {
                onCategorySelected!(category.id);
              } else {
                final encodedName = Uri.encodeComponent(category.name);
                context.push('/category-products?categoryId=${category.id}&categoryName=$encodedName');
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildCategoryItem({
    required BuildContext context,
    required String title,
    String? imageUrl,
    Widget? iconWidget,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Warm subtle background matching reference design
    final circleBgColor = isDark
        ? theme.colorScheme.surfaceContainerHighest
        : const Color(0xFFFAF6F0);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40),
      splashColor: theme.colorScheme.primary.withValues(alpha: 0.1),
      highlightColor: Colors.transparent,
      child: SizedBox(
        width: 68,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Circular image / icon container
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: circleBgColor,
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : isDark
                          ? Colors.white12
                          : const Color(0xFFEFE8DE),
                  width: isSelected ? 2.5 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? theme.colorScheme.primary.withValues(alpha: 0.25)
                        : Colors.black.withValues(alpha: 0.03),
                    blurRadius: isSelected ? 8 : 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: iconWidget != null
                    ? Center(child: iconWidget)
                    : (imageUrl != null && imageUrl.isNotEmpty)
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            width: 62,
                            height: 62,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
                                highlightColor: Colors.grey.shade100,
                                child: Container(
                                  width: 62,
                                  height: 62,
                                  color: Colors.white,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Icon(
                                  Icons.category_outlined,
                                  color: theme.colorScheme.primary,
                                  size: 26,
                                ),
                              );
                            },
                          )
                        : Center(
                            child: Icon(
                              Icons.category_outlined,
                              color: theme.colorScheme.primary,
                              size: 26,
                            ),
                          ),
              ),
            ),
            const SizedBox(height: 6),
            // Category Name Label
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      height: 98,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 6,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          return SizedBox(
            width: 68,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    width: 62,
                    height: 62,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    width: 48,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
