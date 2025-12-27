import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../shipping/domain/entities/governorate_entity.dart';

class GovernorateShippingCard extends StatelessWidget {
  final GovernorateEntity governorate;
  final double? price;
  final String locale;
  final VoidCallback onEdit;

  const GovernorateShippingCard({
    super.key,
    required this.governorate,
    required this.price,
    required this.locale,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasPrice = price != null;

    return Container(
      decoration: BoxDecoration(
        color: hasPrice ? Colors.green.shade50 : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasPrice
              ? Colors.green.shade200
              : theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: hasPrice
                ? Colors.green.withValues(alpha: 0.2)
                : theme.colorScheme.outline.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.location_city,
            color: hasPrice ? Colors.green : theme.colorScheme.outline,
          ),
        ),
        title: Text(
          governorate.getName(locale),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          hasPrice
              ? '${price!.toStringAsFixed(0)} ${'egp'.tr()}'
              : 'no_shipping_prices'.tr(),
          style: TextStyle(
            color: hasPrice ? Colors.green.shade700 : theme.colorScheme.outline,
          ),
        ),
        trailing: IconButton(
          icon: Icon(
            hasPrice ? Icons.edit : Icons.add,
            color: theme.colorScheme.primary,
          ),
          onPressed: onEdit,
        ),
        onTap: onEdit,
      ),
    );
  }
}
