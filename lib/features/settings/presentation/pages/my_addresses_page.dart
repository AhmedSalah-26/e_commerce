import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../shipping/presentation/cubit/shipping_cubit.dart';
import '../widgets/add_edit_address_sheet.dart';
import '../widgets/address_card.dart';

class MyAddressesPage extends StatelessWidget {
  const MyAddressesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isRtl = context.locale.languageCode == 'ar';
    final theme = Theme.of(context);

    return Directionality(
      textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: _buildAppBar(context, theme, isRtl),
        body: _AddressesBody(isRtl: isRtl),
        floatingActionButton: _buildFab(context, isRtl),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, ThemeData theme, bool isRtl) {
    return AppBar(
      backgroundColor: theme.colorScheme.surface,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        isRtl ? 'عناويني' : 'My Addresses',
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.primary,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildFab(BuildContext context, bool isRtl) {
    return FloatingActionButton.extended(
      onPressed: () => _showAddAddressDialog(context, isRtl),
      icon: const Icon(Icons.add),
      label: Text(isRtl ? 'إضافة عنوان' : 'Add Address'),
    );
  }

  void _showAddAddressDialog(BuildContext context, bool isRtl) {
    final shippingCubit = context.read<ShippingCubit>();
    final authCubit = context.read<AuthCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: shippingCubit),
          BlocProvider.value(value: authCubit),
        ],
        child: AddEditAddressSheet(isRtl: isRtl),
      ),
    );
  }
}

class _AddressesBody extends StatelessWidget {
  final bool isRtl;

  const _AddressesBody({required this.isRtl});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) {
          return const Center(child: CircularProgressIndicator());
        }

        final addresses = authState.user.addresses;

        if (addresses.isEmpty) {
          return _EmptyAddresses(isRtl: isRtl);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: addresses.length,
          itemBuilder: (context, index) {
            final address = addresses[index];
            return AddressCard(
              address: address,
              isRtl: isRtl,
              onEdit: () => _showEditDialog(context, address),
            );
          },
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, address) {
    final shippingCubit = context.read<ShippingCubit>();
    final authCubit = context.read<AuthCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: shippingCubit),
          BlocProvider.value(value: authCubit),
        ],
        child: AddEditAddressSheet(isRtl: isRtl, address: address),
      ),
    );
  }
}

class _EmptyAddresses extends StatelessWidget {
  final bool isRtl;

  const _EmptyAddresses({required this.isRtl});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off_outlined,
              size: 80, color: theme.colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            isRtl ? 'لا توجد عناوين محفوظة' : 'No saved addresses',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isRtl
                ? 'أضف عنوانك لتسهيل عملية الطلب'
                : 'Add your address for easier checkout',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
