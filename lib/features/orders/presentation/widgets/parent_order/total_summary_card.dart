import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../domain/entities/parent_order_entity.dart';

class TotalSummaryCard extends StatelessWidget {
  final ParentOrderEntity parentOrder;

  const TotalSummaryCard({super.key, required this.parentOrder});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPaid = parentOrder.paymentStatus == 'paid';
    final isCardPayment = parentOrder.paymentMethod == 'card';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _PriceRow(label: 'subtotal'.tr(), amount: parentOrder.subtotal),
          const SizedBox(height: 8),
          _PriceRow(label: 'shipping'.tr(), amount: parentOrder.shippingCost),
          if (parentOrder.hasCoupon) ...[
            const SizedBox(height: 8),
            _CouponRow(parentOrder: parentOrder),
          ],
          const Divider(height: 24),
          _PriceRow(
              label: 'total'.tr(), amount: parentOrder.total, isTotal: true),
          // Show amount due for merchant (0 if paid online)
          if (isCardPayment) ...[
            const SizedBox(height: 8),
            _AmountDueRow(isPaid: isPaid, total: parentOrder.total),
          ],
        ],
      ),
    );
  }
}

class _AmountDueRow extends StatelessWidget {
  final bool isPaid;
  final double total;

  const _AmountDueRow({required this.isPaid, required this.total});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final amountDue = isPaid ? 0.0 : total;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isPaid ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                isPaid ? Icons.check_circle : Icons.hourglass_empty,
                size: 18,
                color: isPaid ? Colors.green.shade600 : Colors.orange.shade600,
              ),
              const SizedBox(width: 8),
              Text(
                'amount_due'.tr(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color:
                      isPaid ? Colors.green.shade700 : Colors.orange.shade700,
                ),
              ),
            ],
          ),
          Text(
            '${amountDue.toStringAsFixed(2)} ${'egp'.tr()}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: isPaid ? Colors.green.shade700 : Colors.orange.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final double amount;
  final bool isTotal;

  const _PriceRow({
    required this.label,
    required this.amount,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)
              : theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
        ),
        Text(
          '${amount.toStringAsFixed(2)} ${'egp'.tr()}',
          style: isTotal
              ? theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                )
              : theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
        ),
      ],
    );
  }
}

class _CouponRow extends StatelessWidget {
  final ParentOrderEntity parentOrder;

  const _CouponRow({required this.parentOrder});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.local_offer, size: 16, color: Colors.green.shade600),
            const SizedBox(width: 6),
            Text(
              '${'coupon_discount'.tr()} (${parentOrder.couponCode})',
              style: TextStyle(
                fontSize: 14,
                color: Colors.green.shade600,
              ),
            ),
          ],
        ),
        Text(
          '-${parentOrder.couponDiscount.toStringAsFixed(2)} ${'egp'.tr()}',
          style: TextStyle(
            fontSize: 14,
            color: Colors.green.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
