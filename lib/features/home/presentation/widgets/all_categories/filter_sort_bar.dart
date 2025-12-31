import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Sort options enum
enum SortOption {
  newest,
  priceLowToHigh,
  priceHighToLow,
  topRated,
  bestSelling,
}

/// Extension to get display name for sort options
extension SortOptionExtension on SortOption {
  String get displayName {
    switch (this) {
      case SortOption.newest:
        return 'newest'.tr();
      case SortOption.priceLowToHigh:
        return 'price_low_to_high'.tr();
      case SortOption.priceHighToLow:
        return 'price_high_to_low'.tr();
      case SortOption.topRated:
        return 'top_rated'.tr();
      case SortOption.bestSelling:
        return 'best_sellers'.tr();
    }
  }

  IconData get icon {
    switch (this) {
      case SortOption.newest:
        return Icons.access_time;
      case SortOption.priceLowToHigh:
        return Icons.arrow_upward;
      case SortOption.priceHighToLow:
        return Icons.arrow_downward;
      case SortOption.topRated:
        return Icons.star;
      case SortOption.bestSelling:
        return Icons.trending_up;
    }
  }
}

/// Filter and Sort bar widget
class FilterSortBar extends StatelessWidget {
  final SortOption sortOption;
  final Function(SortOption) onSortChanged;
  final VoidCallback onFilterTap;

  const FilterSortBar({
    super.key,
    required this.sortOption,
    required this.onSortChanged,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          // Filter button
          Expanded(
            child: _ActionButton(
              icon: Icons.tune,
              label: 'filter'.tr(),
              onTap: onFilterTap,
            ),
          ),

          // Divider
          Container(
            height: 24,
            width: 1,
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),

          // Sort button
          Expanded(
            child: _ActionButton(
              icon: Icons.swap_vert,
              label: 'sort'.tr(),
              onTap: () => _showSortSheet(context),
            ),
          ),
        ],
      ),
    );
  }

  void _showSortSheet(BuildContext context) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.swap_vert, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'sort'.tr(),
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Sort options
            ...SortOption.values.map((option) => _SortOptionTile(
                  option: option,
                  isSelected: sortOption == option,
                  onTap: () {
                    onSortChanged(option);
                    Navigator.pop(context);
                  },
                )),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

/// Action button widget (Filter/Sort)
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Sort option tile widget
class _SortOptionTile extends StatelessWidget {
  final SortOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _SortOptionTile({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(
        option.icon,
        color: isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface.withValues(alpha: 0.6),
      ),
      title: Text(
        option.displayName,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check, color: theme.colorScheme.primary)
          : null,
      onTap: onTap,
    );
  }
}
