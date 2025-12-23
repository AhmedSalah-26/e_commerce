import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/utils/locale_helper.dart';
import '../../domain/entities/parent_order_entity.dart';

/// Card widget to display a parent order (grouped multi-vendor order) in the orders list
class ParentOrderItemCard extends StatelessWidget {
  final ParentOrderEntity parentOrder;
  final VoidCallback? onTap;

  const ParentOrderItemCard({
    super.key,
    required this.parentOrder,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double fontSize = screenWidth * 0.04;
    final isRtl = LocaleHelper.isArabic(context);

    return Directionality(
      textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: GestureDetector(
        onTap: onTap ?? () => context.push('/parent-order/${parentOrder.id}'),
        child: Container(
          margin: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.2),
                spreadRadius: 1,
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColours.greyLighter),
            color: Colors.white,
          ),
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.03),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Icon
                    Container(
                      width: screenHeight * 0.08,
                      height: screenHeight * 0.08,
                      decoration: BoxDecoration(
                        color: AppColours.brownLight.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.shopping_bag_outlined,
                        color: AppColours.brownMedium,
                        size: 32,
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.03),
                    // Order details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${'order_number'.tr()}: #${parentOrder.id.substring(0, 8)}',
                            style: AppTextStyle.bold_18_medium_brown
                                .copyWith(fontSize: fontSize),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDate(parentOrder.createdAt),
                            style: AppTextStyle.normal_16_brownLight
                                .copyWith(fontSize: fontSize * 0.8),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.store_outlined,
                                  size: fontSize * 0.9, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                '${parentOrder.merchantCount} ${'merchants'.tr()}',
                                style: AppTextStyle.normal_16_brownLight
                                    .copyWith(fontSize: fontSize * 0.75),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.03),
                    // Status indicator
                    _buildStatusIndicator(parentOrder.overallStatus, fontSize),
                  ],
                ),
                const SizedBox(height: 8),

                // Status summary and total
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: AppColours.greyLighter),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatusSummary(fontSize),
                      Text(
                        '${parentOrder.total.toStringAsFixed(2)} ${'egp'.tr()}',
                        style: AppTextStyle.semiBold_16_dark_brown
                            .copyWith(fontSize: fontSize),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusSummary(double fontSize) {
    final counts = parentOrder.statusCounts;
    if (counts.isEmpty) {
      return Text(
        'pending'.tr(),
        style: AppTextStyle.normal_16_brownLight
            .copyWith(fontSize: fontSize * 0.85),
      );
    }

    return Wrap(
      spacing: 8,
      children: counts.entries.map((entry) {
        return _buildMiniStatusBadge(entry.key, entry.value, fontSize);
      }).toList(),
    );
  }

  Widget _buildMiniStatusBadge(dynamic status, int count, double fontSize) {
    Color color;
    String statusName;

    // Handle both OrderStatus enum and string
    final statusStr = status.toString().split('.').last;

    switch (statusStr) {
      case 'delivered':
        color = Colors.green;
        statusName = 'delivered'.tr();
        break;
      case 'shipped':
        color = Colors.blue;
        statusName = 'shipped'.tr();
        break;
      case 'processing':
        color = Colors.orange;
        statusName = 'processing'.tr();
        break;
      case 'cancelled':
        color = Colors.red;
        statusName = 'status_cancelled'.tr();
        break;
      default:
        color = Colors.grey;
        statusName = 'pending'.tr();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$count $statusName',
        style: TextStyle(
          color: color,
          fontSize: fontSize * 0.7,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(String status, double fontSize) {
    Color color;
    IconData icon;

    switch (status) {
      case 'delivered':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'shipped':
        color = Colors.blue;
        icon = Icons.local_shipping;
        break;
      case 'processing':
        color = Colors.orange;
        icon = Icons.sync;
        break;
      case 'partially_cancelled':
        color = Colors.red;
        icon = Icons.warning;
        break;
      case 'cancelled':
        color = Colors.red;
        icon = Icons.cancel;
        break;
      default:
        color = Colors.grey;
        icon = Icons.hourglass_empty;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: color.withValues(alpha: 0.1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: fontSize * 1.5),
          const SizedBox(height: 4),
          Text(
            _getStatusText(status),
            style: TextStyle(
              color: color,
              fontSize: fontSize * 0.7,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'delivered':
        return 'delivered'.tr();
      case 'shipped':
        return 'shipped'.tr();
      case 'processing':
        return 'processing'.tr();
      case 'partially_cancelled':
        return 'partially_cancelled'.tr();
      case 'cancelled':
        return 'status_cancelled'.tr();
      default:
        return 'pending'.tr();
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.day}/${date.month}/${date.year}';
  }
}
