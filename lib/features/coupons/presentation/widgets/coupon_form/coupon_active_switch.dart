import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class CouponActiveSwitch extends StatelessWidget {
  final bool isActive;
  final ValueChanged<bool> onChanged;

  const CouponActiveSwitch({
    super.key,
    required this.isActive,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SwitchListTile(
      title: Text('is_active'.tr()),
      value: isActive,
      onChanged: onChanged,
      activeTrackColor: theme.colorScheme.primary.withValues(alpha: 0.5),
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return theme.colorScheme.primary;
        }
        return Colors.grey[300];
      }),
      contentPadding: EdgeInsets.zero,
    );
  }
}
