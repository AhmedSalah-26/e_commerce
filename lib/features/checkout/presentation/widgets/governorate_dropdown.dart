import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../cart/presentation/cubit/cart_state.dart';
import '../../../shipping/domain/entities/governorate_entity.dart';
import '../../../shipping/presentation/cubit/shipping_cubit.dart';

class GovernorateDropdown extends StatelessWidget {
  final List<GovernorateEntity> governorates;
  final GovernorateEntity? selected;
  final String locale;
  final CartLoaded cartState;
  final Map<String, Map<String, double>> merchantsShippingData;
  final Map<String, String> merchantsInfo; // merchantId -> storeName

  const GovernorateDropdown({
    super.key,
    required this.governorates,
    required this.selected,
    required this.locale,
    required this.cartState,
    this.merchantsShippingData = const {},
    this.merchantsInfo = const {},
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final merchantIds = merchantsInfo.keys.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'governorate'.tr(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border.all(color: theme.colorScheme.primary, width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<GovernorateEntity>(
              value: selected,
              hint: Text(
                'select_governorate'.tr(),
                style: TextStyle(color: theme.colorScheme.primary),
              ),
              isExpanded: true,
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: theme.colorScheme.primary,
              ),
              dropdownColor: theme.colorScheme.surface,
              items: governorates.map((gov) {
                final shippingData = merchantsShippingData[gov.id] ?? {};

                return DropdownMenuItem<GovernorateEntity>(
                  value: gov,
                  child: _GovernorateItem(
                    governorate: gov,
                    locale: locale,
                    merchantIds: merchantIds,
                    merchantsInfo: merchantsInfo,
                    shippingData: shippingData,
                  ),
                );
              }).toList(),
              onChanged: (gov) {
                if (gov != null) {
                  context
                      .read<ShippingCubit>()
                      .selectGovernorateForMultipleMerchants(gov, merchantIds);
                }
              },
            ),
          ),
        ),
        // Show availability info for selected governorate
        if (selected != null && merchantIds.length > 1) ...[
          const SizedBox(height: 12),
          _MerchantsAvailabilityInfo(
            merchantIds: merchantIds,
            merchantsInfo: merchantsInfo,
            shippingData: merchantsShippingData[selected!.id] ?? {},
            locale: locale,
          ),
        ],
      ],
    );
  }
}

class _GovernorateItem extends StatelessWidget {
  final GovernorateEntity governorate;
  final String locale;
  final List<String> merchantIds;
  final Map<String, String> merchantsInfo;
  final Map<String, double> shippingData; // merchantId -> price

  const _GovernorateItem({
    required this.governorate,
    required this.locale,
    required this.merchantIds,
    required this.merchantsInfo,
    required this.shippingData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Count available merchants (price exists = available)
    int availableCount = 0;
    for (final merchantId in merchantIds) {
      if (shippingData.containsKey(merchantId)) {
        availableCount++;
      }
    }

    final allAvailable = availableCount == merchantIds.length;
    final noneAvailable = availableCount == 0;

    return Row(
      children: [
        Expanded(
          child: Text(
            governorate.getName(locale),
            style: TextStyle(color: theme.colorScheme.primary),
          ),
        ),
        if (merchantIds.length > 1) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: allAvailable
                  ? Colors.green.withValues(alpha: 0.1)
                  : noneAvailable
                      ? Colors.red.withValues(alpha: 0.1)
                      : Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  allAvailable
                      ? Icons.check_circle
                      : noneAvailable
                          ? Icons.cancel
                          : Icons.warning,
                  size: 12,
                  color: allAvailable
                      ? Colors.green
                      : noneAvailable
                          ? Colors.red
                          : Colors.orange,
                ),
                const SizedBox(width: 4),
                Text(
                  '$availableCount/${merchantIds.length}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: allAvailable
                        ? Colors.green
                        : noneAvailable
                            ? Colors.red
                            : Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _MerchantsAvailabilityInfo extends StatelessWidget {
  final List<String> merchantIds;
  final Map<String, String> merchantsInfo;
  final Map<String, double> shippingData;
  final String locale;

  const _MerchantsAvailabilityInfo({
    required this.merchantIds,
    required this.merchantsInfo,
    required this.shippingData,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    final isRtl = locale == 'ar';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isRtl ? 'توفر التوصيل:' : 'Delivery availability:',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...merchantIds.map((merchantId) {
            final isAvailable = shippingData.containsKey(merchantId);
            final storeName = merchantsInfo[merchantId] ?? '';

            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(
                    isAvailable ? Icons.check_circle : Icons.cancel,
                    size: 16,
                    color: isAvailable ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      storeName.isNotEmpty ? storeName : merchantId,
                      style: TextStyle(
                        fontSize: 13,
                        color: isAvailable
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                      ),
                    ),
                  ),
                  Text(
                    isAvailable
                        ? (isRtl ? 'متاح' : 'Available')
                        : (isRtl ? 'غير متاح' : 'Not available'),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isAvailable ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
