import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared_widgets/skeleton_widgets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../domain/entities/parent_order_entity.dart';
import '../cubit/orders_cubit.dart';
import '../cubit/orders_state.dart';
import '../widgets/merchant_order_card.dart';

class ParentOrderDetailsPage extends StatefulWidget {
  final String parentOrderId;

  const ParentOrderDetailsPage({super.key, required this.parentOrderId});

  @override
  State<ParentOrderDetailsPage> createState() => _ParentOrderDetailsPageState();
}

class _ParentOrderDetailsPageState extends State<ParentOrderDetailsPage> {
  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  void _loadDetails() {
    context.read<OrdersCubit>().loadParentOrderDetails(widget.parentOrderId);
  }

  void _goBackToOrders() {
    // Reload parent orders before going back
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      context.read<OrdersCubit>().watchUserParentOrders(authState.user.id);
    }
    context.go('/orders');
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = context.locale.languageCode == 'ar';

    return Directionality(
      textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColours.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            icon:
                const Icon(Icons.arrow_back_ios, color: AppColours.brownMedium),
            onPressed: _goBackToOrders,
          ),
          title: Text(
            'order_details'.tr(),
            style: AppTextStyle.semiBold_20_dark_brown,
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<OrdersCubit, OrdersState>(
          builder: (context, state) {
            if (state is OrdersLoading) {
              return const OrderDetailsSkeleton();
            }

            if (state is OrdersError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.message,
                        style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadDetails,
                      child: Text('retry'.tr()),
                    ),
                  ],
                ),
              );
            }

            if (state is ParentOrderLoaded) {
              return _buildContent(context, state.parentOrder, isRtl);
            }

            // If not the right state, reload
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _loadDetails();
            });
            return const OrderDetailsSkeleton();
          },
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ParentOrderEntity parentOrder,
    bool isRtl,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOrderSummaryCard(parentOrder, isRtl),
          const SizedBox(height: 16),
          _buildCustomerInfoCard(parentOrder, isRtl),
          const SizedBox(height: 16),
          _buildPaymentMethodCard(parentOrder, isRtl),
          const SizedBox(height: 16),
          Text(
            'merchant_orders'.tr(),
            style: AppTextStyle.semiBold_16_dark_brown,
          ),
          const SizedBox(height: 12),
          ...parentOrder.subOrders.map((order) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: MerchantOrderCard(order: order, isRtl: isRtl),
              )),
          const SizedBox(height: 16),
          _buildTotalSummaryCard(parentOrder, isRtl),
          if (parentOrder.notes != null && parentOrder.notes!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildNotesCard(parentOrder.notes!, isRtl),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildOrderSummaryCard(ParentOrderEntity parentOrder, bool isRtl) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${'order_number'.tr()}: #${parentOrder.id.substring(0, 8)}',
                style: AppTextStyle.semiBold_12_dark_brown,
              ),
              _buildOverallStatusBadge(parentOrder.overallStatus),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${'merchants_count'.tr()}: ${parentOrder.merchantCount}',
            style: AppTextStyle.normal_14_greyDark,
          ),
          if (parentOrder.createdAt != null) ...[
            const SizedBox(height: 4),
            Text(
              DateFormat('dd/MM/yyyy - hh:mm a', context.locale.languageCode)
                  .format(parentOrder.createdAt!),
              style: AppTextStyle.normal_12_greyDark,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOverallStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String displayText;

    switch (status) {
      case 'delivered':
        bgColor = Colors.green.shade100;
        textColor = Colors.green.shade700;
        displayText = 'delivered'.tr();
        break;
      case 'shipped':
        bgColor = Colors.blue.shade100;
        textColor = Colors.blue.shade700;
        displayText = 'shipped'.tr();
        break;
      case 'processing':
        bgColor = Colors.orange.shade100;
        textColor = Colors.orange.shade700;
        displayText = 'processing'.tr();
        break;
      case 'partially_cancelled':
        bgColor = Colors.red.shade100;
        textColor = Colors.red.shade700;
        displayText = 'partially_cancelled'.tr();
        break;
      default:
        bgColor = Colors.grey.shade100;
        textColor = Colors.grey.shade700;
        displayText = 'pending'.tr();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildCustomerInfoCard(ParentOrderEntity parentOrder, bool isRtl) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'delivery_info'.tr(),
            style: AppTextStyle.semiBold_12_dark_brown,
          ),
          const SizedBox(height: 12),
          if (parentOrder.customerName != null)
            _buildInfoRow(Icons.person_outline, parentOrder.customerName!),
          if (parentOrder.customerPhone != null)
            _buildInfoRow(Icons.phone_outlined, parentOrder.customerPhone!),
          if (parentOrder.deliveryAddress != null)
            _buildInfoRow(
                Icons.location_on_outlined, parentOrder.deliveryAddress!),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColours.brownMedium),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: AppTextStyle.normal_14_greyDark)),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard(ParentOrderEntity parentOrder, bool isRtl) {
    final paymentMethod = parentOrder.paymentMethod ?? 'cash_on_delivery';

    IconData paymentIcon;
    String paymentLabel;
    Color iconColor;

    switch (paymentMethod) {
      case 'credit_card':
        paymentIcon = Icons.credit_card;
        paymentLabel = 'credit_card'.tr();
        iconColor = Colors.blue.shade600;
        break;
      case 'wallet':
        paymentIcon = Icons.account_balance_wallet;
        paymentLabel = 'wallet'.tr();
        iconColor = Colors.purple.shade600;
        break;
      default:
        paymentIcon = Icons.payments_outlined;
        paymentLabel = 'cash_on_delivery'.tr();
        iconColor = Colors.green.shade600;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'payment_method'.tr(),
            style: AppTextStyle.semiBold_12_dark_brown,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(paymentIcon, size: 24, color: iconColor),
              ),
              const SizedBox(width: 12),
              Text(paymentLabel, style: AppTextStyle.semiBold_16_dark_brown),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalSummaryCard(ParentOrderEntity parentOrder, bool isRtl) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildPriceRow('subtotal'.tr(), parentOrder.subtotal),
          const SizedBox(height: 8),
          _buildPriceRow('shipping'.tr(), parentOrder.shippingCost),
          if (parentOrder.hasCoupon) ...[
            const SizedBox(height: 8),
            _buildCouponRow(parentOrder),
          ],
          const Divider(height: 24),
          _buildPriceRow('total'.tr(), parentOrder.total, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildCouponRow(ParentOrderEntity parentOrder) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.local_offer, size: 16, color: Colors.green.shade600),
            const SizedBox(width: 6),
            Text(
              '${'coupon_discount'.tr()} (${parentOrder.couponCode})',
              style: TextStyle(
                fontSize: 14,
                color: Colors.green.shade600,
              ),
            ),
          ],
        ),
        Text(
          '-${parentOrder.couponDiscount.toStringAsFixed(2)} ${'egp'.tr()}',
          style: TextStyle(
            fontSize: 14,
            color: Colors.green.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? AppTextStyle.semiBold_16_dark_brown
              : AppTextStyle.normal_14_greyDark,
        ),
        Text(
          '${amount.toStringAsFixed(2)} ${'egp'.tr()}',
          style: isTotal
              ? AppTextStyle.semiBold_16_dark_brown.copyWith(
                  color: AppColours.brownMedium,
                )
              : AppTextStyle.normal_14_greyDark,
        ),
      ],
    );
  }

  Widget _buildNotesCard(String notes, bool isRtl) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.note_outlined, size: 18, color: Colors.amber.shade700),
              const SizedBox(width: 8),
              Text(
                'notes'.tr(),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.amber.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(notes, style: AppTextStyle.normal_14_greyDark),
        ],
      ),
    );
  }
}
