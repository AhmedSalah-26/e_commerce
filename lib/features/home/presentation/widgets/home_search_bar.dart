import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class HomeSearchBar extends StatelessWidget {
  final bool isSearchMode;
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final Function(String) onSearchChanged;
  final VoidCallback onEnterSearchMode;
  final VoidCallback onExitSearchMode;
  final VoidCallback onShowFilter;
  final VoidCallback? onClearFilters;
  final bool hasActiveFilters;
  final int unreadNotifications;
  final VoidCallback onNotificationTap;

  const HomeSearchBar({
    super.key,
    required this.isSearchMode,
    required this.searchController,
    required this.searchFocusNode,
    required this.onSearchChanged,
    required this.onEnterSearchMode,
    required this.onExitSearchMode,
    required this.onShowFilter,
    this.onClearFilters,
    required this.hasActiveFilters,
    required this.unreadNotifications,
    required this.onNotificationTap,
  });

  void _handleBackPress() {
    if (searchController.text.isNotEmpty || hasActiveFilters) {
      searchController.clear();
      if (onClearFilters != null) onClearFilters!();
      return;
    }
    onExitSearchMode();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (!isSearchMode)
            GestureDetector(
              onTap: onNotificationTap,
              child: Container(
                width: screenWidth * 0.12,
                height: screenHeight * 0.055,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: theme.scaffoldBackgroundColor,
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(Icons.notifications,
                          size: screenWidth * 0.055,
                          color: theme.colorScheme.primary),
                    ),
                    if (unreadNotifications > 0)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                              color: Colors.red, shape: BoxShape.circle),
                          constraints:
                              const BoxConstraints(minWidth: 16, minHeight: 16),
                          child: Text(
                            unreadNotifications > 9
                                ? '9+'
                                : '$unreadNotifications',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          if (isSearchMode)
            IconButton(
              icon: Icon(Icons.arrow_forward, color: theme.colorScheme.primary),
              onPressed: _handleBackPress,
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: isSearchMode
                  ? _buildActiveSearchBar(context, theme)
                  : _buildInactiveSearchBar(context, theme),
            ),
          ),
          if (isSearchMode)
            GestureDetector(
              onTap: onShowFilter,
              child: Container(
                height: 45,
                width: 45,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: theme.colorScheme.primary, width: 1.5),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(Icons.filter_list,
                        color: theme.colorScheme.primary, size: 24),
                    if (hasActiveFilters)
                      Positioned(
                        right: 4,
                        top: 4,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                              color: Colors.red, shape: BoxShape.circle),
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInactiveSearchBar(BuildContext context, ThemeData theme) {
    return GestureDetector(
      onTap: onEnterSearchMode,
      child: Container(
        height: 45,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'search'.tr(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.search, color: theme.colorScheme.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveSearchBar(BuildContext context, ThemeData theme) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: searchController,
        focusNode: searchFocusNode,
        onChanged: onSearchChanged,
        textAlign: TextAlign.right,
        textDirection: ui.TextDirection.rtl,
        textInputAction: TextInputAction.search,
        style: theme.textTheme.bodyMedium,
        decoration: InputDecoration(
          hintText: 'search'.tr(),
          hintStyle: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          suffixIcon: searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      size: 20),
                  onPressed: () {
                    searchController.clear();
                    onSearchChanged('');
                  },
                )
              : null,
          prefixIcon: Icon(Icons.search, color: theme.colorScheme.primary),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}
