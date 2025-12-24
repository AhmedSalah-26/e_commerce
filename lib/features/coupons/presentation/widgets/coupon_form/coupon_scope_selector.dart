import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

class CouponScopeSelector extends StatelessWidget {
  final String selectedScope;
  final ValueChanged<String> onChanged;

  const CouponScopeSelector({
    super.key,
    required this.selectedScope,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('coupon_scope'.tr(),
            style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _ScopeOption(
              label: 'all_store_products'.tr(),
              icon: Icons.store,
              isSelected: selectedScope == 'all',
              onTap: () => onChanged('all'),
            ),
            _ScopeOption(
              label: 'specific_products'.tr(),
              icon: Icons.inventory_2,
              isSelected: selectedScope == 'products',
              onTap: () => onChanged('products'),
            ),
            _ScopeOption(
              label: 'specific_categories'.tr(),
              icon: Icons.category,
              isSelected: selectedScope == 'categories',
              onTap: () => onChanged('categories'),
            ),
          ],
        ),
      ],
    );
  }
}

class _ScopeOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ScopeOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColours.brownLight.withValues(alpha: 0.2)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColours.brownMedium : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 16,
                color: isSelected ? AppColours.brownMedium : Colors.grey),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color:
                    isSelected ? AppColours.brownMedium : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
