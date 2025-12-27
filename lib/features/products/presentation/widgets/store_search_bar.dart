import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_style.dart';

class StoreSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String searchQuery;
  final bool hasActiveFilters;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final VoidCallback onFilterTap;

  const StoreSearchBar({
    super.key,
    required this.controller,
    required this.searchQuery,
    required this.hasActiveFilters,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(child: _buildSearchField(context)),
          const SizedBox(width: 8),
          _buildFilterButton(context),
        ],
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: TextField(
        controller: controller,
        onChanged: onSearchChanged,
        textInputAction: TextInputAction.search,
        style: AppTextStyle.normal_12_black.copyWith(
          color: theme.colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          hintText: 'search'.tr(),
          hintStyle: AppTextStyle.normal_12_greyDark.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      size: 18),
                  onPressed: onClearSearch,
                )
              : null,
          prefixIcon:
              Icon(Icons.search, color: theme.colorScheme.primary, size: 18),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }

  Widget _buildFilterButton(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onFilterTap,
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: theme.colorScheme.primary, width: 1.5),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.filter_list, color: theme.colorScheme.primary, size: 20),
            if (hasActiveFilters)
              Positioned(
                right: 4,
                top: 4,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
