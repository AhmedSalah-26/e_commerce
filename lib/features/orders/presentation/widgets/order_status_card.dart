import 'package:flutter/material.dart';

import '../../domain/entities/order_entity.dart';

/// Status configuration (single source of truth)
const _statusConfig = <OrderStatus,
    (
  Color color,
  IconData icon,
  String enTitle,
  String arTitle,
  String enDesc,
  String arDesc
)>{
  OrderStatus.pending: (
    Colors.orange,
    Icons.hourglass_empty,
    'Pending',
    'قيد الانتظار',
    'Your order is waiting for review',
    'طلبك في انتظار المراجعة',
  ),
  OrderStatus.processing: (
    Colors.blue,
    Icons.sync,
    'Processing',
    'قيد المعالجة',
    'Your order is being prepared',
    'جاري تجهيز طلبك',
  ),
  OrderStatus.shipped: (
    Colors.purple,
    Icons.local_shipping,
    'Shipped',
    'تم الشحن',
    'Your order is on the way',
    'طلبك في الطريق إليك',
  ),
  OrderStatus.delivered: (
    Colors.green,
    Icons.check_circle,
    'Delivered',
    'تم التوصيل',
    'Your order has been delivered',
    'تم توصيل طلبك بنجاح',
  ),
  OrderStatus.cancelled: (
    Colors.red,
    Icons.cancel,
    'Cancelled',
    'ملغي',
    'Order has been cancelled',
    'تم إلغاء الطلب',
  ),
};

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
    final theme = Theme.of(context);
    final cfg = _statusConfig[order.status]!;

    final color = cfg.$1;
    final icon = cfg.$2;
    final title = isRtl ? cfg.$4 : cfg.$3;
    final desc = isRtl ? cfg.$6 : cfg.$5;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: color),
          const SizedBox(height: 12),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
