import 'package:flutter/material.dart';

import '../../widgets/coupon_stat_chip.dart';

class CouponsStatsRow extends StatelessWidget {
  final List<Map<String, dynamic>> coupons;
  final bool isRtl;
  final bool isDark;

  const CouponsStatsRow({
    super.key,
    required this.coupons,
    required this.isRtl,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final activeCount = coupons
        .where((c) => c['is_active'] == true && c['is_suspended'] != true)
        .length;
    final suspendedCount =
        coupons.where((c) => c['is_suspended'] == true).length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Wrap(
        spacing: 8,
        children: [
          CouponStatChip(
            label: isRtl ? 'الكل' : 'All',
            count: coupons.length,
            color: Colors.blue,
            isDark: isDark,
          ),
          CouponStatChip(
            label: isRtl ? 'نشط' : 'Active',
            count: activeCount,
            color: Colors.green,
            isDark: isDark,
          ),
          CouponStatChip(
            label: isRtl ? 'موقوف' : 'Suspended',
            count: suspendedCount,
            color: Colors.red,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}
