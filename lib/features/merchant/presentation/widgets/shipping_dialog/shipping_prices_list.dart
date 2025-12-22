import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../shipping/domain/entities/governorate_entity.dart';
import '../../../../shipping/domain/entities/shipping_price_entity.dart';
import 'governorate_shipping_card.dart';

class ShippingPricesList extends StatelessWidget {
  final List<GovernorateEntity> governorates;
  final List<ShippingPriceEntity> prices;
  final String locale;
  final Function(GovernorateEntity, double?) onEditPrice;
  final VoidCallback onAddZone;

  const ShippingPricesList({
    super.key,
    required this.governorates,
    required this.prices,
    required this.locale,
    required this.onEditPrice,
    required this.onAddZone,
  });

  @override
  Widget build(BuildContext context) {
    final priceMap = <String, double>{};
    for (final price in prices) {
      priceMap[price.governorateId] = price.price;
    }

    final withPrices =
        governorates.where((g) => priceMap.containsKey(g.id)).toList();
    final withoutPrices =
        governorates.where((g) => !priceMap.containsKey(g.id)).toList();

    return Column(
      children: [
        if (withoutPrices.isNotEmpty) _buildAddZoneButton(context),
        const SizedBox(height: 8),
        if (withPrices.isNotEmpty)
          _buildSectionHeader(
            'active_shipping_zones'.tr(),
            withPrices.length,
            Colors.green,
          ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: withPrices.length +
                (withoutPrices.isNotEmpty ? 1 + withoutPrices.length : 0),
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              if (index < withPrices.length) {
                final gov = withPrices[index];
                final price = priceMap[gov.id];
                return GovernorateShippingCard(
                  governorate: gov,
                  price: price,
                  locale: locale,
                  onEdit: () => onEditPrice(gov, price),
                );
              }

              if (index == withPrices.length && withoutPrices.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 8),
                  child: _buildSectionHeader(
                    'inactive_shipping_zones'.tr(),
                    withoutPrices.length,
                    Colors.grey,
                  ),
                );
              }

              final inactiveIndex = index - withPrices.length - 1;
              if (inactiveIndex >= 0 && inactiveIndex < withoutPrices.length) {
                final gov = withoutPrices[inactiveIndex];
                return GovernorateShippingCard(
                  governorate: gov,
                  price: null,
                  locale: locale,
                  onEdit: () => onEditPrice(gov, null),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAddZoneButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: InkWell(
        onTap: onAddZone,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColours.brownLight.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColours.brownLight,
              style: BorderStyle.solid,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.add_circle_outline,
                color: AppColours.brownMedium,
              ),
              const SizedBox(width: 8),
              Text(
                'add_shipping_zone'.tr(),
                style: const TextStyle(
                  color: AppColours.brownMedium,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count, MaterialColor color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          Icon(
            title.contains('active')
                ? Icons.local_shipping
                : Icons.location_off,
            size: 18,
            color: color,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color.shade700,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
