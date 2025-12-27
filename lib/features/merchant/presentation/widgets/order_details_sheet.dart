import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => OrderDetailsSheet(order: order, isRtl: isRtl),
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

  Widget _buildContent(BuildContext context, ScrollController scrollController,
      ThemeData theme) {
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      children: [
        _buildDetailRow(
            isRtl ? 'الحالة' : 'Status', _getStatusText(order.status), theme),
        _buildDetailRow(isRtl ? 'اسم العميل' : 'Customer Name',
            order.customerName ?? (isRtl ? 'غير محدد' : 'N/A'), theme),
        _buildDetailRow(isRtl ? 'رقم الهاتف' : 'Phone',
            order.customerPhone ?? (isRtl ? 'غير محدد' : 'N/A'), theme),
        _buildDetailRow(isRtl ? 'عنوان التوصيل' : 'Delivery Address',
            order.deliveryAddress ?? (isRtl ? 'غير محدد' : 'N/A'), theme),
        // Payment Method
        _buildDetailRow(
          'payment_method'.tr(),
          _getPaymentMethodText(order.paymentMethod),
          theme,
        ),
        // Coupon info if exists
        if (order.hasCoupon) ...[
          _buildDetailRow(
            'coupon_code'.tr(),
            order.couponCode!,
            theme,
          ),
        ],
        const Divider(height: 32),
        Text(isRtl ? 'المنتجات' : 'Products',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            )),
        const SizedBox(height: 12),
        ...order.items
            .map((item) => _ExpandableOrderItem(item: item, isRtl: isRtl)),
        const Divider(height: 32),
        _buildDetailRow(
            isRtl ? 'المجموع الفرعي' : 'Subtotal',
            '${order.subtotal.toStringAsFixed(2)} ${isRtl ? 'ج.م' : 'EGP'}',
            theme),
        // Show coupon discount if exists
        if (order.couponDiscount > 0)
          _buildDetailRow(
            'coupon_discount'.tr(),
            '-${order.couponDiscount.toStringAsFixed(2)} ${isRtl ? 'ج.م' : 'EGP'}',
            theme,
            valueColor: Colors.green,
          ),
        // Show regular discount only if > 0
        if (order.discount > 0)
          _buildDetailRow(
              isRtl ? 'الخصم' : 'Discount',
              '-${order.discount.toStringAsFixed(2)} ${isRtl ? 'ج.م' : 'EGP'}',
              theme),
        _buildDetailRow(
            isRtl ? 'الشحن' : 'Shipping',
            '${order.shippingCost.toStringAsFixed(2)} ${isRtl ? 'ج.م' : 'EGP'}',
            theme),
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

  /// Calculate total with coupon discount applied
  double _calculateTotal() {
    return order.subtotal -
        order.couponDiscount -
        order.discount +
        order.shippingCost;
  }

  /// Get translated payment method text
  String _getPaymentMethodText(String? method) {
    switch (method) {
      case 'cash_on_delivery':
        return 'cash_on_delivery'.tr();
      case 'credit_card':
        return 'credit_card'.tr();
      case 'wallet':
        return 'wallet'.tr();
      default:
        return 'cash_on_delivery'.tr();
    }
  }

  Widget _buildUpdateButton(BuildContext context, ThemeData theme) {
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
          backgroundColor: theme.colorScheme.primary,
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

  Widget _buildDetailRow(String label, String value, ThemeData theme,
      {bool isBold = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: isBold
                  ? TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    )
                  : TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    )),
          Text(
            value,
            style: isBold
                ? TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  )
                : TextStyle(
                    fontSize: 14,
                    color: valueColor ??
                        theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
    }
  }
}

/// Expandable widget for order item with product details
class _ExpandableOrderItem extends StatefulWidget {
  final OrderItemEntity item;
  final bool isRtl;

  const _ExpandableOrderItem({required this.item, required this.isRtl});

  @override
  State<_ExpandableOrderItem> createState() => _ExpandableOrderItemState();
}

class _ExpandableOrderItemState extends State<_ExpandableOrderItem> {
  bool _isExpanded = false;

  String get _locale => widget.isRtl ? 'ar' : 'en';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizedName = widget.item.getLocalizedName(_locale);
    final localizedDescription = widget.item.getLocalizedDescription(_locale);
    final hasDescription =
        localizedDescription != null && localizedDescription.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border:
            Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  // Product Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: widget.item.productImage != null
                        ? CachedNetworkImage(
                            imageUrl: widget.item.productImage!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => _buildPlaceholder(theme),
                            errorWidget: (_, __, ___) =>
                                _buildPlaceholder(theme),
                          )
                        : _buildPlaceholder(theme),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Name
                        Text(
                          localizedName,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        // Quantity display
                        Row(
                          children: [
                            Text(
                              widget.isRtl ? 'الكمية: ' : 'Qty: ',
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                            Text(
                              '${widget.item.quantity}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '× ${widget.item.price.toStringAsFixed(2)} ${widget.isRtl ? 'ج.م' : 'EGP'}',
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                        // Description preview
                        if (hasDescription) ...[
                          const SizedBox(height: 4),
                          Text(
                            localizedDescription,
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${widget.item.itemTotal.toStringAsFixed(2)} ${widget.isRtl ? 'ج.م' : 'EGP'}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded) _buildExpandedDetails(theme),
        ],
      ),
    );
  }

  Widget _buildExpandedDetails(ThemeData theme) {
    final localizedDescription = widget.item.getLocalizedDescription(_locale);
    final productId = widget.item.productId ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
        border: Border(
            top: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.3))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'product_name'.tr(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 4),
          Text(widget.item.getLocalizedName(_locale),
              style: theme.textTheme.bodyMedium),
          const SizedBox(height: 12),
          if (productId.isNotEmpty) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${'product_id'.tr()}: $productId',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: productId));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('product_id_copied'.tr()),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  child: Icon(
                    Icons.copy,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          if (localizedDescription != null &&
              localizedDescription.isNotEmpty) ...[
            Text(
              'product_description'.tr(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              localizedDescription,
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return Container(
      width: 50,
      height: 50,
      color: theme.colorScheme.outline.withValues(alpha: 0.2),
      child: Icon(Icons.image_outlined, color: theme.colorScheme.outline),
    );
  }
}
