import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/payment_method.dart';
import '../cubit/payment_cubit.dart';
import '../cubit/payment_state.dart';

class PaymentMethodSelector extends StatelessWidget {
  final bool enableOnlinePayment;

  const PaymentMethodSelector({
    super.key,
    this.enableOnlinePayment = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = context.locale.languageCode;

    return BlocBuilder<PaymentCubit, PaymentState>(
      builder: (context, state) {
        final selectedMethod = context.read<PaymentCubit>().selectedMethod;

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

            // Cash on Delivery
            _PaymentMethodTile(
              icon: Icons.money,
              title: PaymentMethodType.cashOnDelivery.getName(locale),
              isSelected: selectedMethod == PaymentMethodType.cashOnDelivery,
              onTap: () => context
                  .read<PaymentCubit>()
                  .selectPaymentMethod(PaymentMethodType.cashOnDelivery),
            ),

            if (enableOnlinePayment) ...[
              const SizedBox(height: 8),

              // Credit Card
              _PaymentMethodTile(
                icon: Icons.credit_card,
                title: PaymentMethodType.card.getName(locale),
                isSelected: selectedMethod == PaymentMethodType.card,
                onTap: () => context
                    .read<PaymentCubit>()
                    .selectPaymentMethod(PaymentMethodType.card),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodTile({
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: theme.colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}
