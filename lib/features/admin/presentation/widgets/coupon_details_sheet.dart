import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CouponDetailsSheet extends StatelessWidget {
  final Map<String, dynamic> coupon;
  final bool isRtl;

  const CouponDetailsSheet({
    super.key,
    required this.coupon,
    required this.isRtl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final code = coupon['code'] ?? '';
    final discountType = coupon['discount_type'] ?? 'percentage';
    final discountValue = (coupon['discount_value'] ?? 0).toDouble();
    final store = coupon['stores'] as Map<String, dynamic>?;
    final merchant = store?['profiles'] as Map<String, dynamic>?;
    final merchantName = merchant?['name'] ?? '';
    final merchantEmail = merchant?['email'] ?? '';
    final usageCount = coupon['usage_count'] ?? 0;
    final usageLimit = coupon['usage_limit'];
    final minOrder = coupon['min_order_amount'];
    final maxDiscount = coupon['max_discount_amount'];
    final createdAt = coupon['created_at'];
    final expiresAt = coupon['expires_at'];
    final isSuspended = coupon['is_suspended'] ?? false;
    final suspensionReason = coupon['suspension_reason'];

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Code
                Text(
                  code,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),

                // Discount Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isSuspended
                          ? [Colors.grey, Colors.grey.shade600]
                          : [
                              theme.colorScheme.primary,
                              theme.colorScheme.primary.withValues(alpha: 0.8)
                            ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    discountType == 'percentage'
                        ? '${discountValue.toStringAsFixed(0)}% ${isRtl ? 'خصم' : 'OFF'}'
                        : '${discountValue.toStringAsFixed(0)} ${isRtl ? 'ج.م خصم' : 'EGP OFF'}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

                // Suspension Warning
                if (isSuspended) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: Colors.red.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.block, color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            suspensionReason ??
                                (isRtl
                                    ? 'هذا الكوبون موقوف'
                                    : 'This coupon is suspended'),
                            style: const TextStyle(
                                color: Colors.red, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Details
                _DetailRow(
                  icon: Icons.store_rounded,
                  label: isRtl ? 'التاجر' : 'Merchant',
                  value: merchantName.isEmpty ? '-' : merchantName,
                  isDark: isDark,
                ),
                if (merchantEmail.isNotEmpty)
                  _DetailRow(
                    icon: Icons.email_rounded,
                    label: isRtl ? 'البريد' : 'Email',
                    value: merchantEmail,
                    isDark: isDark,
                  ),
                _DetailRow(
                  icon: Icons.people_rounded,
                  label: isRtl ? 'الاستخدام' : 'Usage',
                  value:
                      '$usageCount${usageLimit != null ? ' / $usageLimit' : ' (${isRtl ? 'غير محدود' : 'Unlimited'})'}',
                  isDark: isDark,
                ),
                if (minOrder != null)
                  _DetailRow(
                    icon: Icons.shopping_cart_rounded,
                    label: isRtl ? 'الحد الأدنى' : 'Min Order',
                    value: '$minOrder ${isRtl ? 'ج.م' : 'EGP'}',
                    isDark: isDark,
                  ),
                if (maxDiscount != null)
                  _DetailRow(
                    icon: Icons.discount_rounded,
                    label: isRtl ? 'أقصى خصم' : 'Max Discount',
                    value: '$maxDiscount ${isRtl ? 'ج.م' : 'EGP'}',
                    isDark: isDark,
                  ),
                if (createdAt != null)
                  _DetailRow(
                    icon: Icons.calendar_today_rounded,
                    label: isRtl ? 'تاريخ الإنشاء' : 'Created',
                    value: DateFormat('dd/MM/yyyy')
                        .format(DateTime.parse(createdAt)),
                    isDark: isDark,
                  ),
                if (expiresAt != null)
                  _DetailRow(
                    icon: Icons.event_rounded,
                    label: isRtl ? 'تاريخ الانتهاء' : 'Expires',
                    value: DateFormat('dd/MM/yyyy')
                        .format(DateTime.parse(expiresAt)),
                    isDark: isDark,
                    isWarning:
                        DateTime.parse(expiresAt).isBefore(DateTime.now()),
                  ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;
  final bool isWarning;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        isWarning ? Colors.red : (isDark ? Colors.white60 : Colors.black54);
    final valueColor =
        isWarning ? Colors.red : (isDark ? Colors.white : Colors.black87);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color:
                  (isWarning ? Colors.red : Colors.grey).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: color, fontSize: 14)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
                fontWeight: FontWeight.w600, fontSize: 14, color: valueColor),
          ),
        ],
      ),
    );
  }
}
