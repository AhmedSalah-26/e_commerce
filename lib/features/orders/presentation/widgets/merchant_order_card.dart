import 'dart:ui' as ui;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_text_style.dart';
import '../../domain/entities/order_entity.dart';

/// Card widget to display a single merchant's order within a parent order
class MerchantOrderCard extends StatelessWidget {
  final OrderEntity order;
  final bool isRtl;

  const MerchantOrderCard({
    super.key,
    required this.order,
    required this.isRtl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMerchantHeader(theme),
          Divider(height: 1, color: theme.colorScheme.outline),
          _buildOrderItems(context, theme),
          Divider(height: 1, color: theme.colorScheme.outline),
          _buildOrderSummary(theme),
        ],
      ),
    );
  }

  Widget _buildMerchantHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.store_outlined,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.merchantName ?? 'unknown_merchant'.tr(),
                  style: AppTextStyle.semiBold_12_dark_brown.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                if (order.merchantPhone != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Row(
                      children: [
                        Icon(Icons.phone_outlined,
                            size: 12,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6)),
                        const SizedBox(width: 4),
                        Text(
                          order.merchantPhone!,
                          style: AppTextStyle.normal_12_greyDark.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (order.merchantAddress != null &&
                    order.merchantAddress!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: 12,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            order.merchantAddress!,
                            style: AppTextStyle.normal_12_greyDark.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          _buildStatusBadge(order.status),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(OrderStatus status) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case OrderStatus.delivered:
        bgColor = Colors.green.shade100;
        textColor = Colors.green.shade700;
        break;
      case OrderStatus.shipped:
        bgColor = Colors.blue.shade100;
        textColor = Colors.blue.shade700;
        break;
      case OrderStatus.processing:
        bgColor = Colors.orange.shade100;
        textColor = Colors.orange.shade700;
        break;
      case OrderStatus.cancelled:
      case OrderStatus.paymentFailed:
        bgColor = Colors.red.shade100;
        textColor = Colors.red.shade700;
        break;
      default:
        bgColor = Colors.grey.shade100;
        textColor = Colors.grey.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildOrderItems(BuildContext context, ThemeData theme) {
    final locale = context.locale.languageCode;
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('order_products'.tr(),
              style: AppTextStyle.normal_12_greyDark.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              )),
          const SizedBox(height: 8),
          ...order.items
              .map((item) => _buildOrderItemRow(context, item, locale, theme)),
        ],
      ),
    );
  }

  Widget _buildOrderItemRow(BuildContext context, OrderItemEntity item,
      String locale, ThemeData theme) {
    return InkWell(
      onTap: item.productId != null
          ? () => context.push('/product/${item.productId}')
          : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.colorScheme.outline),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: item.productImage != null
                  ? CachedNetworkImage(
                      imageUrl: item.productImage!,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => _buildPlaceholderImage(theme),
                      errorWidget: (_, __, ___) =>
                          _buildPlaceholderImage(theme),
                    )
                  : _buildPlaceholderImage(theme),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.getLocalizedName(locale),
                    style: AppTextStyle.bodyMedium.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.quantity} × ${item.price.toStringAsFixed(2)} ${'egp'.tr()}',
                    style: AppTextStyle.normal_12_greyDark.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    textDirection: ui.TextDirection.ltr,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${item.itemTotal.toStringAsFixed(2)} ${'egp'.tr()}',
                  style: AppTextStyle.semiBold_12_dark_brown.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                if (item.productId != null) ...[
                  const SizedBox(height: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: theme.colorScheme.primary,
                    size: 14,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage(ThemeData theme) {
    return Container(
      width: 50,
      height: 50,
      color: theme.colorScheme.surface,
      child: Icon(Icons.image_outlined,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
    );
  }

  Widget _buildOrderSummary(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _buildSummaryRow('subtotal'.tr(), order.subtotal, theme),
          const SizedBox(height: 4),
          _buildSummaryRow('shipping'.tr(), order.shippingCost, theme),
          Divider(height: 16, color: theme.colorScheme.outline),
          _buildSummaryRow('merchant_total'.tr(), order.total, theme,
              isTotal: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, ThemeData theme,
      {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? AppTextStyle.semiBold_12_dark_brown.copyWith(
                  color: theme.colorScheme.onSurface,
                )
              : AppTextStyle.normal_12_greyDark.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
        ),
        Text(
          '${amount.toStringAsFixed(2)} ${'egp'.tr()}',
          style: isTotal
              ? AppTextStyle.semiBold_12_dark_brown.copyWith(
                  color: theme.colorScheme.primary,
                )
              : AppTextStyle.normal_12_greyDark.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
        ),
      ],
    );
  }
}
