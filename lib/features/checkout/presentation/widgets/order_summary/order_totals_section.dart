import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

class OrderTotalsSection extends StatelessWidget {
  final double subtotal;
  final double totalShipping;
  final double total;
  final int merchantCount;
  final double couponDiscount;
  final String? couponCode;

  const OrderTotalsSection({
    super.key,
    required this.subtotal,
    required this.totalShipping,
    required this.total,
    required this.merchantCount,
    this.couponDiscount = 0,
    this.couponCode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (merchantCount <= 1) const Divider(),
        // Subtotal
        _SummaryRow(
          label: 'subtotal'.tr(),
          value: '${subtotal.toStringAsFixed(2)} ${'egp'.tr()}',
        ),
        const SizedBox(height: 8),
        // Shipping
        _ShippingRow(
          totalShipping: totalShipping,
          merchantCount: merchantCount,
        ),
        // Coupon discount
        if (couponDiscount > 0) ...[
          const SizedBox(height: 8),
          _CouponRow(
            couponDiscount: couponDiscount,
            couponCode: couponCode,
          ),
        ],
        const Divider(),
        // Total
        _TotalRow(total: total),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(value),
      ],
    );
  }
}

class _ShippingRow extends StatelessWidget {
  final double totalShipping;
  final int merchantCount;

  const _ShippingRow({
    required this.totalShipping,
    required this.merchantCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text('shipping_cost'.tr()),
            if (merchantCount > 1) ...[
              const SizedBox(width: 4),
              Text(
                '($merchantCount ${'merchants'.tr()})',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ],
        ),
        Text(
          totalShipping > 0
              ? '${totalShipping.toStringAsFixed(2)} ${'egp'.tr()}'
              : '-',
          style: TextStyle(color: totalShipping > 0 ? null : Colors.grey),
        ),
      ],
    );
  }
}

class _CouponRow extends StatelessWidget {
  final double couponDiscount;
  final String? couponCode;

  const _CouponRow({
    required this.couponDiscount,
    this.couponCode,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.local_offer, size: 16, color: Colors.green.shade600),
            const SizedBox(width: 4),
            Text(
              couponCode != null
                  ? '${'coupon_discount'.tr()} ($couponCode)'
                  : 'coupon_discount'.tr(),
              style: TextStyle(color: Colors.green.shade600),
            ),
          ],
        ),
        Text(
          '-${couponDiscount.toStringAsFixed(2)} ${'egp'.tr()}',
          style: TextStyle(
            color: Colors.green.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _TotalRow extends StatelessWidget {
  final double total;

  const _TotalRow({required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'total'.tr(),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          '${total.toStringAsFixed(2)} ${'egp'.tr()}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColours.brownMedium,
          ),
        ),
      ],
    );
  }
}
