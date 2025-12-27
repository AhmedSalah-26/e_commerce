import 'package:flutter/material.dart';

class OrdersFilterSection extends StatelessWidget {
  final bool isRtl;
  final TextEditingController searchController;
  final String searchQuery;
  final String selectedPeriod;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final ValueChanged<String> onPeriodChanged;

  const OrdersFilterSection({
    super.key,
    required this.isRtl,
    required this.searchController,
    required this.searchQuery,
    required this.selectedPeriod,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      color: theme.scaffoldBackgroundColor,
      child: Column(
        children: [
          _buildSearchField(theme),
          const SizedBox(height: 12),
          _buildPeriodChips(theme),
        ],
      ),
    );
  }

  Widget _buildSearchField(ThemeData theme) {
    return TextField(
      controller: searchController,
      onChanged: onSearchChanged,
      decoration: InputDecoration(
        hintText: isRtl ? 'بحث برقم الطلب...' : 'Search by order ID...',
        prefixIcon: Icon(Icons.search, color: theme.colorScheme.primary),
        suffixIcon: searchQuery.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.clear,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                onPressed: onClearSearch,
              )
            : null,
        filled: true,
        fillColor: theme.colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildPeriodChips(ThemeData theme) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildPeriodChip(isRtl ? 'يوم' : 'Day', 'day', theme),
          const SizedBox(width: 8),
          _buildPeriodChip(isRtl ? 'أسبوع' : 'Week', 'week', theme),
          const SizedBox(width: 8),
          _buildPeriodChip(isRtl ? 'شهر' : 'Month', 'month', theme),
          const SizedBox(width: 8),
          _buildPeriodChip(isRtl ? '3 شهور' : '3 Months', '3months', theme),
        ],
      ),
    );
  }

  Widget _buildPeriodChip(String label, String period, ThemeData theme) {
    final isSelected = selectedPeriod == period;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onPeriodChanged(period),
      selectedColor: theme.colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected
            ? Colors.white
            : theme.colorScheme.onSurface.withValues(alpha: 0.6),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: theme.colorScheme.surface,
      side: BorderSide(
          color: theme.colorScheme.primary, width: isSelected ? 2 : 1),
    );
  }
}
