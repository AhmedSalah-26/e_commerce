import 'package:flutter/material.dart';

class ReportFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  const ReportFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chipColor = color ?? theme.colorScheme.primary;

    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : chipColor,
          fontSize: 13,
        ),
      ),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: chipColor.withValues(alpha: 0.1),
      selectedColor: chipColor,
      checkmarkColor: Colors.white,
      side: BorderSide(color: chipColor.withValues(alpha: 0.3)),
    );
  }
}
