import 'package:flutter/material.dart';

class CouponSheetHeader extends StatelessWidget {
  final String merchantName;
  final int couponCount;
  final bool isRtl;
  final bool hasActive;
  final bool hasSuspended;
  final VoidCallback onSuspendAll;
  final VoidCallback onUnsuspendAll;

  const CouponSheetHeader({
    super.key,
    required this.merchantName,
    required this.couponCount,
    required this.isRtl,
    required this.hasActive,
    required this.hasSuspended,
    required this.onSuspendAll,
    required this.onUnsuspendAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Row(
            children: [
              const Icon(Icons.local_offer, color: Colors.orange),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isRtl
                          ? 'كوبونات $merchantName'
                          : '$merchantName\'s Coupons',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$couponCount ${isRtl ? 'كوبون' : 'coupons'}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (couponCount > 0) ...[
                if (hasActive)
                  TextButton.icon(
                    onPressed: onSuspendAll,
                    icon: const Icon(Icons.block, size: 18, color: Colors.red),
                    label: Text(
                      isRtl ? 'إيقاف الكل' : 'Suspend All',
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                if (hasSuspended)
                  TextButton.icon(
                    onPressed: onUnsuspendAll,
                    icon: const Icon(Icons.check_circle,
                        size: 18, color: Colors.green),
                    label: Text(
                      isRtl ? 'تفعيل الكل' : 'Unsuspend All',
                      style: const TextStyle(color: Colors.green, fontSize: 12),
                    ),
                  ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
