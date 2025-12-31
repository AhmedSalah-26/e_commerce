import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/shared_widgets/toast.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../shipping/domain/entities/governorate_entity.dart';
import '../../../shipping/presentation/cubit/shipping_cubit.dart';

class AddEditAddressSheet extends StatefulWidget {
  final bool isRtl;
  final UserAddress? address;

  const AddEditAddressSheet({super.key, required this.isRtl, this.address});

  @override
  State<AddEditAddressSheet> createState() => _AddEditAddressSheetState();
}

class _AddEditAddressSheetState extends State<AddEditAddressSheet> {
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
      _addressController.text = widget.address!.detailedAddress;
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
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
            _buildHandle(theme),
            const SizedBox(height: 20),
            _buildTitle(theme),
            const SizedBox(height: 20),
            _buildTitleField(theme),
            const SizedBox(height: 16),
            _buildGovernorateDropdown(),
            const SizedBox(height: 16),
            _buildAddressField(theme),
            const SizedBox(height: 16),
            _buildDefaultCheckbox(),
            const SizedBox(height: 20),
            _buildSaveButton(theme),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle(ThemeData theme) => Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      );

  Widget _buildTitle(ThemeData theme) => Text(
        widget.address != null
            ? (widget.isRtl ? 'تعديل العنوان' : 'Edit Address')
            : (widget.isRtl ? 'إضافة عنوان جديد' : 'Add New Address'),
        style:
            theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      );

  Widget _buildTitleField(ThemeData theme) => TextField(
        controller: _titleController,
        decoration: InputDecoration(
          labelText: widget.isRtl ? 'اسم العنوان' : 'Address Title',
          hintText: widget.isRtl ? 'مثال: المنزل، العمل' : 'e.g. Home, Work',
          prefixIcon: const Icon(Icons.label_outline),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

  Widget _buildGovernorateDropdown() {
    return BlocBuilder<ShippingCubit, ShippingState>(
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
          _selectedGovernorate =
              governorates.where((g) => g.id == govId).firstOrNull ??
                  governorates.first;
        }

        return DropdownButtonFormField<GovernorateEntity>(
          value: _selectedGovernorate,
          decoration: InputDecoration(
            labelText: widget.isRtl ? 'المحافظة' : 'Governorate',
            prefixIcon: const Icon(Icons.location_city),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          items: governorates.map((gov) {
            return DropdownMenuItem(
              value: gov,
              child: Text(gov.getName(widget.isRtl ? 'ar' : 'en')),
            );
          }).toList(),
          onChanged: (value) => setState(() => _selectedGovernorate = value),
        );
      },
    );
  }

  Widget _buildAddressField(ThemeData theme) => TextField(
        controller: _addressController,
        maxLines: 3,
        decoration: InputDecoration(
          labelText: widget.isRtl ? 'العنوان التفصيلي' : 'Detailed Address',
          hintText: widget.isRtl
              ? 'الشارع، المبنى، الشقة...'
              : 'Street, Building, Apartment...',
          prefixIcon: const Icon(Icons.home_outlined),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

  Widget _buildDefaultCheckbox() => CheckboxListTile(
        value: _isDefault,
        onChanged: (value) => setState(() => _isDefault = value ?? false),
        title: Text(
            widget.isRtl ? 'تعيين كعنوان افتراضي' : 'Set as default address'),
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: EdgeInsets.zero,
      );

  Widget _buildSaveButton(ThemeData theme) => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _saveAddress,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : Text(
                  widget.isRtl ? 'حفظ' : 'Save',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
        ),
      );

  Future<void> _saveAddress() async {
    if (_titleController.text.trim().isEmpty) {
      _showError(widget.isRtl
          ? 'يرجى إدخال اسم العنوان'
          : 'Please enter address title');
      return;
    }
    if (_selectedGovernorate == null) {
      _showError(
          widget.isRtl ? 'يرجى اختيار المحافظة' : 'Please select governorate');
      return;
    }
    if (_addressController.text.trim().isEmpty) {
      _showError(widget.isRtl
          ? 'يرجى إدخال العنوان التفصيلي'
          : 'Please enter detailed address');
      return;
    }

    setState(() => _isLoading = true);

    final detailedAddress = _addressController.text.trim();
    final newAddress = UserAddress.create(
      governorateId: _selectedGovernorate!.id,
      detailedAddress: detailedAddress,
      title: _titleController.text.trim(),
      isDefault: _isDefault,
    );

    bool success;
    if (widget.address != null) {
      final updatedAddress = UserAddress(
        id: '${_selectedGovernorate!.id}:$detailedAddress',
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

  void _showError(String message) {
    Tost.showCustomToast(context, message, backgroundColor: Colors.red);
  }
}
