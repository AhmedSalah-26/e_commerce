import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/shared_widgets/toast.dart';
import '../../domain/entities/order_entity.dart';

class OrderDetailsPage extends StatelessWidget {
  final OrderEntity order;

  const OrderDetailsPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final isRtl = context.locale.languageCode == 'ar';
    final screenWidth = MediaQuery.of(context).size.width;

    return Directionality(
      textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColours.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon:
                const Icon(Icons.arrow_back_ios, color: AppColours.brownMedium),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'order_details'.tr(),
            style: AppTextStyle.semiBold_20_dark_brown,
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Status Card
              _buildStatusCard(context, isRtl),
              const SizedBox(height: 16),
              // Order Info Card
              _buildOrderInfoCard(context, isRtl),
              const SizedBox(height: 16),
              // Customer Info Card
              _buildCustomerInfoCard(context, isRtl),
              const SizedBox(height: 16),
              // Merchant Info Card
              if (order.hasMerchantInfo) ...[
                _buildMerchantInfoCard(context, isRtl),
                const SizedBox(height: 16),
              ],
              // Products Card
              _buildProductsCard(context, isRtl, screenWidth),
              const SizedBox(height: 16),
              // Price Summary Card
              _buildPriceSummaryCard(context, isRtl),
              if (order.notes != null && order.notes!.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildNotesCard(context, isRtl),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, bool isRtl) {
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

  Widget _buildOrderInfoCard(BuildContext context, bool isRtl) {
    return _buildCard(
      title: isRtl ? 'معلومات الطلب' : 'Order Information',
      icon: Icons.receipt_long_outlined,
      children: [
        _buildInfoRow(
          isRtl ? 'رقم الطلب' : 'Order ID',
          '#${order.id.substring(0, 8)}',
          trailing: IconButton(
            icon: const Icon(Icons.copy, size: 18),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: order.id));
              Tost.showCustomToast(
                context,
                isRtl ? 'تم نسخ رقم الطلب' : 'Order ID copied',
                backgroundColor: Colors.green,
              );
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ),
        _buildDivider(),
        _buildInfoRow(
          isRtl ? 'تاريخ الطلب' : 'Order Date',
          _formatDateTime(order.createdAt, isRtl),
        ),
        _buildDivider(),
        _buildInfoRow(
          isRtl ? 'عدد المنتجات' : 'Items Count',
          '${order.items.length} ${isRtl ? 'منتج' : 'items'}',
        ),
      ],
    );
  }

  Widget _buildCustomerInfoCard(BuildContext context, bool isRtl) {
    return _buildCard(
      title: isRtl ? 'معلومات التوصيل' : 'Delivery Information',
      icon: Icons.local_shipping_outlined,
      children: [
        if (order.customerName != null && order.customerName!.isNotEmpty) ...[
          _buildInfoRow(
            isRtl ? 'اسم المستلم' : 'Recipient Name',
            order.customerName!,
            icon: Icons.person_outline,
          ),
          _buildDivider(),
        ],
        if (order.customerPhone != null && order.customerPhone!.isNotEmpty) ...[
          _buildInfoRow(
            isRtl ? 'رقم الهاتف' : 'Phone Number',
            order.customerPhone!,
            icon: Icons.phone_outlined,
            trailing: IconButton(
              icon: const Icon(Icons.copy, size: 18),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: order.customerPhone!));
                Tost.showCustomToast(
                  context,
                  isRtl ? 'تم نسخ رقم الهاتف' : 'Phone copied',
                  backgroundColor: Colors.green,
                );
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
          _buildDivider(),
        ],
        if (order.deliveryAddress != null &&
            order.deliveryAddress!.isNotEmpty) ...[
          _buildInfoRow(
            isRtl ? 'عنوان التوصيل' : 'Delivery Address',
            order.deliveryAddress!,
            icon: Icons.location_on_outlined,
            isMultiLine: true,
          ),
        ],
      ],
    );
  }

  Widget _buildMerchantInfoCard(BuildContext context, bool isRtl) {
    return _buildCard(
      title: isRtl ? 'معلومات التاجر' : 'Merchant Information',
      icon: Icons.store_outlined,
      children: [
        if (order.merchantName != null && order.merchantName!.isNotEmpty) ...[
          _buildInfoRow(
            isRtl ? 'اسم المتجر' : 'Store Name',
            order.merchantName!,
            icon: Icons.storefront_outlined,
          ),
        ],
        if (order.merchantPhone != null && order.merchantPhone!.isNotEmpty) ...[
          _buildDivider(),
          _buildInfoRow(
            isRtl ? 'رقم التاجر' : 'Merchant Phone',
            order.merchantPhone!,
            icon: Icons.phone_outlined,
            trailing: IconButton(
              icon: const Icon(Icons.copy, size: 18),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: order.merchantPhone!));
                Tost.showCustomToast(
                  context,
                  isRtl ? 'تم نسخ رقم التاجر' : 'Phone copied',
                  backgroundColor: Colors.green,
                );
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
        ],
        if (order.merchantAddress != null &&
            order.merchantAddress!.isNotEmpty) ...[
          _buildDivider(),
          _buildInfoRow(
            isRtl ? 'عنوان المتجر' : 'Store Address',
            order.merchantAddress!,
            icon: Icons.location_on_outlined,
            isMultiLine: true,
          ),
        ],
      ],
    );
  }

  Widget _buildProductsCard(
      BuildContext context, bool isRtl, double screenWidth) {
    return _buildCard(
      title: isRtl ? 'المنتجات' : 'Products',
      icon: Icons.shopping_bag_outlined,
      children: [
        ...order.items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Column(
            children: [
              _buildProductItem(item, isRtl, screenWidth),
              if (index < order.items.length - 1) _buildDivider(),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildProductItem(
      OrderItemEntity item, bool isRtl, double screenWidth) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: item.productImage != null && item.productImage!.isNotEmpty
                ? Image.network(
                    item.productImage!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                  )
                : _buildImagePlaceholder(),
          ),
          const SizedBox(width: 12),
          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: AppTextStyle.semiBold_16_dark_brown,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.price.toStringAsFixed(2)} ${isRtl ? 'ج.م' : 'EGP'} × ${item.quantity}',
                  style: AppTextStyle.normal_14_greyDark,
                ),
              ],
            ),
          ),
          // Item Total
          Text(
            '${item.itemTotal.toStringAsFixed(2)} ${isRtl ? 'ج.م' : 'EGP'}',
            style: AppTextStyle.semiBold_16_dark_brown.copyWith(
              color: AppColours.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: 60,
      height: 60,
      color: AppColours.greyLighter,
      child: const Icon(Icons.image_outlined, color: AppColours.greyMedium),
    );
  }

  Widget _buildPriceSummaryCard(BuildContext context, bool isRtl) {
    return _buildCard(
      title: isRtl ? 'ملخص السعر' : 'Price Summary',
      icon: Icons.receipt_outlined,
      children: [
        _buildPriceRow(
          isRtl ? 'المجموع الفرعي' : 'Subtotal',
          order.subtotal,
          isRtl,
        ),
        if (order.discount > 0) ...[
          _buildDivider(),
          _buildPriceRow(
            isRtl ? 'الخصم' : 'Discount',
            -order.discount,
            isRtl,
            isDiscount: true,
          ),
        ],
        if (order.shippingCost > 0) ...[
          _buildDivider(),
          _buildPriceRow(
            isRtl ? 'الشحن' : 'Shipping',
            order.shippingCost,
            isRtl,
          ),
        ],
        const Divider(thickness: 2, height: 24),
        _buildPriceRow(
          isRtl ? 'الإجمالي' : 'Total',
          order.total,
          isRtl,
          isTotal: true,
        ),
      ],
    );
  }

  Widget _buildNotesCard(BuildContext context, bool isRtl) {
    return _buildCard(
      title: isRtl ? 'ملاحظات' : 'Notes',
      icon: Icons.note_outlined,
      children: [
        Text(
          order.notes!,
          style: AppTextStyle.normal_14_greyDark,
        ),
      ],
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColours.primary, size: 22),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyle.semiBold_16_dark_brown.copyWith(
                  color: AppColours.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    IconData? icon,
    Widget? trailing,
    bool isMultiLine = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment:
            isMultiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: AppColours.greyMedium),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyle.normal_14_greyDark,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyle.semiBold_16_dark_brown,
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    double amount,
    bool isRtl, {
    bool isTotal = false,
    bool isDiscount = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? AppTextStyle.semiBold_16_dark_brown
                : AppTextStyle.normal_14_greyDark,
          ),
          Text(
            '${isDiscount ? '-' : ''}${amount.abs().toStringAsFixed(2)} ${isRtl ? 'ج.م' : 'EGP'}',
            style: isTotal
                ? AppTextStyle.semiBold_20_dark_brown.copyWith(
                    color: AppColours.primary,
                  )
                : isDiscount
                    ? AppTextStyle.semiBold_16_dark_brown.copyWith(
                        color: Colors.green,
                      )
                    : AppTextStyle.semiBold_16_dark_brown,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, color: AppColours.greyLighter);
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

  String _formatDateTime(DateTime? date, bool isRtl) {
    if (date == null) return '-';
    final dateStr = '${date.day}/${date.month}/${date.year}';
    final timeStr =
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    return '$dateStr - $timeStr';
  }
}
