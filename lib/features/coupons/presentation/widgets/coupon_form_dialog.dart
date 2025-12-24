import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../data/models/coupon_model.dart';
import '../../domain/entities/coupon_entity.dart';
import '../cubit/coupon_cubit.dart';
import '../cubit/coupon_state.dart';

class CouponFormDialog extends StatefulWidget {
  final CouponEntity? coupon;
  final String storeId;
  final List<ProductEntity> storeProducts;

  const CouponFormDialog({
    super.key,
    this.coupon,
    required this.storeId,
    required this.storeProducts,
  });

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
  String _scope = 'all'; // 'all' or 'products'
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _isActive = true;
  List<String> _selectedProductIds = [];

  bool get isEditing => widget.coupon != null;

  /// Generate random unique coupon code
  String _generateRandomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch % 10000;
    final randomPart =
        List.generate(4, (_) => chars[random.nextInt(chars.length)]).join();
    return '$randomPart$timestamp';
  }

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
      _scope = c.scope;
      _startDate = c.startDate;
      _endDate = c.endDate;
      _isActive = c.isActive;
      _selectedProductIds = List.from(c.productIds);
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

    // Validate product selection if scope is 'products'
    if (_scope == 'products' && _selectedProductIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('no_products_selected'.tr())),
      );
      return;
    }

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
      scope: _scope,
      isActive: _isActive,
      storeId: widget.storeId,
      createdAt: widget.coupon?.createdAt ?? DateTime.now(),
      productIds: _scope == 'products' ? _selectedProductIds : [],
    );

    final cubit = context.read<MerchantCouponsCubit>();
    final productIds = _scope == 'products' ? _selectedProductIds : null;

    if (isEditing) {
      cubit.updateCoupon(coupon, widget.storeId, productIds: productIds);
    } else {
      cubit.createCoupon(coupon, widget.storeId, productIds: productIds);
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
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _codeController,
                                label: 'coupon_code'.tr(),
                                hint: 'SAVE20',
                                enabled: !isEditing,
                                textCapitalization:
                                    TextCapitalization.characters,
                                validator: (v) => v?.isEmpty == true
                                    ? 'field_required'.tr()
                                    : null,
                              ),
                            ),
                            if (!isEditing) ...[
                              const SizedBox(width: 8),
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: IconButton.filled(
                                  onPressed: () {
                                    _codeController.text =
                                        _generateRandomCode();
                                  },
                                  icon:
                                      const Icon(Icons.auto_awesome, size: 20),
                                  style: IconButton.styleFrom(
                                    backgroundColor: AppColours.brownMedium,
                                    foregroundColor: Colors.white,
                                  ),
                                  tooltip: 'generate_code'.tr(),
                                ),
                              ),
                            ],
                          ],
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
                                    : 'egp'.tr(),
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
                                  suffix: 'egp'.tr(),
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

                        // Coupon Scope
                        Text('coupon_scope'.tr(),
                            style:
                                const TextStyle(fontWeight: FontWeight.w500)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _DiscountTypeOption(
                                label: 'all_store_products'.tr(),
                                icon: Icons.store,
                                isSelected: _scope == 'all',
                                onTap: () => setState(() => _scope = 'all'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _DiscountTypeOption(
                                label: 'specific_products'.tr(),
                                icon: Icons.inventory_2,
                                isSelected: _scope == 'products',
                                onTap: () =>
                                    setState(() => _scope = 'products'),
                              ),
                            ),
                          ],
                        ),

                        // Product Selection (only if scope is 'products')
                        if (_scope == 'products') ...[
                          const SizedBox(height: 16),
                          _buildProductSelection(),
                        ],

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

  Widget _buildProductSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'selected_products'.tr(),
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            TextButton.icon(
              onPressed: _showProductSelectionDialog,
              icon: const Icon(Icons.add, size: 18),
              label: Text('select_products'.tr()),
              style: TextButton.styleFrom(
                foregroundColor: AppColours.brownMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_selectedProductIds.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, color: Colors.grey.shade600, size: 18),
                const SizedBox(width: 8),
                Text(
                  'no_products_selected'.tr(),
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          )
        else
          Container(
            constraints: const BoxConstraints(maxHeight: 150),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _selectedProductIds.length,
              itemBuilder: (context, index) {
                final productId = _selectedProductIds[index];
                final product = widget.storeProducts.firstWhere(
                  (p) => p.id == productId,
                  orElse: () => widget.storeProducts.first,
                );
                return ListTile(
                  dense: true,
                  leading: product.images.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(
                            product.images.first,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 40,
                              height: 40,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.image, size: 20),
                            ),
                          ),
                        )
                      : Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(Icons.inventory_2, size: 20),
                        ),
                  title: Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () {
                      setState(() {
                        _selectedProductIds.remove(productId);
                      });
                    },
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  void _showProductSelectionDialog() {
    showDialog(
      context: context,
      builder: (ctx) => _ProductSelectionDialog(
        products: widget.storeProducts,
        selectedIds: _selectedProductIds,
        onConfirm: (ids) {
          setState(() {
            _selectedProductIds = ids;
          });
        },
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

class _ProductSelectionDialog extends StatefulWidget {
  final List<ProductEntity> products;
  final List<String> selectedIds;
  final ValueChanged<List<String>> onConfirm;

  const _ProductSelectionDialog({
    required this.products,
    required this.selectedIds,
    required this.onConfirm,
  });

  @override
  State<_ProductSelectionDialog> createState() =>
      _ProductSelectionDialogState();
}

class _ProductSelectionDialogState extends State<_ProductSelectionDialog> {
  late List<String> _tempSelectedIds;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tempSelectedIds = List.from(widget.selectedIds);
  }

  List<ProductEntity> get _filteredProducts {
    if (_searchQuery.isEmpty) return widget.products;
    return widget.products
        .where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxHeight: 500),
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
                  const Icon(Icons.inventory_2, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'select_products'.tr(),
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

            // Search
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'search_products'.tr(),
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ),

            // Products List
            Flexible(
              child: _filteredProducts.isEmpty
                  ? Center(
                      child: Text(
                        'no_products'.tr(),
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = _filteredProducts[index];
                        final isSelected =
                            _tempSelectedIds.contains(product.id);
                        return CheckboxListTile(
                          value: isSelected,
                          onChanged: (v) {
                            setState(() {
                              if (v == true) {
                                _tempSelectedIds.add(product.id);
                              } else {
                                _tempSelectedIds.remove(product.id);
                              }
                            });
                          },
                          secondary: product.images.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Image.network(
                                    product.images.first,
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 40,
                                      height: 40,
                                      color: Colors.grey.shade200,
                                      child: const Icon(Icons.image, size: 20),
                                    ),
                                  ),
                                )
                              : Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child:
                                      const Icon(Icons.inventory_2, size: 20),
                                ),
                          title: Text(
                            product.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            '${product.price} ${'egp'.tr()}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                          activeColor: AppColours.brownMedium,
                        );
                      },
                    ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  Text(
                    '${_tempSelectedIds.length} ${'selected'.tr()}',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('cancel'.tr()),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      widget.onConfirm(_tempSelectedIds);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColours.brownMedium,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('confirm'.tr()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
