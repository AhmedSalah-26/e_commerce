import 'package:flutter/material.dart';
import '../../../../orders/domain/entities/order_entity.dart';
import '../../../../orders/presentation/cubit/orders_cubit.dart';

class OrderStatusDialog extends StatelessWidget {
  final OrderEntity order;
  final bool isRtl;
  final OrdersCubit ordersCubit;

  const OrderStatusDialog({
    super.key,
    required this.order,
    required this.isRtl,
    required this.ordersCubit,
  });

  static void show(
    BuildContext context, {
    required OrderEntity order,
    required bool isRtl,
    required OrdersCubit ordersCubit,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => OrderStatusDialog(
        order: order,
        isRtl: isRtl,
        ordersCubit: ordersCubit,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.update,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isRtl ? 'تحديث حالة الطلب' : 'Update Order Status',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '#${order.id.substring(0, 8)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
            // Status options
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  _buildStatusOption(
                    context,
                    theme,
                    OrderStatus.processing,
                    isRtl ? 'قيد التجهيز' : 'Processing',
                    isRtl
                        ? 'الطلب قيد التحضير والتجهيز'
                        : 'Order is being prepared',
                    Icons.hourglass_empty,
                    Colors.blue,
                  ),
                  _buildStatusOption(
                    context,
                    theme,
                    OrderStatus.shipped,
                    isRtl ? 'تم الشحن' : 'Shipped',
                    isRtl ? 'الطلب في الطريق للعميل' : 'Order is on the way',
                    Icons.local_shipping,
                    Colors.purple,
                  ),
                  _buildStatusOption(
                    context,
                    theme,
                    OrderStatus.delivered,
                    isRtl ? 'تم التوصيل' : 'Delivered',
                    isRtl
                        ? 'تم تسليم الطلب بنجاح'
                        : 'Order delivered successfully',
                    Icons.check_circle,
                    Colors.green,
                  ),
                  _buildStatusOption(
                    context,
                    theme,
                    OrderStatus.cancelled,
                    isRtl ? 'ملغي' : 'Cancelled',
                    isRtl ? 'تم إلغاء الطلب' : 'Order has been cancelled',
                    Icons.cancel,
                    Colors.red,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusOption(
    BuildContext context,
    ThemeData theme,
    OrderStatus newStatus,
    String label,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    final isCurrentStatus = order.status == newStatus;
    final disabledColor = theme.colorScheme.onSurface.withValues(alpha: 0.3);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: isCurrentStatus
            ? theme.colorScheme.primary.withValues(alpha: 0.08)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrentStatus
              ? theme.colorScheme.primary.withValues(alpha: 0.3)
              : theme.colorScheme.outline.withValues(alpha: 0.2),
          width: isCurrentStatus ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isCurrentStatus
              ? null
              : () {
                  Navigator.pop(context);
                  ordersCubit.updateOrderStatus(order.id, newStatus);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isRtl
                            ? 'تم تحديث حالة الطلب بنجاح'
                            : 'Order status updated successfully',
                      ),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (isCurrentStatus ? disabledColor : color)
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: isCurrentStatus ? disabledColor : color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isCurrentStatus
                              ? disabledColor
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: isCurrentStatus
                              ? disabledColor
                              : theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isCurrentStatus)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isRtl ? 'الحالية' : 'Current',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  )
                else
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
