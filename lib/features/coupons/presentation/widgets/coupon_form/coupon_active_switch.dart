import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

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
    return SwitchListTile(
      title: Text('is_active'.tr()),
      value: isActive,
      onChanged: onChanged,
      activeTrackColor: AppColours.brownMedium.withValues(alpha: 0.5),
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected))
          return AppColours.brownMedium;
        return null;
      }),
      contentPadding: EdgeInsets.zero,
    );
  }
}
