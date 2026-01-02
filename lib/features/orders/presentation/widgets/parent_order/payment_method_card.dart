import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../domain/entities/parent_order_entity.dart';

class PaymentMethodCard extends StatelessWidget {
  final ParentOrderEntity parentOrder;

  const PaymentMethodCard({super.key, required this.parentOrder});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final paymentMethod = parentOrder.paymentMethod ?? 'cash_on_delivery';
    // For card payments, default status should be 'pending', not 'cash_on_delivery'
    final paymentStatus = parentOrder.paymentStatus ??
        (paymentMethod == 'card' ? 'pending' : 'cash_on_delivery');

    IconData paymentIcon;
    String paymentLabel;
    Color iconColor;

    // Determine display based on payment method
    switch (paymentMethod) {
      case 'card':
        paymentIcon = Icons.credit_card;
        paymentLabel = 'card_payment'.tr();
        iconColor = Colors.blue.shade600;
        break;
      case 'credit_card':
        paymentIcon = Icons.credit_card;
        paymentLabel = 'credit_card'.tr();
        iconColor = Colors.blue.shade600;
        break;
      case 'wallet':
        paymentIcon = Icons.account_balance_wallet;
        paymentLabel = 'wallet'.tr();
        iconColor = Colors.purple.shade600;
        break;
      default:
        paymentIcon = Icons.payments_outlined;
        paymentLabel = 'cash_on_delivery'.tr();
        iconColor = Colors.green.shade600;
    }

    // Payment status info
    String statusLabel;
    Color statusColor;
    IconData statusIcon;

    switch (paymentStatus) {
      case 'paid':
        statusLabel = 'payment_paid'.tr();
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'pending':
        statusLabel = 'payment_pending'.tr();
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_empty;
        break;
      case 'failed':
        statusLabel = 'payment_failed'.tr();
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusLabel = 'cash_on_delivery'.tr();
        statusColor = Colors.green.shade600;
        statusIcon = Icons.payments_outlined;
    }

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'payment_method'.tr(),
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(paymentIcon, size: 24, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      paymentLabel,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (paymentMethod == 'card') ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(statusIcon, size: 16, color: statusColor),
                          const SizedBox(width: 4),
                          Text(
                            statusLabel,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
