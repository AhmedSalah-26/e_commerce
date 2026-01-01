import 'package:flutter/material.dart';

class CouponsSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String searchQuery;
  final bool isRtl;
  final bool isDark;
  final ValueChanged<String> onSearch;
  final VoidCallback onClear;

  const CouponsSearchBar({
    super.key,
    required this.controller,
    required this.searchQuery,
    required this.isRtl,
    required this.isDark,
    required this.onSearch,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        decoration: InputDecoration(
          hintText: isRtl ? 'بحث بكود الكوبون...' : 'Search by coupon code...',
          hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black45),
          prefixIcon: Icon(Icons.search,
              color: isDark ? Colors.white54 : Colors.black45),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear,
                      color: isDark ? Colors.white54 : Colors.black45),
                  onPressed: onClear,
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        onSubmitted: onSearch,
      ),
    );
  }
}
