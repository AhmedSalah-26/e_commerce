import 'package:flutter/material.dart';

import 'coupon_discount_badge.dart';
import 'coupon_code_section.dart';
import 'coupon_menu.dart';
import 'coupon_stats_row.dart';
import 'coupon_suspension_reason.dart';
import 'status_info.dart';

class MerchantCouponCard extends StatelessWidget {
  final Map<String, dynamic> coupon;
  final bool isRtl;
  final VoidCallback onToggle;
  final VoidCallback onSuspend;
  final VoidCallback onTap;

  const MerchantCouponCard({
    super.key,
    required this.coupon,
    required this.isRtl,
    required this.onToggle,
    required this.onSuspend,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final code = coupon['code'] ?? '';
    final discountType = coupon['discount_type'] ?? 'percentage';
    final discountValue = (coupon['discount_value'] ?? 0).toDouble();
    final isActive = coupon['is_active'] ?? true;
    final isSuspended = coupon['is_suspended'] ?? false;
    final suspensionReason = coupon['suspension_reason'];

    final store = coupon['stores'] as Map<String, dynamic>?;
    final merchant = store?['profiles'] as Map<String, dynamic>?;
    final merchantName = merchant?['name'] ?? store?['name'] ?? '';
    final usageCount = coupon['usage_count'] ?? 0;
    final usageLimit = coupon['usage_limit'];
    final expiresAt = coupon['expires_at'];

    final isExpired = expiresAt != null &&
        DateTime.tryParse(expiresAt)?.isBefore(DateTime.now()) == true;

    final statusInfo = _getStatusInfo(isSuspended, isActive, isExpired);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surfaceContainerHigh : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSuspended
              ? Colors.red.withValues(alpha: 0.4)
              : (isDark
                  ? Colors.white12
                  : Colors.black.withValues(alpha: 0.06)),
          width: isSuspended ? 1.5 : 1,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CouponDiscountBadge(
                      discountType: discountType,
                      discountValue: discountValue,
                      isSuspended: isSuspended,
                      isRtl: isRtl,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CouponCodeSection(
                        code: code,
                        merchantName: merchantName,
                        isSuspended: isSuspended,
                        isRtl: isRtl,
                      ),
                    ),
                    CouponMenu(
                      isActive: isActive,
                      isSuspended: isSuspended,
                      isRtl: isRtl,
                      onToggle: onToggle,
                      onSuspend: onSuspend,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                CouponStatsRow(
                  statusInfo: statusInfo,
                  usageCount: usageCount,
                  usageLimit: usageLimit,
                  expiresAt: expiresAt,
                  isExpired: isExpired,
                  isDark: isDark,
                ),
                if (isSuspended && suspensionReason != null)
                  CouponSuspensionReason(reason: suspensionReason),
              ],
            ),
          ),
        ),
      ),
    );
  }

  StatusInfo _getStatusInfo(bool isSuspended, bool isActive, bool isExpired) {
    if (isSuspended) {
      return StatusInfo(
        icon: Icons.block_rounded,
        label: isRtl ? 'موقوف' : 'Suspended',
        color: Colors.red,
      );
    } else if (!isActive) {
      return StatusInfo(
        icon: Icons.pause_circle_rounded,
        label: isRtl ? 'معطل' : 'Inactive',
        color: Colors.orange,
      );
    } else if (isExpired) {
      return StatusInfo(
        icon: Icons.timer_off_rounded,
        label: isRtl ? 'منتهي' : 'Expired',
        color: Colors.grey,
      );
    }
    return StatusInfo(
      icon: Icons.check_circle_rounded,
      label: isRtl ? 'نشط' : 'Active',
      color: Colors.green,
    );
  }
}
