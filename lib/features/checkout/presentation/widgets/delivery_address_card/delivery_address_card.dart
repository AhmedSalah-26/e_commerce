import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../auth/domain/entities/user_entity.dart';
import '../../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../../auth/presentation/cubit/auth_state.dart';
import '../../../../cart/presentation/cubit/cart_state.dart';
import '../../../../shipping/domain/entities/governorate_entity.dart';
import '../../../../shipping/presentation/cubit/shipping_cubit.dart';
import '../address_selector_sheet.dart';
import 'delivery_address_header.dart';
import 'delivery_address_form.dart';

class DeliveryAddressCard extends StatelessWidget {
  final List<GovernorateEntity> governorates;
  final GovernorateEntity? selectedGovernorate;
  final String locale;
  final CartLoaded cartState;
  final Map<String, Map<String, double>> merchantsShippingData;
  final Map<String, String> merchantsInfo;
  final TextEditingController addressController;
  final void Function(UserAddress, GovernorateEntity?)? onAddressSelected;

  const DeliveryAddressCard({
    super.key,
    required this.governorates,
    required this.selectedGovernorate,
    required this.locale,
    required this.cartState,
    required this.addressController,
    this.merchantsShippingData = const {},
    this.merchantsInfo = const {},
    this.onAddressSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRtl = locale == 'ar';
    final merchantIds = merchantsInfo.keys.toList();
    final displayGovernorates = _filterGovernorates(merchantIds);
    final validSelected = _getValidSelected(displayGovernorates);

    return Container(
      decoration: _cardDecoration(theme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DeliveryAddressHeader(
            isRtl: isRtl,
            onChangeAddress: () => _showAddressSelector(context, isRtl),
          ),
          DeliveryAddressForm(
            governorates: governorates,
            displayGovernorates: displayGovernorates,
            validSelected: validSelected,
            locale: locale,
            merchantIds: merchantIds,
            merchantsShippingData: merchantsShippingData,
            merchantsInfo: merchantsInfo,
            addressController: addressController,
            isRtl: isRtl,
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration(ThemeData theme) => BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            width: 1.5),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      );

  List<GovernorateEntity> _filterGovernorates(List<String> merchantIds) {
    final isSingleMerchant = merchantIds.length == 1;
    final hasShippingData = merchantsShippingData.isNotEmpty;

    if (isSingleMerchant && hasShippingData) {
      final filtered = governorates.where((gov) {
        final data = merchantsShippingData[gov.id] ?? {};
        return data.containsKey(merchantIds.first);
      }).toList();
      return filtered.isEmpty ? governorates : filtered;
    }
    return governorates;
  }

  GovernorateEntity? _getValidSelected(
      List<GovernorateEntity> displayGovernorates) {
    if (selectedGovernorate == null) return null;
    return displayGovernorates.any((g) => g.id == selectedGovernorate!.id)
        ? selectedGovernorate
        : null;
  }

  void _showAddressSelector(BuildContext context, bool isRtl) {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) return;

    final shippingCubit = context.read<ShippingCubit>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => AddressSelectorSheet(
        addresses: authState.user.addresses,
        governorates: governorates,
        isRtl: isRtl,
        onSelect: (address) {
          addressController.text = address.detailedAddress;
          final govId = address.governorateId;
          if (govId != null) {
            final gov = governorates.where((g) => g.id == govId).firstOrNull;
            if (gov != null) {
              shippingCubit.selectGovernorateForMultipleMerchants(
                  gov, merchantsInfo.keys.toList());
            }
            onAddressSelected?.call(address, gov);
          }
        },
      ),
    );
  }
}
