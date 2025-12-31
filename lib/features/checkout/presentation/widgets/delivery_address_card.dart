import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../cart/presentation/cubit/cart_state.dart';
import '../../../shipping/domain/entities/governorate_entity.dart';
import '../../../shipping/presentation/cubit/shipping_cubit.dart';
import 'address_selector_sheet.dart';

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
          _Header(
              isRtl: isRtl,
              onChangeAddress: () => _showAddressSelector(context, isRtl)),
          _FormContent(
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

class _Header extends StatelessWidget {
  final bool isRtl;
  final VoidCallback onChangeAddress;

  const _Header({required this.isRtl, required this.onChangeAddress});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
      ),
      child: Row(
        children: [
          Icon(Icons.location_on, color: theme.colorScheme.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isRtl ? 'عنوان التوصيل' : 'Delivery Address',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              if (state is! AuthAuthenticated || state.user.addresses.isEmpty) {
                return const SizedBox.shrink();
              }
              return _ChangeButton(isRtl: isRtl, onPressed: onChangeAddress);
            },
          ),
        ],
      ),
    );
  }
}

class _ChangeButton extends StatelessWidget {
  final bool isRtl;
  final VoidCallback onPressed;

  const _ChangeButton({required this.isRtl, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(Icons.swap_horiz, size: 18, color: theme.colorScheme.primary),
      label: Text(
        isRtl ? 'تبديل' : 'Change',
        style: TextStyle(
            color: theme.colorScheme.primary, fontWeight: FontWeight.w600),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}

class _FormContent extends StatelessWidget {
  final List<GovernorateEntity> governorates;
  final List<GovernorateEntity> displayGovernorates;
  final GovernorateEntity? validSelected;
  final String locale;
  final List<String> merchantIds;
  final Map<String, Map<String, double>> merchantsShippingData;
  final Map<String, String> merchantsInfo;
  final TextEditingController addressController;
  final bool isRtl;

  const _FormContent({
    required this.governorates,
    required this.displayGovernorates,
    required this.validSelected,
    required this.locale,
    required this.merchantIds,
    required this.merchantsShippingData,
    required this.merchantsInfo,
    required this.addressController,
    required this.isRtl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSingleMerchant = merchantIds.length == 1;
    final hasShippingData = merchantsShippingData.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('governorate'.tr(), theme),
          const SizedBox(height: 8),
          _GovernorateDropdown(
            governorates: governorates,
            displayGovernorates: displayGovernorates,
            validSelected: validSelected,
            locale: locale,
            merchantIds: merchantIds,
            merchantsShippingData: merchantsShippingData,
            isSingleMerchant: isSingleMerchant,
            hasShippingData: hasShippingData,
          ),
          const SizedBox(height: 16),
          _buildLabel(isRtl ? 'العنوان التفصيلي' : 'Detailed Address', theme),
          const SizedBox(height: 8),
          _AddressField(controller: addressController),
          if (validSelected != null &&
              !isSingleMerchant &&
              hasShippingData) ...[
            const SizedBox(height: 12),
            _MerchantsAvailability(
              merchantIds: merchantIds,
              merchantsInfo: merchantsInfo,
              shippingData: merchantsShippingData[validSelected!.id] ?? {},
              isRtl: isRtl,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLabel(String text, ThemeData theme) => Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
        ),
      );
}

class _GovernorateDropdown extends StatelessWidget {
  final List<GovernorateEntity> governorates;
  final List<GovernorateEntity> displayGovernorates;
  final GovernorateEntity? validSelected;
  final String locale;
  final List<String> merchantIds;
  final Map<String, Map<String, double>> merchantsShippingData;
  final bool isSingleMerchant;
  final bool hasShippingData;

  const _GovernorateDropdown({
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
                : _GovernorateItem(
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

class _GovernorateItem extends StatelessWidget {
  final GovernorateEntity gov;
  final String locale;
  final List<String> merchantIds;
  final Map<String, double> shippingData;

  const _GovernorateItem(
      {required this.gov,
      required this.locale,
      required this.merchantIds,
      required this.shippingData});

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

class _AddressField extends StatelessWidget {
  final TextEditingController controller;

  const _AddressField({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: controller,
      maxLines: 2,
      decoration: InputDecoration(
        hintText: 'delivery_address_hint'.tr(),
        prefixIcon: Icon(Icons.home_outlined,
            color: theme.colorScheme.primary.withValues(alpha: 0.7)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: theme.colorScheme.outline.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      validator: (value) =>
          (value == null || value.isEmpty) ? 'field_required'.tr() : null,
    );
  }
}

class _MerchantsAvailability extends StatelessWidget {
  final List<String> merchantIds;
  final Map<String, String> merchantsInfo;
  final Map<String, double> shippingData;
  final bool isRtl;

  const _MerchantsAvailability({
    required this.merchantIds,
    required this.merchantsInfo,
    required this.shippingData,
    required this.isRtl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(isRtl ? 'توفر التوصيل:' : 'Delivery availability:',
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          ...merchantIds.map((id) {
            final available = shippingData.containsKey(id);
            return Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Row(
                children: [
                  Icon(available ? Icons.check_circle : Icons.cancel,
                      size: 14, color: available ? Colors.green : Colors.red),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      merchantsInfo[id] ?? id,
                      style: TextStyle(
                          fontSize: 12,
                          color: available
                              ? Colors.green.shade700
                              : Colors.red.shade700),
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
