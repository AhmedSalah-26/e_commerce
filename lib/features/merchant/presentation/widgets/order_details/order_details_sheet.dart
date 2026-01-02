import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../orders/domain/entities/order_entity.dart';
import '../../../../orders/presentation/cubit/orders_cubit.dart';
import 'expandable_order_item.dart';
import 'order_status_dialog.dart';

class OrderDetailsSheet extends StatelessWidget {
  final OrderEntity order;
  final bool isRtl;
  final OrdersCubit ordersCubit;

  const OrderDetailsSheet({
    super.key,
    required this.order,
    required this.isRtl,
    required this.ordersCubit,
  });

  static void show(BuildContext context, OrderEntity order, bool isRtl) {
    final ordersCubit = context.read<OrdersCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => OrderDetailsSheet(
        order: order,
        isRtl: isRtl,
        ordersCubit: ordersCubit,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Column(
        children: [
          _buildHeader(context, theme),
          Expanded(child: _buildContent(context, scrollController, theme)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${isRtl ? 'تفاصيل الطلب' : 'Order Details'} #${order.id.substring(0, 8)}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ScrollController scrollController,
    ThemeData theme,
  ) {
    final governorateName = order.getGovernorateName(isRtl ? 'ar' : 'en');

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      children: [
        _buildDetailRow(
          isRtl ? 'الحالة' : 'Status',
          _getStatusText(order.status),
          theme,
        ),
        _buildDetailRow(
          isRtl ? 'اسم العميل' : 'Customer Name',
          order.customerName ?? (isRtl ? 'غير محدد' : 'N/A'),
          theme,
        ),
        _buildDetailRow(
          isRtl ? 'رقم الهاتف' : 'Phone',
          order.customerPhone ?? (isRtl ? 'غير محدد' : 'N/A'),
          theme,
        ),
        if (governorateName != null)
          _buildDetailRow(
            isRtl ? 'المحافظة' : 'Governorate',
            governorateName,
            theme,
          ),
        _buildDetailRow(
          isRtl ? 'عنوان التوصيل' : 'Delivery Address',
          order.deliveryAddress ?? (isRtl ? 'غير محدد' : 'N/A'),
          theme,
        ),
        _buildDetailRow(
          'payment_method'.tr(),
          _getPaymentMethodText(order.paymentMethod),
          theme,
        ),
        _buildPaymentStatusRow(theme),
        if (order.hasCoupon)
          _buildDetailRow('coupon_code'.tr(), order.couponCode!, theme),
        const Divider(height: 32),
        Text(
          isRtl ? 'المنتجات' : 'Products',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        ...order.items.map(
          (item) => ExpandableOrderItem(item: item, isRtl: isRtl),
        ),
        const Divider(height: 32),
        _buildDetailRow(
          isRtl ? 'المجموع الفرعي' : 'Subtotal',
          '${order.subtotal.toStringAsFixed(2)} ${isRtl ? 'ج.م' : 'EGP'}',
          theme,
        ),
        if (order.couponDiscount > 0)
          _buildDetailRow(
            'coupon_discount'.tr(),
            '-${order.couponDiscount.toStringAsFixed(2)} ${isRtl ? 'ج.م' : 'EGP'}',
            theme,
            valueColor: Colors.green,
          ),
        if (order.discount > 0)
          _buildDetailRow(
            isRtl ? 'الخصم' : 'Discount',
            '-${order.discount.toStringAsFixed(2)} ${isRtl ? 'ج.م' : 'EGP'}',
            theme,
          ),
        _buildDetailRow(
          isRtl ? 'الشحن' : 'Shipping',
          '${order.shippingCost.toStringAsFixed(2)} ${isRtl ? 'ج.م' : 'EGP'}',
          theme,
        ),
        const Divider(height: 24),
        _buildDetailRow(
          isRtl ? 'الإجمالي' : 'Total',
          '${_calculateTotal().toStringAsFixed(2)} ${isRtl ? 'ج.م' : 'EGP'}',
          theme,
          isBold: true,
        ),
        const SizedBox(height: 24),
        if (order.status != OrderStatus.delivered &&
            order.status != OrderStatus.cancelled)
          _buildUpdateButton(context, theme),
      ],
    );
  }

  double _calculateTotal() {
    return order.subtotal -
        order.couponDiscount -
        order.discount +
        order.shippingCost;
  }

  String _getPaymentMethodText(String? method) {
    switch (method) {
      case 'card':
        return 'card_payment'.tr();
      case 'cash_on_delivery':
        return 'cash_on_delivery'.tr();
      case 'credit_card':
        return 'credit_card'.tr();
      case 'wallet':
        return 'wallet_payment'.tr();
      default:
        return 'cash_on_delivery'.tr();
    }
  }

  Widget _buildPaymentStatusRow(ThemeData theme) {
    final isOnlinePayment =
        order.paymentMethod == 'card' || order.paymentMethod == 'wallet';
    final paymentStatus = order.paymentStatus;

    String statusText;
    Color statusColor;
    IconData statusIcon;

    if (isOnlinePayment) {
      switch (paymentStatus) {
        case 'paid':
          statusText = isRtl ? 'تم الدفع ✓' : 'Paid ✓';
          statusColor = Colors.green;
          statusIcon = Icons.check_circle;
          break;
        case 'failed':
          statusText = isRtl ? 'فشل الدفع ❌' : 'Payment Failed ❌';
          statusColor = Colors.red;
          statusIcon = Icons.cancel;
          break;
        case 'refunded':
          statusText = isRtl ? 'تم الاسترداد' : 'Refunded';
          statusColor = Colors.blue;
          statusIcon = Icons.replay;
          break;
        default:
          statusText = isRtl ? 'في انتظار الدفع' : 'Pending Payment';
          statusColor = Colors.orange;
          statusIcon = Icons.hourglass_empty;
      }
    } else {
      statusText = isRtl ? 'الدفع عند الاستلام' : 'Cash on Delivery';
      statusColor = Colors.grey.shade600;
      statusIcon = Icons.payments_outlined;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            isRtl ? 'حالة الدفع' : 'Payment Status',
            style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, size: 16, color: statusColor),
                const SizedBox(width: 4),
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateButton(BuildContext context, ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.pop(context);
          OrderStatusDialog.show(
            context,
            order: order,
            isRtl: isRtl,
            ordersCubit: ordersCubit,
          );
        },
        icon: const Icon(Icons.update),
        label: Text(isRtl ? 'تحديث الحالة' : 'Update Status'),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    ThemeData theme, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: isBold
                ? TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  )
                : TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface,
                  ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: isBold
                  ? TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    )
                  : TextStyle(
                      fontSize: 14,
                      color: valueColor ?? theme.colorScheme.onSurface,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(OrderStatus status) {
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
      case OrderStatus.paymentFailed:
        return isRtl ? 'فشل الدفع' : 'Payment Failed';
    }
  }
}
