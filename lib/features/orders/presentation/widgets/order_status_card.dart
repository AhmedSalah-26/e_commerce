import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_style.dart';
import '../../domain/entities/order_entity.dart';

class OrderStatusCard extends StatelessWidget {
  final OrderEntity order;
  final bool isRtl;

  const OrderStatusCard({
    super.key,
    required this.order,
    required this.isRtl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _getStatusColor(order.status).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getStatusColor(order.status).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            _getStatusIcon(order.status),
            size: 48,
            color: _getStatusColor(order.status),
          ),
          const SizedBox(height: 12),
          Text(
            _getStatusText(order.status, isRtl),
            style: AppTextStyle.semiBold_20_dark_brown.copyWith(
              color: _getStatusColor(order.status),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _getStatusDescription(order.status, isRtl),
            style: AppTextStyle.normal_14_greyDark,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.processing:
        return Colors.blue;
      case OrderStatus.shipped:
        return Colors.purple;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.hourglass_empty;
      case OrderStatus.processing:
        return Icons.sync;
      case OrderStatus.shipped:
        return Icons.local_shipping;
      case OrderStatus.delivered:
        return Icons.check_circle;
      case OrderStatus.cancelled:
        return Icons.cancel;
    }
  }

  String _getStatusText(OrderStatus status, bool isRtl) {
    switch (status) {
      case OrderStatus.pending:
        return isRtl ? 'قيد الانتظار' : 'Pending';
      case OrderStatus.processing:
        return isRtl ? 'قيد المعالجة' : 'Processing';
      case OrderStatus.shipped:
        return isRtl ? 'تم الشحن' : 'Shipped';
      case OrderStatus.delivered:
        return isRtl ? 'تم التوصيل' : 'Delivered';
      case OrderStatus.cancelled:
        return isRtl ? 'ملغي' : 'Cancelled';
    }
  }

  String _getStatusDescription(OrderStatus status, bool isRtl) {
    switch (status) {
      case OrderStatus.pending:
        return isRtl
            ? 'طلبك في انتظار المراجعة'
            : 'Your order is waiting for review';
      case OrderStatus.processing:
        return isRtl ? 'جاري تجهيز طلبك' : 'Your order is being prepared';
      case OrderStatus.shipped:
        return isRtl ? 'طلبك في الطريق إليك' : 'Your order is on the way';
      case OrderStatus.delivered:
        return isRtl ? 'تم توصيل طلبك بنجاح' : 'Your order has been delivered';
      case OrderStatus.cancelled:
        return isRtl ? 'تم إلغاء الطلب' : 'Order has been cancelled';
    }
  }
}
