import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../shipping/domain/entities/governorate_entity.dart';
import 'governorate_dropdown.dart';
import 'address_field.dart';
import 'merchants_availability.dart';

class DeliveryAddressForm extends StatelessWidget {
  final List<GovernorateEntity> governorates;
  final List<GovernorateEntity> displayGovernorates;
  final GovernorateEntity? validSelected;
  final String locale;
  final List<String> merchantIds;
  final Map<String, Map<String, double>> merchantsShippingData;
  final Map<String, String> merchantsInfo;
  final TextEditingController addressController;
  final bool isRtl;

  const DeliveryAddressForm({
    super.key,
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
          GovernorateDropdown(
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
          AddressField(controller: addressController),
          if (validSelected != null &&
              !isSingleMerchant &&
              hasShippingData) ...[
            const SizedBox(height: 12),
            MerchantsAvailability(
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
