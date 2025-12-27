import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/shared_widgets/toast.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../domain/entities/order_entity.dart';
import 'order_card_wrapper.dart';

class OrderInfoCard extends StatelessWidget {
  final OrderEntity order;
  final bool isRtl;

  const OrderInfoCard({
    super.key,
    required this.order,
    required this.isRtl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return OrderCardWrapper(
      title: isRtl ? 'معلومات الطلب' : 'Order Information',
      icon: Icons.receipt_long_outlined,
      children: [
        _buildInfoRow(
          context,
          isRtl ? 'رقم الطلب' : 'Order ID',
          '#${order.id.substring(0, 8)}',
          theme,
          trailing: IconButton(
            icon: Icon(Icons.copy,
                size: 18,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: order.id));
              Tost.showCustomToast(
                context,
                isRtl ? 'تم نسخ رقم الطلب' : 'Order ID copied',
                backgroundColor: Colors.green,
              );
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ),
        Divider(height: 1, color: theme.colorScheme.outline),
        _buildInfoRow(
          context,
          isRtl ? 'تاريخ الطلب' : 'Order Date',
          _formatDateTime(order.createdAt, isRtl),
          theme,
        ),
        Divider(height: 1, color: theme.colorScheme.outline),
        _buildInfoRow(
          context,
          isRtl ? 'عدد المنتجات' : 'Items Count',
          '${order.items.length} ${isRtl ? 'منتج' : 'items'}',
          theme,
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    ThemeData theme, {
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppTextStyle.normal_14_greyDark.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    )),
                const SizedBox(height: 2),
                Text(value,
                    style: AppTextStyle.semiBold_16_dark_brown.copyWith(
                      color: theme.colorScheme.onSurface,
                    )),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  String _formatDateTime(DateTime? date, bool isRtl) {
    if (date == null) return '-';
    final dateStr = '${date.day}/${date.month}/${date.year}';
    final timeStr =
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    return '$dateStr - $timeStr';
  }
}

class CustomerInfoCard extends StatelessWidget {
  final OrderEntity order;
  final bool isRtl;

  const CustomerInfoCard({
    super.key,
    required this.order,
    required this.isRtl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return OrderCardWrapper(
      title: isRtl ? 'معلومات التوصيل' : 'Delivery Information',
      icon: Icons.local_shipping_outlined,
      children: [
        if (order.customerName != null && order.customerName!.isNotEmpty) ...[
          _buildInfoRow(
            context,
            isRtl ? 'اسم المستلم' : 'Recipient Name',
            order.customerName!,
            theme,
            icon: Icons.person_outline,
          ),
          Divider(height: 1, color: theme.colorScheme.outline),
        ],
        if (order.customerPhone != null && order.customerPhone!.isNotEmpty) ...[
          _buildInfoRow(
            context,
            isRtl ? 'رقم الهاتف' : 'Phone Number',
            order.customerPhone!,
            theme,
            icon: Icons.phone_outlined,
            trailing: IconButton(
              icon: Icon(Icons.copy,
                  size: 18,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: order.customerPhone!));
                Tost.showCustomToast(
                  context,
                  isRtl ? 'تم نسخ رقم الهاتف' : 'Phone copied',
                  backgroundColor: Colors.green,
                );
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
          Divider(height: 1, color: theme.colorScheme.outline),
        ],
        if (order.deliveryAddress != null &&
            order.deliveryAddress!.isNotEmpty) ...[
          _buildInfoRow(
            context,
            isRtl ? 'عنوان التوصيل' : 'Delivery Address',
            order.deliveryAddress!,
            theme,
            icon: Icons.location_on_outlined,
            isMultiLine: true,
          ),
        ],
      ],
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    ThemeData theme, {
    IconData? icon,
    Widget? trailing,
    bool isMultiLine = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment:
            isMultiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon,
                size: 18,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppTextStyle.normal_14_greyDark.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    )),
                const SizedBox(height: 2),
                Text(value,
                    style: AppTextStyle.semiBold_16_dark_brown.copyWith(
                      color: theme.colorScheme.onSurface,
                    )),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }
}

class MerchantInfoCard extends StatelessWidget {
  final OrderEntity order;
  final bool isRtl;

  const MerchantInfoCard({
    super.key,
    required this.order,
    required this.isRtl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return OrderCardWrapper(
      title: isRtl ? 'معلومات التاجر' : 'Merchant Information',
      icon: Icons.store_outlined,
      children: [
        if (order.merchantName != null && order.merchantName!.isNotEmpty) ...[
          _buildInfoRow(
            context,
            isRtl ? 'اسم المتجر' : 'Store Name',
            order.merchantName!,
            theme,
            icon: Icons.storefront_outlined,
          ),
        ],
        if (order.merchantPhone != null && order.merchantPhone!.isNotEmpty) ...[
          Divider(height: 1, color: theme.colorScheme.outline),
          _buildInfoRow(
            context,
            isRtl ? 'رقم التاجر' : 'Merchant Phone',
            order.merchantPhone!,
            theme,
            icon: Icons.phone_outlined,
            trailing: IconButton(
              icon: Icon(Icons.copy,
                  size: 18,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: order.merchantPhone!));
                Tost.showCustomToast(
                  context,
                  isRtl ? 'تم نسخ رقم التاجر' : 'Phone copied',
                  backgroundColor: Colors.green,
                );
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
        ],
        if (order.merchantAddress != null &&
            order.merchantAddress!.isNotEmpty) ...[
          Divider(height: 1, color: theme.colorScheme.outline),
          _buildInfoRow(
            context,
            isRtl ? 'عنوان المتجر' : 'Store Address',
            order.merchantAddress!,
            theme,
            icon: Icons.location_on_outlined,
            isMultiLine: true,
          ),
        ],
      ],
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    ThemeData theme, {
    IconData? icon,
    Widget? trailing,
    bool isMultiLine = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment:
            isMultiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon,
                size: 18,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppTextStyle.normal_14_greyDark.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    )),
                const SizedBox(height: 2),
                Text(value,
                    style: AppTextStyle.semiBold_16_dark_brown.copyWith(
                      color: theme.colorScheme.onSurface,
                    )),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }
}
