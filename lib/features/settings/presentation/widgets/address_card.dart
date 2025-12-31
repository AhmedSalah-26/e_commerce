import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../shipping/presentation/cubit/shipping_cubit.dart';

class AddressCard extends StatelessWidget {
  final UserAddress address;
  final bool isRtl;
  final VoidCallback onEdit;

  const AddressCard({
    super.key,
    required this.address,
    required this.isRtl,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<ShippingCubit, ShippingState>(
      builder: (context, shippingState) {
        final fullDisplay = _buildFullDisplay(shippingState);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: address.isDefault
                ? BorderSide(color: theme.colorScheme.primary, width: 2)
                : BorderSide.none,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(theme),
                const SizedBox(height: 8),
                Text(
                  fullDisplay,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 12),
                _buildActions(context, theme),
              ],
            ),
          ),
        );
      },
    );
  }

  String _buildFullDisplay(ShippingState shippingState) {
    String governorateName = '';
    if (shippingState is GovernoratesLoaded) {
      final govId = address.governorateId;
      if (govId != null) {
        final gov =
            shippingState.governorates.where((g) => g.id == govId).firstOrNull;
        if (gov != null) {
          governorateName = gov.getName(isRtl ? 'ar' : 'en');
        }
      }
    }
    return governorateName.isNotEmpty
        ? '$governorateName - ${address.detailedAddress}'
        : address.detailedAddress;
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        Icon(Icons.location_on, color: theme.colorScheme.primary, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            address.title,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        if (address.isDefault) _buildDefaultBadge(theme),
      ],
    );
  }

  Widget _buildDefaultBadge(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isRtl ? 'افتراضي' : 'Default',
        style: TextStyle(
          fontSize: 12,
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (!address.isDefault)
          TextButton.icon(
            onPressed: () =>
                context.read<AuthCubit>().setDefaultAddress(address.id),
            icon: const Icon(Icons.check_circle_outline, size: 18),
            label: Text(isRtl ? 'تعيين كافتراضي' : 'Set as default'),
          ),
        TextButton.icon(
          onPressed: onEdit,
          icon: const Icon(Icons.edit_outlined, size: 18),
          label: Text(isRtl ? 'تعديل' : 'Edit'),
        ),
        TextButton.icon(
          onPressed: () => _showDeleteDialog(context),
          icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
          label: Text(isRtl ? 'حذف' : 'Delete',
              style: const TextStyle(color: Colors.red)),
        ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context) {
    final authCubit = context.read<AuthCubit>();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isRtl ? 'حذف العنوان' : 'Delete Address'),
        content: Text(isRtl
            ? 'هل أنت متأكد من حذف هذا العنوان؟'
            : 'Are you sure you want to delete this address?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isRtl ? 'إلغاء' : 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              authCubit.deleteAddress(address.id);
            },
            child: Text(isRtl ? 'حذف' : 'Delete',
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
