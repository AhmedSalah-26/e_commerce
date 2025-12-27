import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../orders/domain/entities/order_entity.dart';

class OrderCard extends StatelessWidget {
  final OrderEntity order;
  final VoidCallback onTap;

  const OrderCard({
    super.key,
    required this.order,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRtl = context.locale.languageCode == 'ar';
    final statusText = _getStatusText(order.status, isRtl);
    final statusColor = _getStatusColor(order.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: theme.colorScheme.surface,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outline),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${isRtl ? 'طلب رقم' : 'Order'} #${order.id.substring(0, 8)}',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.person_outline,
                      size: 16,
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                  const SizedBox(width: 8),
                  Text(
                    order.customerName ??
                        (isRtl ? 'غير محدد' : 'Not specified'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.shopping_bag_outlined,
                      size: 16,
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                  const SizedBox(width: 8),
                  Text(
                    '${order.items.length} ${isRtl ? 'منتج' : 'items'}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${order.total.toStringAsFixed(2)} ${isRtl ? 'ج.م' : 'EGP'}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.access_time,
                      size: 16,
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('dd/MM/yyyy HH:mm')
                        .format(order.createdAt ?? DateTime.now()),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getStatusText(OrderStatus status, bool isRtl) {
    switch (status) {
      case OrderStatus.pending:
        return isRtl ? 'قيد الانتظار' : 'Pending';
      case OrderStatus.processing:
        return isRtl ? 'قيد التجهيز' : 'Processing';
      case OrderStatus.shipped:
        return isRtl ? 'تم الشحن' : 'Shipped';
      case OrderStatus.delivered:
        return isRtl ? 'تم التوصيل' : 'Delivered';
      case OrderStatus.cancelled:
        return isRtl ? 'ملغي' : 'Cancelled';
    }
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
}
