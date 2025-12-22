import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
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
    return OrderCardWrapper(
      title: isRtl ? 'ملخص السعر' : 'Price Summary',
      icon: Icons.receipt_outlined,
      children: [
        _buildPriceRow(
          isRtl ? 'المجموع الفرعي' : 'Subtotal',
          order.subtotal,
        ),
        if (order.discount > 0) ...[
          const Divider(height: 1, color: AppColours.greyLighter),
          _buildPriceRow(
            isRtl ? 'الخصم' : 'Discount',
            -order.discount,
            isDiscount: true,
          ),
        ],
        if (order.shippingCost > 0) ...[
          const Divider(height: 1, color: AppColours.greyLighter),
          _buildPriceRow(
            isRtl ? 'الشحن' : 'Shipping',
            order.shippingCost,
          ),
        ],
        const Divider(thickness: 2, height: 24),
        _buildPriceRow(
          isRtl ? 'الإجمالي' : 'Total',
          order.total,
          isTotal: true,
        ),
      ],
    );
  }

  Widget _buildPriceRow(
    String label,
    double amount, {
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
                ? AppTextStyle.semiBold_16_dark_brown
                : AppTextStyle.normal_14_greyDark,
          ),
          Text(
            '${isDiscount ? '-' : ''}${amount.abs().toStringAsFixed(2)} ${isRtl ? 'ج.م' : 'EGP'}',
            style: isTotal
                ? AppTextStyle.semiBold_20_dark_brown.copyWith(
                    color: AppColours.primary,
                  )
                : isDiscount
                    ? AppTextStyle.semiBold_16_dark_brown.copyWith(
                        color: Colors.green,
                      )
                    : AppTextStyle.semiBold_16_dark_brown,
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
    return OrderCardWrapper(
      title: isRtl ? 'ملاحظات' : 'Notes',
      icon: Icons.note_outlined,
      children: [
        Text(
          notes,
          style: AppTextStyle.normal_14_greyDark,
        ),
      ],
    );
  }
}
