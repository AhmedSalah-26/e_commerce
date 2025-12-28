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

    IconData paymentIcon;
    String paymentLabel;
    Color iconColor;

    switch (paymentMethod) {
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
              Text(
                paymentLabel,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
