import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class BannerDateField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;
  final VoidCallback onClear;

  const BannerDateField({
    super.key,
    required this.label,
    this.date,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    date != null
                        ? DateFormat('yyyy-MM-dd').format(date!)
                        : 'not_set'.tr(),
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            if (date != null)
              GestureDetector(
                onTap: onClear,
                child: Icon(
                  Icons.clear,
                  size: 18,
                  color: theme.colorScheme.outline,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
