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

  const GovernorateDropdown({
    super.key,
    required this.governorates,
    required this.selected,
    required this.locale,
    required this.cartState,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Get all unique merchant IDs from cart
    final merchantIds = <String>{};
    for (final item in cartState.items) {
      if (item.product?.merchantId != null) {
        merchantIds.add(item.product!.merchantId!);
      }
    }
    final merchantIdsList = merchantIds.toList();

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
                return DropdownMenuItem<GovernorateEntity>(
                  value: gov,
                  child: Text(
                    gov.getName(locale),
                    style: TextStyle(color: theme.colorScheme.primary),
                  ),
                );
              }).toList(),
              onChanged: (gov) {
                if (gov != null) {
                  // Use multi-merchant shipping calculation
                  context
                      .read<ShippingCubit>()
                      .selectGovernorateForMultipleMerchants(
                          gov, merchantIdsList);
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
