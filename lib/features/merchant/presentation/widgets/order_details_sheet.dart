import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../Core/Theme/app_text_style.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../../orders/presentation/cubit/orders_cubit.dart';

class OrderDetailsSheet extends StatelessWidget {
  final OrderEntity order;
  final bool isRtl;

  const OrderDetailsSheet({
    super.key,
    required this.order,
    required this.isRtl,
  });

  static void show(BuildContext context, OrderEntity order, bool isRtl) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => OrderDetailsSheet(order: order, isRtl: isRtl),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Column(
        children: [
          _buildHeader(context),
          Expanded(child: _buildContent(context, scrollController)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColours.primary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${isRtl ? 'تفاصيل الطلب' : 'Order Details'} #${order.id.substring(0, 8)}',
            style: AppTextStyle.semiBold_18_white,
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
      BuildContext context, ScrollController scrollController) {
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      children: [
        _buildDetailRow(
            isRtl ? 'الحالة' : 'Status', _getStatusText(order.status)),
        _buildDetailRow(isRtl ? 'اسم العميل' : 'Customer Name',
            order.customerName ?? (isRtl ? 'غير محدد' : 'N/A')),
        _buildDetailRow(isRtl ? 'رقم الهاتف' : 'Phone',
            order.customerPhone ?? (isRtl ? 'غير محدد' : 'N/A')),
        _buildDetailRow(isRtl ? 'عنوان التوصيل' : 'Delivery Address',
            order.deliveryAddress ?? (isRtl ? 'غير محدد' : 'N/A')),
        const Divider(height: 32),
        Text(isRtl ? 'المنتجات' : 'Products',
            style: AppTextStyle.semiBold_16_dark_brown),
        const SizedBox(height: 12),
        ...order.items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                      child: Text('${item.productName} x${item.quantity}',
                          style: AppTextStyle.normal_14_greyDark)),
                  Text(
                      '${item.price.toStringAsFixed(2)} ${isRtl ? 'ج.م' : 'EGP'}',
                      style: AppTextStyle.semiBold_16_dark_brown),
                ],
              ),
            )),
        const Divider(height: 32),
        _buildDetailRow(isRtl ? 'المجموع الفرعي' : 'Subtotal',
            '${order.subtotal.toStringAsFixed(2)} ${isRtl ? 'ج.م' : 'EGP'}'),
        _buildDetailRow(isRtl ? 'الخصم' : 'Discount',
            '${order.discount.toStringAsFixed(2)} ${isRtl ? 'ج.م' : 'EGP'}'),
        _buildDetailRow(isRtl ? 'الشحن' : 'Shipping',
            '${order.shippingCost.toStringAsFixed(2)} ${isRtl ? 'ج.م' : 'EGP'}'),
        const Divider(height: 24),
        _buildDetailRow(isRtl ? 'الإجمالي' : 'Total',
            '${order.total.toStringAsFixed(2)} ${isRtl ? 'ج.م' : 'EGP'}',
            isBold: true),
        const SizedBox(height: 24),
        if (order.status != OrderStatus.delivered &&
            order.status != OrderStatus.cancelled)
          _buildUpdateButton(context),
      ],
    );
  }

  Widget _buildUpdateButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.pop(context);
          _showUpdateStatusDialog(context);
        },
        icon: const Icon(Icons.update),
        label: Text(isRtl ? 'تحديث الحالة' : 'Update Status'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColours.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  void _showUpdateStatusDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isRtl ? 'تحديث حالة الطلب' : 'Update Order Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusOption(
                ctx,
                OrderStatus.processing,
                isRtl ? 'قيد التجهيز' : 'Processing',
                Icons.hourglass_empty,
                Colors.blue),
            _buildStatusOption(
                ctx,
                OrderStatus.shipped,
                isRtl ? 'تم الشحن' : 'Shipped',
                Icons.local_shipping,
                Colors.purple),
            _buildStatusOption(
                ctx,
                OrderStatus.delivered,
                isRtl ? 'تم التوصيل' : 'Delivered',
                Icons.check_circle,
                Colors.green),
            _buildStatusOption(ctx, OrderStatus.cancelled,
                isRtl ? 'ملغي' : 'Cancelled', Icons.cancel, Colors.red),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isRtl ? 'إلغاء' : 'Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusOption(BuildContext context, OrderStatus newStatus,
      String label, IconData icon, Color color) {
    final isCurrentStatus = order.status == newStatus;
    return ListTile(
      leading: Icon(icon, color: isCurrentStatus ? Colors.grey : color),
      title: Text(
        label,
        style: TextStyle(
          color: isCurrentStatus ? Colors.grey : Colors.black,
          fontWeight: isCurrentStatus ? FontWeight.normal : FontWeight.w500,
        ),
      ),
      enabled: !isCurrentStatus,
      onTap: isCurrentStatus
          ? null
          : () {
              Navigator.pop(context);
              context
                  .read<OrdersCubit>()
                  .updateOrderStatus(order.id, newStatus);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isRtl
                      ? 'تم تحديث حالة الطلب بنجاح'
                      : 'Order status updated successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: isBold
                  ? AppTextStyle.semiBold_16_dark_brown
                  : AppTextStyle.normal_14_greyDark),
          Text(value,
              style: isBold
                  ? AppTextStyle.semiBold_16_dark_brown
                  : AppTextStyle.normal_14_greyDark),
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
    }
  }
}
