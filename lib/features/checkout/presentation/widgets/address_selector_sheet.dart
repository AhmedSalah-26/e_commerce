import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../shipping/domain/entities/governorate_entity.dart';

class AddressSelectorSheet extends StatefulWidget {
  final List<UserAddress> addresses;
  final List<GovernorateEntity> governorates;
  final bool isRtl;
  final void Function(UserAddress) onSelect;
  final UserAddress? currentAddress;

  const AddressSelectorSheet({
    super.key,
    required this.addresses,
    required this.governorates,
    required this.isRtl,
    required this.onSelect,
    this.currentAddress,
  });

  @override
  State<AddressSelectorSheet> createState() => _AddressSelectorSheetState();
}

class _AddressSelectorSheetState extends State<AddressSelectorSheet> {
  UserAddress? _selectedAddress;

  @override
  void initState() {
    super.initState();
    // Don't pre-select any address - user must choose
    _selectedAddress = null;
  }

  String _getGovernorateName(String? govId) {
    if (govId == null) return '';
    try {
      final gov = widget.governorates.firstWhere((g) => g.id == govId);
      return gov.getName(widget.isRtl ? 'ar' : 'en');
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
          const SizedBox(height: 16),
          _buildConfirmButton(context, theme),
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
              widget.isRtl ? 'اختر عنوان' : 'Select Address',
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
            tooltip: widget.isRtl ? 'إضافة عنوان جديد' : 'Add new address',
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
        itemCount: widget.addresses.length,
        itemBuilder: (context, index) {
          final address = widget.addresses[index];
          final govName = _getGovernorateName(address.governorateId);
          final fullDisplay = govName.isNotEmpty
              ? '$govName - ${address.detailedAddress}'
              : address.detailedAddress;
          final isSelected = _selectedAddress?.id == address.id;

          return _AddressItem(
            address: address,
            fullDisplay: fullDisplay,
            isRtl: widget.isRtl,
            isSelected: isSelected,
            onTap: () {
              setState(() {
                _selectedAddress = address;
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context, ThemeData theme) {
    final isEnabled = _selectedAddress != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isEnabled
              ? () {
                  Navigator.pop(context);
                  widget.onSelect(_selectedAddress!);
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor:
                theme.colorScheme.primary.withValues(alpha: 0.3),
            disabledForegroundColor: Colors.white70,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            widget.isRtl ? 'تأكيد العنوان' : 'Confirm Address',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _AddressItem extends StatelessWidget {
  final UserAddress address;
  final String fullDisplay;
  final bool isRtl;
  final bool isSelected;
  final VoidCallback onTap;

  const _AddressItem({
    required this.address,
    required this.fullDisplay,
    required this.isRtl,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: theme.colorScheme.primary, width: 2)
            : address.isDefault
                ? BorderSide(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    width: 1)
                : BorderSide.none,
      ),
      color:
          isSelected ? theme.colorScheme.primary.withValues(alpha: 0.05) : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Selection indicator
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline,
                    width: 2,
                  ),
                  color: isSelected ? theme.colorScheme.primary : null,
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 12),
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
