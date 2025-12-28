import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../domain/entities/coupon_entity.dart';
import 'coupon_info_chip.dart';
import 'coupon_scope_badge.dart';

class CouponCard extends StatelessWidget {
  final CouponEntity coupon;
  final bool isGlobal;
  final VoidCallback onEdit;
  final ValueChanged<bool> onToggle;

  const CouponCard({
    super.key,
    required this.coupon,
    this.isGlobal = false,
    required this.onEdit,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = context.locale.languageCode;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(locale, theme),
            const SizedBox(height: 12),
            _buildTitle(locale, theme),
            if (coupon.getDescription(locale) != null) ...[
              const SizedBox(height: 4),
              Text(
                coupon.getDescription(locale)!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
            const SizedBox(height: 12),
            _buildInfoChips(),
            if (coupon.endDate != null) ...[
              const SizedBox(height: 8),
              _buildExpiryInfo(theme),
            ],
            const Divider(height: 24),
            _buildActions(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String locale, ThemeData theme) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            coupon.code,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(width: 8),
        if (isGlobal)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.public, size: 14, color: Colors.green.shade700),
                const SizedBox(width: 4),
                Text(
                  locale == 'ar' ? 'عام' : 'Global',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ),
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
          activeTrackColor: theme.colorScheme.primary,
        ),
      ],
    );
  }

  Widget _buildTitle(String locale, ThemeData theme) {
    return Text(
      coupon.getName(locale),
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
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

  Widget _buildExpiryInfo(ThemeData theme) {
    return Row(
      children: [
        Icon(
          coupon.isExpired ? Icons.error_outline : Icons.schedule,
          size: 16,
          color: coupon.isExpired
              ? Colors.red
              : theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        const SizedBox(width: 4),
        Text(
          coupon.isExpired
              ? 'expired'.tr()
              : '${'ends'.tr()}: ${DateFormat('yyyy/MM/dd').format(coupon.endDate!)}',
          style: TextStyle(
            fontSize: 12,
            color: coupon.isExpired
                ? Colors.red
                : theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildActions(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton.icon(
          onPressed: onEdit,
          icon: const Icon(Icons.edit_outlined, size: 18),
          label: Text('edit'.tr()),
          style:
              TextButton.styleFrom(foregroundColor: theme.colorScheme.primary),
        ),
      ],
    );
  }
}
