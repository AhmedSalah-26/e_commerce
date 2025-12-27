import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_style.dart';
import '../../domain/entities/order_entity.dart';
import 'order_card_wrapper.dart';

class OrderPriceSummary extends StatelessWidget {
  final OrderEntity order;
  final bool isRtl;

  const OrderPriceSummary({
    super.key,
    required this.order,
    required this.isRtl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return OrderCardWrapper(
      title: isRtl ? 'ملخص السعر' : 'Price Summary',
      icon: Icons.receipt_outlined,
      children: [
        _buildPriceRow(
          isRtl ? 'المجموع الفرعي' : 'Subtotal',
          order.subtotal,
          theme,
        ),
        if (order.discount > 0) ...[
          Divider(height: 1, color: theme.colorScheme.outline),
          _buildPriceRow(
            isRtl ? 'الخصم' : 'Discount',
            -order.discount,
            theme,
            isDiscount: true,
          ),
        ],
        if (order.shippingCost > 0) ...[
          Divider(height: 1, color: theme.colorScheme.outline),
          _buildPriceRow(
            isRtl ? 'الشحن' : 'Shipping',
            order.shippingCost,
            theme,
          ),
        ],
        const Divider(thickness: 2, height: 24),
        _buildPriceRow(
          isRtl ? 'الإجمالي' : 'Total',
          order.total,
          theme,
          isTotal: true,
        ),
      ],
    );
  }

  Widget _buildPriceRow(
    String label,
    double amount,
    ThemeData theme, {
    bool isTotal = false,
    bool isDiscount = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? AppTextStyle.semiBold_16_dark_brown.copyWith(
                    color: theme.colorScheme.onSurface,
                  )
                : AppTextStyle.normal_14_greyDark.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
          ),
          Text(
            '${isDiscount ? '-' : ''}${amount.abs().toStringAsFixed(2)} ${isRtl ? 'ج.م' : 'EGP'}',
            style: isTotal
                ? AppTextStyle.semiBold_20_dark_brown.copyWith(
                    color: theme.colorScheme.primary,
                  )
                : isDiscount
                    ? AppTextStyle.semiBold_16_dark_brown.copyWith(
                        color: Colors.green,
                      )
                    : AppTextStyle.semiBold_16_dark_brown.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
          ),
        ],
      ),
    );
  }
}

class OrderNotesCard extends StatelessWidget {
  final String notes;
  final bool isRtl;

  const OrderNotesCard({
    super.key,
    required this.notes,
    required this.isRtl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return OrderCardWrapper(
      title: isRtl ? 'ملاحظات' : 'Notes',
      icon: Icons.note_outlined,
      children: [
        Text(
          notes,
          style: AppTextStyle.normal_14_greyDark.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}
