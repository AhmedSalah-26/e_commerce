import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../products/domain/repositories/product_repository.dart';
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMerchantHeader(),
          const Divider(height: 1),
          _buildOrderItems(context),
          const Divider(height: 1),
          _buildOrderSummary(),
        ],
      ),
    );
  }

  Widget _buildMerchantHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColours.brownLight.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColours.brownMedium.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.store_outlined,
              color: AppColours.brownMedium,
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
                  style: AppTextStyle.semiBold_12_dark_brown,
                ),
                if (order.merchantPhone != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Row(
                      children: [
                        Icon(Icons.phone_outlined,
                            size: 12, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          order.merchantPhone!,
                          style: AppTextStyle.normal_12_greyDark,
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
                            size: 12, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            order.merchantAddress!,
                            style: AppTextStyle.normal_12_greyDark,
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

  Widget _buildOrderItems(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('products'.tr(), style: AppTextStyle.normal_12_greyDark),
          const SizedBox(height: 8),
          ...order.items.map((item) => _buildOrderItemRow(context, item)),
        ],
      ),
    );
  }

  Widget _buildOrderItemRow(BuildContext context, OrderItemEntity item) {
    return GestureDetector(
      onTap: item.productId != null
          ? () => _navigateToProduct(context, item.productId!)
          : null,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: item.productImage != null
                  ? Image.network(
                      item.productImage!,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
                    )
                  : _buildPlaceholderImage(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName,
                    style: AppTextStyle.bodyMedium.copyWith(
                      color: item.productId != null
                          ? AppColours.brownMedium
                          : null,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.quantity} × ${item.price.toStringAsFixed(2)} ${'egp'.tr()}',
                    style: AppTextStyle.normal_12_greyDark,
                    textDirection: ui.TextDirection.ltr,
                  ),
                ],
              ),
            ),
            Text(
              '${item.itemTotal.toStringAsFixed(2)} ${'egp'.tr()}',
              style: AppTextStyle.semiBold_12_dark_brown,
            ),
            if (item.productId != null)
              const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Icon(Icons.chevron_right, size: 16, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _navigateToProduct(
      BuildContext context, String productId) async {
    try {
      final repository = sl<ProductRepository>();
      final result = await repository.getProductById(productId);
      result.fold(
        (failure) {},
        (product) {
          if (context.mounted) {
            context.push('/product', extra: product);
          }
        },
      );
    } catch (e) {
      // Product not found or error
    }
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 50,
      height: 50,
      color: Colors.grey.shade200,
      child: const Icon(Icons.image_outlined, color: Colors.grey),
    );
  }

  Widget _buildOrderSummary() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _buildSummaryRow('subtotal'.tr(), order.subtotal),
          const SizedBox(height: 4),
          _buildSummaryRow('shipping'.tr(), order.shippingCost),
          const Divider(height: 16),
          _buildSummaryRow('merchant_total'.tr(), order.total, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? AppTextStyle.semiBold_12_dark_brown
              : AppTextStyle.normal_12_greyDark,
        ),
        Text(
          '${amount.toStringAsFixed(2)} ${'egp'.tr()}',
          style: isTotal
              ? AppTextStyle.semiBold_12_dark_brown.copyWith(
                  color: AppColours.brownMedium,
                )
              : AppTextStyle.normal_12_greyDark,
        ),
      ],
    );
  }
}
