import 'package:flutter/material.dart';

class CouponDiscountBadge extends StatelessWidget {
  final String discountType;
  final double discountValue;
  final bool isSuspended;
  final bool isRtl;

  const CouponDiscountBadge({
    super.key,
    required this.discountType,
    required this.discountValue,
    required this.isSuspended,
    required this.isRtl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isSuspended
              ? [Colors.grey.shade500, Colors.grey.shade600]
              : [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withValues(alpha: 0.85)
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: isSuspended
            ? null
            : [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Text(
        discountType == 'percentage'
            ? '${discountValue.toStringAsFixed(0)}%'
            : '${discountValue.toStringAsFixed(0)} ${isRtl ? 'ج.م' : 'EGP'}',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}
