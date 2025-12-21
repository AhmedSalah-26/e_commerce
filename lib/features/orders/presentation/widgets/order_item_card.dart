import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../domain/entities/order_entity.dart';

class OrderItemCard extends StatelessWidget {
  final OrderEntity order;
  final VoidCallback? onTap;

  const OrderItemCard({
    super.key,
    required this.order,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double imageSize = screenHeight * 0.08;
    double fontSize = screenWidth * 0.04;

    // Get first item image for display
    final firstItem = order.items.isNotEmpty ? order.items.first : null;
    final productImage = firstItem?.productImage ?? '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.2),
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColours.greyLighter),
          color: Colors.white,
        ),
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.03),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Status indicator
                  _buildStatusIndicator(order.status, fontSize),
                  SizedBox(width: screenWidth * 0.04),
                  // Order details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${'order_id'.tr()}: #${order.id.substring(0, 8)}',
                          style: AppTextStyle.bold_18_medium_brown
                              .copyWith(fontSize: fontSize),
                          textAlign: TextAlign.right,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(order.createdAt),
                          style: AppTextStyle.normal_16_brownLight
                              .copyWith(fontSize: fontSize * 0.8),
                        ),
                        if (order.deliveryAddress != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Flexible(
                                child: Text(
                                  order.deliveryAddress!,
                                  style: AppTextStyle.normal_16_brownLight
                                      .copyWith(fontSize: fontSize * 0.75),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.location_on,
                                  size: fontSize * 0.9, color: Colors.grey),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  // Image
                  SizedBox(
                    width: imageSize,
                    height: imageSize,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _buildProductImage(productImage),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Items count and total
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: AppColours.greyLighter),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${order.items.length} ${'items'.tr()}',
                      style: AppTextStyle.normal_16_brownLight
                          .copyWith(fontSize: fontSize * 0.85),
                    ),
                    Text(
                      '${order.total.toStringAsFixed(2)} ${'egp'.tr()}',
                      style: AppTextStyle.semiBold_16_dark_brown
                          .copyWith(fontSize: fontSize),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(OrderStatus status, double fontSize) {
    Color color;
    IconData icon;

    switch (status) {
      case OrderStatus.pending:
        color = Colors.orange;
        icon = Icons.hourglass_empty;
        break;
      case OrderStatus.processing:
        color = Colors.blue;
        icon = Icons.sync;
        break;
      case OrderStatus.shipped:
        color = Colors.purple;
        icon = Icons.local_shipping;
        break;
      case OrderStatus.delivered:
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case OrderStatus.cancelled:
        color = Colors.red;
        icon = Icons.cancel;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: color.withValues(alpha: 0.1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: fontSize * 1.5),
          const SizedBox(height: 4),
          Text(
            _getStatusText(status),
            style: TextStyle(
              color: color,
              fontSize: fontSize * 0.7,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'status_pending'.tr();
      case OrderStatus.processing:
        return 'status_processing'.tr();
      case OrderStatus.shipped:
        return 'status_shipped'.tr();
      case OrderStatus.delivered:
        return 'status_delivered'.tr();
      case OrderStatus.cancelled:
        return 'status_cancelled'.tr();
    }
  }

  Widget _buildProductImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return _buildPlaceholder();
    }

    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }

    return Image.asset(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColours.greyLight,
      child: const Icon(Icons.shopping_bag, color: Colors.grey),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.day}/${date.month}/${date.year}';
  }
}
