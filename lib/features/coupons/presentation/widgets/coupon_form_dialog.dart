import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/coupon_model.dart';
import '../../domain/entities/coupon_entity.dart';
import '../cubit/coupon_cubit.dart';
import '../cubit/coupon_state.dart';

class CouponFormDialog extends StatefulWidget {
  final CouponEntity? coupon;
  final String storeId;

  const CouponFormDialog({super.key, this.coupon, required this.storeId});

  @override
  State<CouponFormDialog> createState() => _CouponFormDialogState();
}

class _CouponFormDialogState extends State<CouponFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codeController;
  late final TextEditingController _nameArController;
  late final TextEditingController _nameEnController;
  late final TextEditingController _descArController;
  late final TextEditingController _descEnController;
  late final TextEditingController _discountValueController;
  late final TextEditingController _maxDiscountController;
  late final TextEditingController _minOrderController;
  late final TextEditingController _usageLimitController;
  late final TextEditingController _userLimitController;

  String _discountType = 'percentage';
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _isActive = true;

  bool get isEditing => widget.coupon != null;

  @override
  void initState() {
    super.initState();
    final c = widget.coupon;
    _codeController = TextEditingController(text: c?.code ?? '');
    _nameArController = TextEditingController(text: c?.nameAr ?? '');
    _nameEnController = TextEditingController(text: c?.nameEn ?? '');
    _descArController = TextEditingController(text: c?.descriptionAr ?? '');
    _descEnController = TextEditingController(text: c?.descriptionEn ?? '');
    _discountValueController =
        TextEditingController(text: c?.discountValue.toString() ?? '');
    _maxDiscountController =
        TextEditingController(text: c?.maxDiscountAmount?.toString() ?? '');
    _minOrderController =
        TextEditingController(text: c?.minOrderAmount.toString() ?? '0');
    _usageLimitController =
        TextEditingController(text: c?.usageLimit?.toString() ?? '');
    _userLimitController =
        TextEditingController(text: c?.usageLimitPerUser.toString() ?? '1');

    if (c != null) {
      _discountType = c.discountType;
      _startDate = c.startDate;
      _endDate = c.endDate;
      _isActive = c.isActive;
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameArController.dispose();
    _nameEnController.dispose();
    _descArController.dispose();
    _descEnController.dispose();
    _discountValueController.dispose();
    _maxDiscountController.dispose();
    _minOrderController.dispose();
    _usageLimitController.dispose();
    _userLimitController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final coupon = CouponModel(
      id: widget.coupon?.id ?? '',
      code: _codeController.text.trim().toUpperCase(),
      nameAr: _nameArController.text.trim(),
      nameEn: _nameEnController.text.trim(),
      descriptionAr: _descArController.text.trim().isEmpty
          ? null
          : _descArController.text.trim(),
      descriptionEn: _descEnController.text.trim().isEmpty
          ? null
          : _descEnController.text.trim(),
      discountType: _discountType,
      discountValue: double.parse(_discountValueController.text),
      maxDiscountAmount: _maxDiscountController.text.isEmpty
          ? null
          : double.parse(_maxDiscountController.text),
      minOrderAmount: double.tryParse(_minOrderController.text) ?? 0,
      usageLimit: _usageLimitController.text.isEmpty
          ? null
          : int.parse(_usageLimitController.text),
      usageLimitPerUser: int.tryParse(_userLimitController.text) ?? 1,
      startDate: _startDate,
      endDate: _endDate,
      isActive: _isActive,
      storeId: widget.storeId,
      createdAt: widget.coupon?.createdAt ?? DateTime.now(),
    );

    final cubit = context.read<MerchantCouponsCubit>();
    if (isEditing) {
      cubit.updateCoupon(coupon, widget.storeId);
    } else {
      cubit.createCoupon(coupon, widget.storeId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MerchantCouponsCubit, CouponState>(
      listener: (context, state) {
        if (state is CouponSaved) {
          Navigator.pop(context);
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: const BoxConstraints(maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColours.brownLight,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    Icon(
                      isEditing ? Icons.edit : Icons.add,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isEditing ? 'edit_coupon'.tr() : 'add_coupon'.tr(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Form
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Code
                        _buildTextField(
                          controller: _codeController,
                          label: 'coupon_code'.tr(),
                          hint: 'SAVE20',
                          enabled: !isEditing,
                          textCapitalization: TextCapitalization.characters,
                          validator: (v) =>
                              v?.isEmpty == true ? 'field_required'.tr() : null,
                        ),
                        const SizedBox(height: 16),

                        // Names
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _nameArController,
                                label: 'name_ar'.tr(),
                                validator: (v) => v?.isEmpty == true
                                    ? 'field_required'.tr()
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildTextField(
                                controller: _nameEnController,
                                label: 'name_en'.tr(),
                                validator: (v) => v?.isEmpty == true
                                    ? 'field_required'.tr()
                                    : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Discount Type
                        Text('discount_type'.tr(),
                            style:
                                const TextStyle(fontWeight: FontWeight.w500)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _DiscountTypeOption(
                                label: 'percentage'.tr(),
                                icon: Icons.percent,
                                isSelected: _discountType == 'percentage',
                                onTap: () => setState(
                                    () => _discountType = 'percentage'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _DiscountTypeOption(
                                label: 'fixed_amount'.tr(),
                                icon: Icons.attach_money,
                                isSelected: _discountType == 'fixed',
                                onTap: () =>
                                    setState(() => _discountType = 'fixed'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Discount Value & Max
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _discountValueController,
                                label: 'discount_value'.tr(),
                                keyboardType: TextInputType.number,
                                suffix: _discountType == 'percentage'
                                    ? '%'
                                    : 'currency'.tr(),
                                validator: (v) {
                                  if (v?.isEmpty == true) {
                                    return 'field_required'.tr();
                                  }
                                  final val = double.tryParse(v!);
                                  if (val == null || val <= 0) {
                                    return 'invalid_value'.tr();
                                  }
                                  if (_discountType == 'percentage' &&
                                      val > 100) {
                                    return 'max_100'.tr();
                                  }
                                  return null;
                                },
                              ),
                            ),
                            if (_discountType == 'percentage') ...[
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildTextField(
                                  controller: _maxDiscountController,
                                  label: 'max_discount'.tr(),
                                  keyboardType: TextInputType.number,
                                  suffix: 'currency'.tr(),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Min Order & Limits
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _minOrderController,
                                label: 'min_order'.tr(),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildTextField(
                                controller: _usageLimitController,
                                label: 'usage_limit'.tr(),
                                hint: 'unlimited'.tr(),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Dates
                        Row(
                          children: [
                            Expanded(
                              child: _DateField(
                                label: 'start_date'.tr(),
                                date: _startDate,
                                onChanged: (d) =>
                                    setState(() => _startDate = d),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _DateField(
                                label: 'end_date'.tr(),
                                date: _endDate,
                                isOptional: true,
                                onChanged: (d) => setState(() => _endDate = d),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Active Switch
                        SwitchListTile(
                          title: Text('is_active'.tr()),
                          value: _isActive,
                          onChanged: (v) => setState(() => _isActive = v),
                          activeTrackColor:
                              AppColours.brownMedium.withValues(alpha: 0.5),
                          thumbColor: WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.selected)) {
                              return AppColours.brownMedium;
                            }
                            return null;
                          }),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Actions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey.shade200)),
                ),
                child: BlocBuilder<MerchantCouponsCubit, CouponState>(
                  builder: (context, state) {
                    final isLoading = state is CouponSaving;
                    return Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed:
                                isLoading ? null : () => Navigator.pop(context),
                            child: Text('cancel'.tr()),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _save,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColours.brownMedium,
                              foregroundColor: Colors.white,
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white),
                                  )
                                : Text('save'.tr()),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    String? suffix,
    bool enabled = true,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixText: suffix,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }
}

class _DiscountTypeOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _DiscountTypeOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColours.brownLight.withValues(alpha: 0.2)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColours.brownMedium : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 18,
                color: isSelected ? AppColours.brownMedium : Colors.grey),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color:
                    isSelected ? AppColours.brownMedium : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final bool isOptional;
  final ValueChanged<DateTime> onChanged;

  const _DateField({
    required this.label,
    required this.date,
    this.isOptional = false,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
        );
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                date != null
                    ? DateFormat('yyyy/MM/dd').format(date!)
                    : (isOptional ? 'optional'.tr() : 'select_date'.tr()),
                style: TextStyle(
                  color: date != null ? Colors.black : Colors.grey,
                ),
              ),
            ),
            const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
