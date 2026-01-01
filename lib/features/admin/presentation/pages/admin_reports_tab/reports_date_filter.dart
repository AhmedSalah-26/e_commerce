import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../widgets/reports/date_picker_button.dart';
import '../../widgets/reports/quick_filter_chip.dart';

class ReportsDateFilter extends StatelessWidget {
  final bool isRtl;
  final bool isMobile;
  final DateTime? fromDate;
  final DateTime? toDate;
  final bool isFiltering;
  final String? selectedQuickFilter;
  final Future<void> Function(bool) onSelectDate;
  final VoidCallback onApplyFilter;
  final VoidCallback onClearFilter;
  final void Function(int, String) onSetQuickFilter;
  final VoidCallback onSetThisMonth;

  const ReportsDateFilter({
    super.key,
    required this.isRtl,
    required this.isMobile,
    required this.fromDate,
    required this.toDate,
    required this.isFiltering,
    required this.selectedQuickFilter,
    required this.onSelectDate,
    required this.onApplyFilter,
    required this.onClearFilter,
    required this.onSetQuickFilter,
    required this.onSetThisMonth,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('yyyy/MM/dd');

    return Card(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFilterHeader(theme),
            const SizedBox(height: 12),
            _buildDatePickers(dateFormat),
            const SizedBox(height: 8),
            _buildQuickFilters(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterHeader(ThemeData theme) {
    return Row(
      children: [
        Icon(Icons.date_range, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          isRtl ? 'فلتر التاريخ' : 'Date Filter',
          style:
              theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const Spacer(),
        if (isFiltering)
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else if (fromDate != null || toDate != null)
          TextButton(
            onPressed: onClearFilter,
            child: Text(
              isRtl ? 'مسح' : 'Clear',
              style: const TextStyle(color: Colors.red),
            ),
          ),
      ],
    );
  }

  Widget _buildDatePickers(DateFormat dateFormat) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        DatePickerButton(
          label: isRtl ? 'من' : 'From',
          date: fromDate,
          dateFormat: dateFormat,
          onTap: isFiltering ? null : () => onSelectDate(true),
          isRtl: isRtl,
        ),
        DatePickerButton(
          label: isRtl ? 'إلى' : 'To',
          date: toDate,
          dateFormat: dateFormat,
          onTap: isFiltering ? null : () => onSelectDate(false),
          isRtl: isRtl,
        ),
        ElevatedButton.icon(
          onPressed: isFiltering ? null : onApplyFilter,
          icon: const Icon(Icons.filter_alt, size: 18),
          label: Text(isRtl ? 'تطبيق' : 'Apply'),
        ),
      ],
    );
  }

  Widget _buildQuickFilters() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        QuickFilterChip(
          label: isRtl ? 'اليوم' : 'Today',
          isSelected: selectedQuickFilter == 'today',
          onTap: isFiltering ? null : () => onSetQuickFilter(0, 'today'),
        ),
        QuickFilterChip(
          label: isRtl ? 'أمس' : 'Yesterday',
          isSelected: selectedQuickFilter == 'yesterday',
          onTap: isFiltering ? null : () => onSetQuickFilter(1, 'yesterday'),
        ),
        QuickFilterChip(
          label: isRtl ? 'آخر 7 أيام' : 'Last 7 days',
          isSelected: selectedQuickFilter == 'week',
          onTap: isFiltering ? null : () => onSetQuickFilter(7, 'week'),
        ),
        QuickFilterChip(
          label: isRtl ? 'آخر 30 يوم' : 'Last 30 days',
          isSelected: selectedQuickFilter == 'month',
          onTap: isFiltering ? null : () => onSetQuickFilter(30, 'month'),
        ),
        QuickFilterChip(
          label: isRtl ? 'هذا الشهر' : 'This month',
          isSelected: selectedQuickFilter == 'this_month',
          onTap: isFiltering ? null : onSetThisMonth,
        ),
      ],
    );
  }
}
