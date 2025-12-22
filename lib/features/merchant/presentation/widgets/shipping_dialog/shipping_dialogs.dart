import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../shipping/domain/entities/governorate_entity.dart';

class ShippingDialogs {
  static void showAddShippingZoneDialog(
    BuildContext context,
    List<GovernorateEntity> availableGovernorates,
    String locale,
    Function(GovernorateEntity) onGovernorateSelected,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('add_shipping_zone'.tr()),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: availableGovernorates.length,
            itemBuilder: (context, index) {
              final gov = availableGovernorates[index];
              return ListTile(
                leading: const Icon(
                  Icons.location_city,
                  color: AppColours.brownMedium,
                ),
                title: Text(gov.getName(locale)),
                trailing: const Icon(Icons.add, color: Colors.green),
                onTap: () {
                  Navigator.pop(dialogContext);
                  onGovernorateSelected(gov);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('cancel'.tr()),
          ),
        ],
      ),
    );
  }

  static void showEditPriceDialog(
    BuildContext context,
    GovernorateEntity governorate,
    double? currentPrice,
    String locale, {
    required Function(double) onSave,
    required VoidCallback? onDelete,
  }) {
    final controller =
        TextEditingController(text: currentPrice?.toStringAsFixed(0) ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(governorate.getName(locale)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'shipping_cost'.tr(),
            suffixText: 'egp'.tr(),
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          if (currentPrice != null && onDelete != null)
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                onDelete();
              },
              child: Text(
                'delete'.tr(),
                style: const TextStyle(color: Colors.red),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () {
              final price = double.tryParse(controller.text);
              if (price != null && price >= 0) {
                Navigator.pop(dialogContext);
                onSave(price);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColours.brownLight,
            ),
            child: Text('save'.tr()),
          ),
        ],
      ),
    );
  }
}
