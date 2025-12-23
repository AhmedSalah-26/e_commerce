import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

class OrderTotalsSection extends StatelessWidget {
  final double subtotal;
  final double totalShipping;
  final double total;
  final int merchantCount;

  const OrderTotalsSection({
    super.key,
    required this.subtotal,
    required this.totalShipping,
    required this.total,
    required this.merchantCount,
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
