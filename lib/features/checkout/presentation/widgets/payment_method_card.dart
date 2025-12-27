import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class PaymentMethodCard extends StatelessWidget {
  const PaymentMethodCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'payment_method'.tr(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.primary),
          ),
          child: Row(
            children: [
              Icon(Icons.money, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Text(
                'cash_on_delivery'.tr(),
                style: TextStyle(
                  fontSize: 16,
                  color: theme.colorScheme.primary,
                ),
              ),
              const Spacer(),
              const Icon(Icons.check_circle, color: Colors.green),
            ],
          ),
        ),
      ],
    );
  }
}
