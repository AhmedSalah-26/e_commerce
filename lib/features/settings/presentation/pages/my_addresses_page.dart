import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/shared_widgets/toast.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../shipping/domain/entities/governorate_entity.dart';
import '../../../shipping/presentation/cubit/shipping_cubit.dart';

class MyAddressesPage extends StatelessWidget {
  const MyAddressesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isRtl = context.locale.languageCode == 'ar';
    final theme = Theme.of(context);

    return BlocProvider(
      create: (_) => sl<ShippingCubit>()..loadGovernorates(),
      child: Directionality(
        textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
        child: Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
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
          ),
          body: BlocBuilder<AuthCubit, AuthState>(
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
                  return _AddressCard(
                    address: address,
                    isRtl: isRtl,
                  );
                },
              );
            },
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddAddressDialog(context, isRtl),
            icon: const Icon(Icons.add),
            label: Text(isRtl ? 'إضافة عنوان' : 'Add Address'),
          ),
        ),
      ),
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
        child: _AddEditAddressSheet(isRtl: isRtl),
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
          Icon(
            Icons.location_off_outlined,
            size: 80,
            color: theme.colorScheme.outline,
          ),
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

class _AddressCard extends StatelessWidget {
  final UserAddress address;
  final bool isRtl;

  const _AddressCard({required this.address, required this.isRtl});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    address.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (address.isDefault)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              address.displayAddress,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!address.isDefault)
                  TextButton.icon(
                    onPressed: () => _setAsDefault(context),
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: Text(isRtl ? 'تعيين كافتراضي' : 'Set as default'),
                  ),
                TextButton.icon(
                  onPressed: () => _editAddress(context),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: Text(isRtl ? 'تعديل' : 'Edit'),
                ),
                TextButton.icon(
                  onPressed: () => _deleteAddress(context),
                  icon: const Icon(Icons.delete_outline,
                      size: 18, color: Colors.red),
                  label: Text(
                    isRtl ? 'حذف' : 'Delete',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _setAsDefault(BuildContext context) {
    context.read<AuthCubit>().setDefaultAddress(address.id);
  }

  void _editAddress(BuildContext context) {
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
        child: _AddEditAddressSheet(isRtl: isRtl, address: address),
      ),
    );
  }

  void _deleteAddress(BuildContext context) {
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
            child: Text(
              isRtl ? 'حذف' : 'Delete',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddEditAddressSheet extends StatefulWidget {
  final bool isRtl;
  final UserAddress? address;

  const _AddEditAddressSheet({required this.isRtl, this.address});

  @override
  State<_AddEditAddressSheet> createState() => _AddEditAddressSheetState();
}

class _AddEditAddressSheetState extends State<_AddEditAddressSheet> {
  final _titleController = TextEditingController();
  final _addressController = TextEditingController();
  GovernorateEntity? _selectedGovernorate;
  bool _isDefault = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.address != null) {
      _titleController.text = widget.address!.title;
      _addressController.text = widget.address!.displayAddress;
      _isDefault = widget.address!.isDefault;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.address != null
                  ? (widget.isRtl ? 'تعديل العنوان' : 'Edit Address')
                  : (widget.isRtl ? 'إضافة عنوان جديد' : 'Add New Address'),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: widget.isRtl ? 'اسم العنوان' : 'Address Title',
                hintText:
                    widget.isRtl ? 'مثال: المنزل، العمل' : 'e.g. Home, Work',
                prefixIcon: const Icon(Icons.label_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            BlocBuilder<ShippingCubit, ShippingState>(
              builder: (context, state) {
                if (state is ShippingLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                List<GovernorateEntity> governorates = [];
                if (state is GovernoratesLoaded) {
                  governorates = state.governorates;
                }

                // Set initial governorate if editing
                if (widget.address != null &&
                    _selectedGovernorate == null &&
                    governorates.isNotEmpty) {
                  final govId = widget.address!.governorateId;
                  _selectedGovernorate = governorates.firstWhere(
                    (g) => g.id == govId,
                    orElse: () => governorates.first,
                  );
                }

                return DropdownButtonFormField<GovernorateEntity>(
                  value: _selectedGovernorate,
                  decoration: InputDecoration(
                    labelText: widget.isRtl ? 'المحافظة' : 'Governorate',
                    prefixIcon: const Icon(Icons.location_city),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: governorates.map((gov) {
                    return DropdownMenuItem(
                      value: gov,
                      child: Text(gov.getName(widget.isRtl ? 'ar' : 'en')),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedGovernorate = value);
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _addressController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText:
                    widget.isRtl ? 'العنوان التفصيلي' : 'Detailed Address',
                hintText: widget.isRtl
                    ? 'الشارع، المبنى، الشقة...'
                    : 'Street, Building, Apartment...',
                prefixIcon: const Icon(Icons.home_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              value: _isDefault,
              onChanged: (value) => setState(() => _isDefault = value ?? false),
              title: Text(
                widget.isRtl
                    ? 'تعيين كعنوان افتراضي'
                    : 'Set as default address',
              ),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveAddress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        widget.isRtl ? 'حفظ' : 'Save',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Future<void> _saveAddress() async {
    if (_titleController.text.trim().isEmpty) {
      Tost.showCustomToast(
        context,
        widget.isRtl ? 'يرجى إدخال اسم العنوان' : 'Please enter address title',
        backgroundColor: Colors.red,
      );
      return;
    }

    if (_selectedGovernorate == null) {
      Tost.showCustomToast(
        context,
        widget.isRtl ? 'يرجى اختيار المحافظة' : 'Please select governorate',
        backgroundColor: Colors.red,
      );
      return;
    }

    if (_addressController.text.trim().isEmpty) {
      Tost.showCustomToast(
        context,
        widget.isRtl
            ? 'يرجى إدخال العنوان التفصيلي'
            : 'Please enter detailed address',
        backgroundColor: Colors.red,
      );
      return;
    }

    setState(() => _isLoading = true);

    final govName = _selectedGovernorate!.getName(widget.isRtl ? 'ar' : 'en');
    final fullAddress = '$govName - ${_addressController.text.trim()}';

    final newAddress = UserAddress.create(
      governorateId: _selectedGovernorate!.id,
      detailedAddress: fullAddress,
      title: _titleController.text.trim(),
      isDefault: _isDefault,
    );

    bool success;
    if (widget.address != null) {
      // Update existing - keep same id structure but update content
      final updatedAddress = UserAddress(
        id: '${_selectedGovernorate!.id}:$fullAddress',
        title: _titleController.text.trim(),
        isDefault: _isDefault,
      );
      success = await context.read<AuthCubit>().updateAddress(updatedAddress);
    } else {
      success = await context.read<AuthCubit>().addAddress(newAddress);
    }

    setState(() => _isLoading = false);

    if (mounted) {
      Navigator.pop(context);
      Tost.showCustomToast(
        context,
        success
            ? (widget.isRtl ? 'تم الحفظ بنجاح' : 'Saved successfully')
            : (widget.isRtl ? 'فشل في الحفظ' : 'Failed to save'),
        backgroundColor: success ? Colors.green : Colors.red,
      );
    }
  }
}
