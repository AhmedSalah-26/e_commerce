import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../domain/entities/coupon_entity.dart';
import 'coupon_info_chip.dart';
import 'coupon_scope_badge.dart';

class CouponCard extends StatelessWidget {
  final CouponEntity coupon;
  final VoidCallback onEdit;
  final ValueChanged<bool> onToggle;

  const CouponCard({
    super.key,
    required this.coupon,
    required this.onEdit,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final locale = context.locale.languageCode;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 12),
            _buildTitle(locale),
            if (coupon.getDescription(locale) != null) ...[
              const SizedBox(height: 4),
              Text(
                coupon.getDescription(locale)!,
                style: const TextStyle(color: AppColours.greyMedium),
              ),
            ],
            const SizedBox(height: 12),
            _buildInfoChips(),
            if (coupon.endDate != null) ...[
              const SizedBox(height: 8),
              _buildExpiryInfo(),
            ],
            const Divider(height: 24),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColours.brownLight.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            coupon.code,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColours.brownDark,
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(width: 8),
        if (coupon.isProductSpecific)
          CouponScopeBadge(
            icon: Icons.inventory_2,
            count: coupon.productIds.length,
            color: Colors.blue,
          ),
        if (coupon.isCategorySpecific)
          CouponScopeBadge(
            icon: Icons.category,
            count: coupon.categoryIds.length,
            color: Colors.purple,
          ),
        const Spacer(),
        Switch(
          value: coupon.isActive,
          onChanged: onToggle,
          activeThumbColor: AppColours.brownMedium,
        ),
      ],
    );
  }

  Widget _buildTitle(String locale) {
    return Text(
      coupon.getName(locale),
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColours.brownDark,
      ),
    );
  }

  Widget _buildInfoChips() {
    return Row(
      children: [
        CouponInfoChip(
          icon: Icons.percent,
          label: coupon.isPercentage
              ? '${coupon.discountValue.toInt()}%'
              : '${coupon.discountValue.toStringAsFixed(0)} ${'egp'.tr()}',
        ),
        const SizedBox(width: 8),
        if (coupon.minOrderAmount > 0)
          CouponInfoChip(
            icon: Icons.shopping_cart_outlined,
            label: '${'min'.tr()} ${coupon.minOrderAmount.toStringAsFixed(0)}',
          ),
        const SizedBox(width: 8),
        CouponInfoChip(
          icon: Icons.people_outline,
          label: '${coupon.usageCount}/${coupon.usageLimit ?? '∞'}',
        ),
      ],
    );
  }

  Widget _buildExpiryInfo() {
    return Row(
      children: [
        Icon(
          coupon.isExpired ? Icons.error_outline : Icons.schedule,
          size: 16,
          color: coupon.isExpired ? Colors.red : AppColours.greyMedium,
        ),
        const SizedBox(width: 4),
        Text(
          coupon.isExpired
              ? 'expired'.tr()
              : '${'ends'.tr()}: ${DateFormat('yyyy/MM/dd').format(coupon.endDate!)}',
          style: TextStyle(
            fontSize: 12,
            color: coupon.isExpired ? Colors.red : AppColours.greyMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton.icon(
          onPressed: onEdit,
          icon: const Icon(Icons.edit_outlined, size: 18),
          label: Text('edit'.tr()),
          style: TextButton.styleFrom(foregroundColor: AppColours.brownMedium),
        ),
      ],
    );
  }
}
