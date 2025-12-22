import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';

class HomeSearchBar extends StatelessWidget {
  final bool isSearchMode;
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final Function(String) onSearchChanged;
  final VoidCallback onEnterSearchMode;
  final VoidCallback onExitSearchMode;
  final VoidCallback onShowFilter;
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
    required this.hasActiveFilters,
    required this.unreadNotifications,
    required this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Notification icon (right side in RTL)
          if (!isSearchMode)
            GestureDetector(
              onTap: onNotificationTap,
              child: Container(
                width: screenWidth * 0.12,
                height: screenHeight * 0.055,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColours.greyLighter,
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        Icons.notifications,
                        size: screenWidth * 0.055,
                        color: AppColours.brownLight,
                      ),
                    ),
                    if (unreadNotifications > 0)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            unreadNotifications > 9
                                ? '9+'
                                : '$unreadNotifications',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          // Back button when in search mode
          if (isSearchMode)
            IconButton(
              icon: const Icon(Icons.arrow_forward,
                  color: AppColours.brownMedium),
              onPressed: onExitSearchMode,
            ),
          // Search bar (center)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: isSearchMode
                  ? _buildActiveSearchBar(context)
                  : _buildInactiveSearchBar(context),
            ),
          ),
          // Filter button when in search mode
          if (isSearchMode)
            GestureDetector(
              onTap: onShowFilter,
              child: Container(
                height: 45,
                width: 45,
                decoration: BoxDecoration(
                  color: AppColours.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: AppColours.primaryColor, width: 1.5),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(Icons.filter_list,
                        color: AppColours.primaryColor, size: 24),
                    if (hasActiveFilters)
                      Positioned(
                        right: 4,
                        top: 4,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
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

  Widget _buildInactiveSearchBar(BuildContext context) {
    return GestureDetector(
      onTap: onEnterSearchMode,
      child: Container(
        height: 45,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColours.greyLighter,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('search'.tr(), style: AppTextStyle.normal_12_greyDark),
            const SizedBox(width: 8),
            const Icon(Icons.search, color: AppColours.primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveSearchBar(BuildContext context) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: AppColours.greyLighter,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: searchController,
        focusNode: searchFocusNode,
        onChanged: onSearchChanged,
        textAlign: TextAlign.right,
        textDirection: ui.TextDirection.rtl,
        textInputAction: TextInputAction.search,
        style: AppTextStyle.normal_12_black,
        decoration: InputDecoration(
          hintText: 'search'.tr(),
          hintStyle: AppTextStyle.normal_12_greyDark,
          suffixIcon: searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear,
                      color: AppColours.greyMedium, size: 20),
                  onPressed: () {
                    searchController.clear();
                    onSearchChanged('');
                  },
                )
              : null,
          prefixIcon: const Icon(Icons.search, color: AppColours.primaryColor),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}
