import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
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
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColours.brownMedium,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColours.brownLight, width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<GovernorateEntity>(
              value: selected,
              hint: Text(
                'select_governorate'.tr(),
                style: const TextStyle(color: AppColours.brownMedium),
              ),
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: AppColours.brownMedium,
              ),
              dropdownColor: Colors.white,
              items: governorates.map((gov) {
                return DropdownMenuItem<GovernorateEntity>(
                  value: gov,
                  child: Text(
                    gov.getName(locale),
                    style: const TextStyle(color: AppColours.brownMedium),
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
