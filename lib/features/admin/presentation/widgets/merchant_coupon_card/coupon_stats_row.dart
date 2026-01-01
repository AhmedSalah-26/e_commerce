import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'status_chip.dart';
import 'status_info.dart';

class CouponStatsRow extends StatelessWidget {
  final StatusInfo statusInfo;
  final int usageCount;
  final int? usageLimit;
  final String? expiresAt;
  final bool isExpired;
  final bool isDark;

  const CouponStatsRow({
    super.key,
    required this.statusInfo,
    required this.usageCount,
    required this.usageLimit,
    required this.expiresAt,
    required this.isExpired,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        StatusChip(
          icon: statusInfo.icon,
          label: statusInfo.label,
          color: statusInfo.color,
          isDark: isDark,
        ),
        StatusChip(
          icon: Icons.people_outline_rounded,
          label: '$usageCount${usageLimit != null ? '/$usageLimit' : ''}',
          color: isDark ? Colors.white70 : Colors.black54,
          isDark: isDark,
        ),
        if (expiresAt != null)
          StatusChip(
            icon: Icons.event_rounded,
            label: DateFormat('dd/MM').format(DateTime.parse(expiresAt!)),
            color: isExpired
                ? Colors.red
                : (isDark ? Colors.white70 : Colors.black54),
            isDark: isDark,
          ),
      ],
    );
  }
}
