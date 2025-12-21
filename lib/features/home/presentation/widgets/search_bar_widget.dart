import 'dart:async';
import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';

class SearchBarWidget extends StatefulWidget {
  final Function(String) onSearchChanged;
  final VoidCallback onSearchModeEnter;
  final VoidCallback onSearchModeExit;
  final bool isSearchMode;

  const SearchBarWidget({
    super.key,
    required this.onSearchChanged,
    required this.onSearchModeEnter,
    required this.onSearchModeExit,
    required this.isSearchMode,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _debounceTimer;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();

    if (query.isEmpty) {
      widget.onSearchChanged('');
      return;
    }

    _debounceTimer = Timer(const Duration(seconds: 1), () {
      widget.onSearchChanged(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isSearchMode) {
      return _buildInactiveSearchBar();
    }
    return _buildActiveSearchBar();
  }

  Widget _buildInactiveSearchBar() {
    return GestureDetector(
      onTap: widget.onSearchModeEnter,
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

  Widget _buildActiveSearchBar() {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: AppColours.greyLighter,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onChanged: _onSearchChanged,
        textAlign: TextAlign.right,
        textDirection: ui.TextDirection.rtl,
        textInputAction: TextInputAction.search,
        onSubmitted: (value) {
          _debounceTimer?.cancel();
          if (value.isNotEmpty) {
            widget.onSearchChanged(value);
          }
        },
        style: AppTextStyle.normal_12_black,
        decoration: InputDecoration(
          hintText: 'search'.tr(),
          hintStyle: AppTextStyle.normal_12_greyDark,
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear,
                      color: AppColours.greyMedium, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    widget.onSearchChanged('');
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
