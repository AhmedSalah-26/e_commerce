import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
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
    final hasPrice = price != null;

    return Container(
      decoration: BoxDecoration(
        color: hasPrice ? Colors.green.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasPrice ? Colors.green.shade200 : Colors.grey.shade300,
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: hasPrice
                ? Colors.green.withValues(alpha: 0.2)
                : Colors.grey.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.location_city,
            color: hasPrice ? Colors.green : Colors.grey,
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
            color: hasPrice ? Colors.green.shade700 : Colors.grey,
          ),
        ),
        trailing: IconButton(
          icon: Icon(
            hasPrice ? Icons.edit : Icons.add,
            color: AppColours.brownMedium,
          ),
          onPressed: onEdit,
        ),
        onTap: onEdit,
      ),
    );
  }
}
