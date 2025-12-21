import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

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
    return Container(
      padding: const EdgeInsets.all(12),
      color: AppColours.greyLighter,
      child: Column(
        children: [
          _buildSearchField(),
          const SizedBox(height: 12),
          _buildPeriodChips(),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: searchController,
      onChanged: onSearchChanged,
      decoration: InputDecoration(
        hintText: isRtl ? 'بحث برقم الطلب...' : 'Search by order ID...',
        prefixIcon: const Icon(Icons.search, color: AppColours.primary),
        suffixIcon: searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: AppColours.greyDark),
                onPressed: onClearSearch,
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildPeriodChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildPeriodChip(isRtl ? 'يوم' : 'Day', 'day'),
          const SizedBox(width: 8),
          _buildPeriodChip(isRtl ? 'أسبوع' : 'Week', 'week'),
          const SizedBox(width: 8),
          _buildPeriodChip(isRtl ? 'شهر' : 'Month', 'month'),
          const SizedBox(width: 8),
          _buildPeriodChip(isRtl ? '3 شهور' : '3 Months', '3months'),
        ],
      ),
    );
  }

  Widget _buildPeriodChip(String label, String period) {
    final isSelected = selectedPeriod == period;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onPeriodChanged(period),
      selectedColor: AppColours.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColours.greyDark,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: Colors.white,
      side: BorderSide(
        color: AppColours.primary,
        width: isSelected ? 2 : 1,
      ),
    );
  }
}
