import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../shipping/domain/entities/governorate_entity.dart';

class ShippingDialogs {
  static void showAddShippingZoneDialog(
    BuildContext context,
    List<GovernorateEntity> availableGovernorates,
    String locale,
    Function(GovernorateEntity) onGovernorateSelected,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 380, maxHeight: 500),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.15),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add_location_alt_outlined,
                  size: 32,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'add_shipping_zone'.tr(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: availableGovernorates.length,
                  itemBuilder: (context, index) {
                    final gov = availableGovernorates[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.colorScheme.outline),
                      ),
                      child: ListTile(
                        leading: Icon(
                          Icons.location_city,
                          color: theme.colorScheme.primary,
                        ),
                        title: Text(gov.getName(locale)),
                        trailing: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add,
                              color: Colors.green, size: 20),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        onTap: () {
                          Navigator.pop(dialogContext);
                          onGovernorateSelected(gov);
                        },
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: theme.colorScheme.outline),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'cancel'.tr(),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final controller =
        TextEditingController(text: currentPrice?.toStringAsFixed(0) ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 340),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.15),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.local_shipping_outlined,
                  size: 32,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                governorate.getName(locale),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    labelText: 'shipping_cost'.tr(),
                    suffixText: 'egp'.tr(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: theme.colorScheme.primary, width: 2),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side:
                                  BorderSide(color: theme.colorScheme.outline),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'cancel'.tr(),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.7),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              final price = double.tryParse(controller.text);
                              if (price != null && price >= 0) {
                                Navigator.pop(dialogContext);
                                onSave(price);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'save'.tr(),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (currentPrice != null && onDelete != null) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(dialogContext);
                            onDelete();
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(
                            'delete'.tr(),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
