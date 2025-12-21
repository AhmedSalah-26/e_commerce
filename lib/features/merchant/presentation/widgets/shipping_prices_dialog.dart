import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/shared_widgets/toast.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../shipping/domain/entities/governorate_entity.dart';
import '../../../shipping/domain/entities/shipping_price_entity.dart';
import '../../../shipping/presentation/cubit/shipping_cubit.dart';

class ShippingPricesDialog extends StatelessWidget {
  final bool isRtl;

  const ShippingPricesDialog({super.key, required this.isRtl});

  static Future<void> show(BuildContext context, bool isRtl) async {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider(
        create: (context) =>
            sl<ShippingCubit>()..loadMerchantShippingPrices(authState.user.id),
        child: ShippingPricesDialog(isRtl: isRtl),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.locale.languageCode;

    return Directionality(
      textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      'shipping_prices'.tr(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColours.brownDark,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            const Divider(height: 1),
            // Content
            Expanded(
              child: BlocBuilder<ShippingCubit, ShippingState>(
                builder: (context, state) {
                  if (state is ShippingLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is ShippingError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(state.message,
                              style: const TextStyle(color: Colors.red)),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              final authState = context.read<AuthCubit>().state;
                              if (authState is AuthAuthenticated) {
                                context
                                    .read<ShippingCubit>()
                                    .loadMerchantShippingPrices(
                                        authState.user.id);
                              }
                            },
                            child: Text('retry'.tr()),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is MerchantShippingPricesLoaded) {
                    return _buildPricesList(
                        context, state.governorates, state.prices, locale);
                  }

                  return Center(child: Text('no_shipping_prices'.tr()));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricesList(
    BuildContext context,
    List<GovernorateEntity> governorates,
    List<ShippingPriceEntity> prices,
    String locale,
  ) {
    // Create a map of governorate prices
    final priceMap = <String, double>{};
    for (final price in prices) {
      priceMap[price.governorateId] = price.price;
    }

    // Separate governorates with and without prices
    final withPrices =
        governorates.where((g) => priceMap.containsKey(g.id)).toList();
    final withoutPrices =
        governorates.where((g) => !priceMap.containsKey(g.id)).toList();

    return Column(
      children: [
        // Add new shipping zone button
        if (withoutPrices.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: InkWell(
              onTap: () =>
                  _showAddShippingZoneDialog(context, withoutPrices, locale),
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
                    const Icon(Icons.add_circle_outline,
                        color: AppColours.brownMedium),
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
          ),
        const SizedBox(height: 8),
        // Active shipping zones header
        if (withPrices.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              children: [
                const Icon(Icons.local_shipping, size: 18, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'active_shipping_zones'.tr(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade700,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${withPrices.length}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        // List of governorates with prices
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
                return _GovernorateShippingCard(
                  governorate: gov,
                  price: price,
                  locale: locale,
                  onEdit: () =>
                      _showEditPriceDialog(context, gov, price, locale),
                );
              }

              // Inactive zones header
              if (index == withPrices.length && withoutPrices.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.location_off,
                          size: 18, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        'inactive_shipping_zones'.tr(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${withoutPrices.length}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Inactive zones
              final inactiveIndex = index - withPrices.length - 1;
              if (inactiveIndex >= 0 && inactiveIndex < withoutPrices.length) {
                final gov = withoutPrices[inactiveIndex];
                return _GovernorateShippingCard(
                  governorate: gov,
                  price: null,
                  locale: locale,
                  onEdit: () =>
                      _showEditPriceDialog(context, gov, null, locale),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }

  void _showAddShippingZoneDialog(
    BuildContext parentContext,
    List<GovernorateEntity> availableGovernorates,
    String locale,
  ) {
    showDialog(
      context: parentContext,
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
                leading: const Icon(Icons.location_city,
                    color: AppColours.brownMedium),
                title: Text(gov.getName(locale)),
                trailing: const Icon(Icons.add, color: Colors.green),
                onTap: () {
                  Navigator.pop(dialogContext);
                  _showEditPriceDialog(parentContext, gov, null, locale);
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

  void _showEditPriceDialog(
    BuildContext parentContext,
    GovernorateEntity governorate,
    double? currentPrice,
    String locale,
  ) {
    final controller =
        TextEditingController(text: currentPrice?.toStringAsFixed(0) ?? '');

    showDialog(
      context: parentContext,
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
          if (currentPrice != null)
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _deletePrice(parentContext, governorate.id);
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
                _savePrice(parentContext, governorate.id, price);
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

  void _savePrice(BuildContext context, String governorateId, double price) {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      context
          .read<ShippingCubit>()
          .setShippingPrice(authState.user.id, governorateId, price);
      Tost.showCustomToast(
        context,
        'shipping_price_updated'.tr(),
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    }
  }

  void _deletePrice(BuildContext context, String governorateId) {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      context
          .read<ShippingCubit>()
          .deleteShippingPrice(authState.user.id, governorateId);
      Tost.showCustomToast(
        context,
        'deleted'.tr(),
        backgroundColor: Colors.orange,
        textColor: Colors.white,
      );
    }
  }
}

class _GovernorateShippingCard extends StatelessWidget {
  final GovernorateEntity governorate;
  final double? price;
  final String locale;
  final VoidCallback onEdit;

  const _GovernorateShippingCard({
    required this.governorate,
    required this.price,
    required this.locale,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final hasPrice = price != null;

    return Container(
      decoration: BoxDecoration(
        color: hasPrice ? Colors.green.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasPrice ? Colors.green.shade200 : Colors.grey.shade300,
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: hasPrice
                ? Colors.green.withValues(alpha: 0.2)
                : Colors.grey.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.location_city,
            color: hasPrice ? Colors.green : Colors.grey,
          ),
        ),
        title: Text(
          governorate.getName(locale),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          hasPrice
              ? '${price!.toStringAsFixed(0)} ${'egp'.tr()}'
              : 'no_shipping_prices'.tr(),
          style: TextStyle(
            color: hasPrice ? Colors.green.shade700 : Colors.grey,
          ),
        ),
        trailing: IconButton(
          icon: Icon(
            hasPrice ? Icons.edit : Icons.add,
            color: AppColours.brownMedium,
          ),
          onPressed: onEdit,
        ),
        onTap: onEdit,
      ),
    );
  }
}
