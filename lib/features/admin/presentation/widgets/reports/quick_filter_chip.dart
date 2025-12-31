import 'package:flutter/material.dart';

class QuickFilterChip extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isSelected;

  const QuickFilterChip({
    super.key,
    required this.label,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ActionChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: isSelected ? Colors.white : null,
        ),
      ),
      onPressed: onTap,
      visualDensity: VisualDensity.compact,
      backgroundColor: isSelected ? theme.colorScheme.primary : null,
      side: isSelected ? BorderSide.none : null,
    );
  }
}
