import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/utils/locale_helper.dart';
import '../../domain/entities/parent_order_entity.dart';

/// Status config
const _statusMap = <String, (Color, IconData, String)>{
  'delivered': (Colors.green, Icons.check_circle, 'delivered'),
  'shipped': (Colors.blue, Icons.local_shipping, 'shipped'),
  'processing': (Colors.orange, Icons.sync, 'processing'),
  'partially_cancelled': (Colors.red, Icons.warning, 'partially_cancelled'),
  'cancelled': (Colors.red, Icons.cancel, 'status_cancelled'),
};

(Color, IconData, String) _getStatus(String s) =>
    _statusMap[s] ?? (Colors.grey, Icons.hourglass_empty, 'pending');

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
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final fs = w * 0.04;
    final isRtl = LocaleHelper.isArabic(context);
    final locale = context.locale.languageCode;

    return Directionality(
      textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: GestureDetector(
        onTap: onTap ?? () => context.push('/parent-order/${parentOrder.id}'),
        child: Container(
          margin: EdgeInsets.symmetric(vertical: h * 0.01),
          padding: EdgeInsets.all(w * 0.03),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColours.greyLighter),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.2),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildHeader(w, h, fs, locale),
              const SizedBox(height: 8),
              _buildFooter(fs),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(double w, double h, double fs, String locale) {
    return Row(
      children: [
        _buildImage(h * 0.08),
        SizedBox(width: w * 0.03),
        Expanded(child: _buildDetails(fs, locale)),
        SizedBox(width: w * 0.03),
        _buildStatusBadge(fs),
      ],
    );
  }

  Widget _buildImage(double size) {
    final url = parentOrder.firstProductImage;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: url != null
          ? Image.network(
              url,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _placeholder(size),
            )
          : _placeholder(size),
    );
  }

  Widget _placeholder(double size) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColours.brownLight.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.shopping_bag_outlined,
            color: AppColours.brownMedium, size: 32),
      );

  Widget _buildDetails(double fs, String locale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${'order_number'.tr()}: #${parentOrder.id.substring(0, 8)}',
          style: AppTextStyle.bold_18_medium_brown.copyWith(fontSize: fs),
        ),
        const SizedBox(height: 4),
        Text(
          _formatDate(parentOrder.createdAt, locale),
          style: AppTextStyle.normal_16_brownLight.copyWith(fontSize: fs * 0.8),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.store_outlined, size: fs * 0.9, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              '${parentOrder.merchantCount} ${'merchants'.tr()}',
              style: AppTextStyle.normal_16_brownLight
                  .copyWith(fontSize: fs * 0.75),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBadge(double fs) {
    final (color, icon, key) = _getStatus(parentOrder.overallStatus);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: color.withValues(alpha: 0.1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: fs * 1.5),
          const SizedBox(height: 4),
          Text(
            key.tr(),
            style: TextStyle(
                color: color, fontSize: fs * 0.7, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(double fs) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColours.greyLighter)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatusSummary(fs),
          Text(
            '${parentOrder.total.toStringAsFixed(2)} ${'egp'.tr()}',
            style: AppTextStyle.semiBold_16_dark_brown.copyWith(fontSize: fs),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSummary(double fs) {
    final counts = parentOrder.statusCounts;
    if (counts.isEmpty) {
      return Text('pending'.tr(),
          style:
              AppTextStyle.normal_16_brownLight.copyWith(fontSize: fs * 0.85));
    }
    return Wrap(
      spacing: 8,
      children: counts.entries.map((e) {
        final (color, _, key) = _getStatus(e.key.toString().split('.').last);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '${e.value} ${key.tr()}',
            style: TextStyle(
                color: color, fontSize: fs * 0.7, fontWeight: FontWeight.w500),
          ),
        );
      }).toList(),
    );
  }

  String _formatDate(DateTime? d, [String locale = 'ar']) {
    if (d == null) return '-';
    return DateFormat('dd/MM/yyyy', locale).format(d);
  }
}
