import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class NotesCard extends StatelessWidget {
  final String notes;

  const NotesCard({super.key, required this.notes});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerHighest
            : Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? theme.colorScheme.outline.withValues(alpha: 0.3)
              : Colors.amber.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.note_outlined,
                size: 18,
                color:
                    isDark ? theme.colorScheme.primary : Colors.amber.shade700,
              ),
              const SizedBox(width: 8),
              Text(
                'notes'.tr(),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? theme.colorScheme.primary
                      : Colors.amber.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            notes,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
