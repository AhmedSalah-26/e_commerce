import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_style.dart';
import '../../domain/entities/order_entity.dart';
import '../widgets/order_status_card.dart';
import '../widgets/order_info_cards.dart';
import '../widgets/order_products_card.dart';
import '../widgets/order_price_summary.dart';

class OrderDetailsPage extends StatelessWidget {
  final OrderEntity order;

  const OrderDetailsPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRtl = context.locale.languageCode == 'ar';
    final screenWidth = MediaQuery.of(context).size.width;

    return Directionality(
      textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: theme.colorScheme.primary),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'order_details'.tr(),
            style: AppTextStyle.semiBold_20_dark_brown.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OrderStatusCard(order: order, isRtl: isRtl),
              const SizedBox(height: 16),
              OrderInfoCard(order: order, isRtl: isRtl),
              const SizedBox(height: 16),
              CustomerInfoCard(order: order, isRtl: isRtl),
              const SizedBox(height: 16),
              if (order.hasMerchantInfo) ...[
                MerchantInfoCard(order: order, isRtl: isRtl),
                const SizedBox(height: 16),
              ],
              OrderProductsCard(
                order: order,
                isRtl: isRtl,
                screenWidth: screenWidth,
              ),
              const SizedBox(height: 16),
              OrderPriceSummary(order: order, isRtl: isRtl),
              if (order.notes != null && order.notes!.isNotEmpty) ...[
                const SizedBox(height: 16),
                OrderNotesCard(notes: order.notes!, isRtl: isRtl),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
