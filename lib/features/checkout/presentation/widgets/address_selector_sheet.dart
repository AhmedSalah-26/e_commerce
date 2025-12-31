import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../shipping/domain/entities/governorate_entity.dart';

class AddressSelectorSheet extends StatelessWidget {
  final List<UserAddress> addresses;
  final List<GovernorateEntity> governorates;
  final bool isRtl;
  final void Function(UserAddress) onSelect;

  const AddressSelectorSheet({
    super.key,
    required this.addresses,
    required this.governorates,
    required this.isRtl,
    required this.onSelect,
  });

  String _getGovernorateName(String? govId) {
    if (govId == null) return '';
    try {
      final gov = governorates.firstWhere((g) => g.id == govId);
      return gov.getName(isRtl ? 'ar' : 'en');
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          _buildHeader(context, theme),
          const SizedBox(height: 16),
          _buildAddressList(theme),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Icon(Icons.location_on, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isRtl ? 'اختر عنوان' : 'Select Address',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              final router = GoRouter.of(context);
              Navigator.pop(context);
              router.push('/my-addresses');
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ),
            tooltip: isRtl ? 'إضافة عنوان جديد' : 'Add new address',
          ),
        ],
      ),
    );
  }

  Widget _buildAddressList(ThemeData theme) {
    return Flexible(
      child: ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: addresses.length,
        itemBuilder: (context, index) {
          final address = addresses[index];
          final govName = _getGovernorateName(address.governorateId);
          final fullDisplay = govName.isNotEmpty
              ? '$govName - ${address.detailedAddress}'
              : address.detailedAddress;

          return _AddressItem(
            address: address,
            fullDisplay: fullDisplay,
            isRtl: isRtl,
            onTap: () {
              Navigator.pop(context);
              onSelect(address);
            },
          );
        },
      ),
    );
  }
}

class _AddressItem extends StatelessWidget {
  final UserAddress address;
  final String fullDisplay;
  final bool isRtl;
  final VoidCallback onTap;

  const _AddressItem({
    required this.address,
    required this.fullDisplay,
    required this.isRtl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: address.isDefault
            ? BorderSide(color: theme.colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(Icons.location_on_outlined,
                  color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitleRow(theme),
                    const SizedBox(height: 4),
                    Text(
                      fullDisplay,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleRow(ThemeData theme) {
    return Row(
      children: [
        Text(
          address.title,
          style:
              theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        if (address.isDefault) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isRtl ? 'افتراضي' : 'Default',
              style: TextStyle(
                fontSize: 10,
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
