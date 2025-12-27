import 'dart:async';
import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

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
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: widget.onSearchModeEnter,
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
            Text('search'.tr(),
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                )),
            const SizedBox(width: 8),
            Icon(Icons.search, color: theme.colorScheme.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveSearchBar() {
    final theme = Theme.of(context);

    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
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
        style: TextStyle(
          fontSize: 12,
          color: theme.colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          hintText: 'search'.tr(),
          hintStyle: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      size: 20),
                  onPressed: () {
                    _searchController.clear();
                    widget.onSearchChanged('');
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
