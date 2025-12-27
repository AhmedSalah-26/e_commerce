import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/shared_widgets/toast.dart';
import '../../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../../auth/presentation/cubit/auth_state.dart';
import '../../../../shipping/domain/entities/governorate_entity.dart';
import '../../../../shipping/presentation/cubit/shipping_cubit.dart';
import 'shipping_prices_list.dart';
import 'shipping_dialogs.dart';

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
    final theme = Theme.of(context);

    return Directionality(
      textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            _buildHandle(theme),
            _buildHeader(context, theme),
            const Divider(height: 1),
            Expanded(child: _buildContent(context, locale)),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: theme.colorScheme.outline.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Padding(
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
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, String locale) {
    return BlocBuilder<ShippingCubit, ShippingState>(
      builder: (context, state) {
        if (state is ShippingLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ShippingError) {
          return _buildError(context, state.message);
        }

        if (state is MerchantShippingPricesLoaded) {
          return ShippingPricesList(
            governorates: state.governorates,
            prices: state.prices,
            locale: locale,
            onEditPrice: (gov, price) =>
                _showEditPriceDialog(context, gov, price, locale),
            onAddZone: () => _showAddShippingZoneDialog(
              context,
              state.governorates
                  .where(
                      (g) => !state.prices.any((p) => p.governorateId == g.id))
                  .toList(),
              locale,
            ),
          );
        }

        return Center(child: Text('no_shipping_prices'.tr()));
      },
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              final authState = context.read<AuthCubit>().state;
              if (authState is AuthAuthenticated) {
                context
                    .read<ShippingCubit>()
                    .loadMerchantShippingPrices(authState.user.id);
              }
            },
            child: Text('retry'.tr()),
          ),
        ],
      ),
    );
  }

  void _showAddShippingZoneDialog(
    BuildContext context,
    List<GovernorateEntity> availableGovernorates,
    String locale,
  ) {
    ShippingDialogs.showAddShippingZoneDialog(
      context,
      availableGovernorates,
      locale,
      (gov) => _showEditPriceDialog(context, gov, null, locale),
    );
  }

  void _showEditPriceDialog(
    BuildContext context,
    GovernorateEntity governorate,
    double? currentPrice,
    String locale,
  ) {
    ShippingDialogs.showEditPriceDialog(
      context,
      governorate,
      currentPrice,
      locale,
      onSave: (price) => _savePrice(context, governorate.id, price),
      onDelete: currentPrice != null
          ? () => _deletePrice(context, governorate.id)
          : null,
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
