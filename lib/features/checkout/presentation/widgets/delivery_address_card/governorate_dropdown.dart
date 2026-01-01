import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shipping/domain/entities/governorate_entity.dart';
import '../../../../shipping/presentation/cubit/shipping_cubit.dart';

class GovernorateDropdown extends StatelessWidget {
  final List<GovernorateEntity> governorates;
  final List<GovernorateEntity> displayGovernorates;
  final GovernorateEntity? validSelected;
  final String locale;
  final List<String> merchantIds;
  final Map<String, Map<String, double>> merchantsShippingData;
  final bool isSingleMerchant;
  final bool hasShippingData;

  const GovernorateDropdown({
    super.key,
    required this.governorates,
    required this.displayGovernorates,
    required this.validSelected,
    required this.locale,
    required this.merchantIds,
    required this.merchantsShippingData,
    required this.isSingleMerchant,
    required this.hasShippingData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border:
            Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: governorates.isEmpty
          ? _buildLoading(theme)
          : _buildDropdown(context, theme),
    );
  }

  Widget _buildLoading(ThemeData theme) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 12),
            Text('loading'.tr(),
                style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
          ],
        ),
      );

  Widget _buildDropdown(BuildContext context, ThemeData theme) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<GovernorateEntity>(
        value: validSelected,
        hint: Text('select_governorate'.tr(),
            style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
        isExpanded: true,
        icon: Icon(Icons.keyboard_arrow_down, color: theme.colorScheme.primary),
        dropdownColor: theme.colorScheme.surface,
        items: displayGovernorates.map((gov) {
          final shippingData = merchantsShippingData[gov.id] ?? {};
          return DropdownMenuItem<GovernorateEntity>(
            value: gov,
            child: (isSingleMerchant && hasShippingData)
                ? Text(gov.getName(locale))
                : GovernorateItem(
                    gov: gov,
                    locale: locale,
                    merchantIds: merchantIds,
                    shippingData: shippingData),
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
    );
  }
}

class GovernorateItem extends StatelessWidget {
  final GovernorateEntity gov;
  final String locale;
  final List<String> merchantIds;
  final Map<String, double> shippingData;

  const GovernorateItem({
    super.key,
    required this.gov,
    required this.locale,
    required this.merchantIds,
    required this.shippingData,
  });

  @override
  Widget build(BuildContext context) {
    final count =
        merchantIds.where((id) => shippingData.containsKey(id)).length;
    final allAvailable = count == merchantIds.length;
    final noneAvailable = count == 0;

    return Row(
      children: [
        Expanded(child: Text(gov.getName(locale))),
        if (merchantIds.length > 1) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: (allAvailable
                      ? Colors.green
                      : noneAvailable
                          ? Colors.red
                          : Colors.orange)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '$count/${merchantIds.length}',
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
          ),
        ],
      ],
    );
  }
}
