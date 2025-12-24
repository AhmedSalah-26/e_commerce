import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../categories/domain/entities/category_entity.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../data/models/coupon_model.dart';
import '../../domain/entities/coupon_entity.dart';
import '../cubit/coupon_cubit.dart';
import '../cubit/coupon_state.dart';
import '../widgets/coupon_form/coupon_code_field.dart';
import '../widgets/coupon_form/coupon_names_fields.dart';
import '../widgets/coupon_form/discount_type_selector.dart';
import '../widgets/coupon_form/discount_value_fields.dart';
import '../widgets/coupon_form/coupon_limits_fields.dart';
import '../widgets/coupon_form/coupon_dates_fields.dart';
import '../widgets/coupon_form/coupon_scope_selector.dart';
import '../widgets/coupon_form/product_selection_section.dart';
import '../widgets/coupon_form/category_selection_section.dart';
import '../widgets/coupon_form/product_selection_dialog.dart';
import '../widgets/coupon_form/category_selection_dialog.dart';
import '../widgets/coupon_form/coupon_active_switch.dart';
import '../widgets/coupon_form/coupon_form_actions.dart';

class CouponFormPage extends StatefulWidget {
  final CouponEntity? coupon;
  final String storeId;
  final List<ProductEntity> storeProducts;
  final List<CategoryEntity> categories;

  const CouponFormPage({
    super.key,
    this.coupon,
    required this.storeId,
    required this.storeProducts,
    required this.categories,
  });

  @override
  State<CouponFormPage> createState() => _CouponFormPageState();
}

class _CouponFormPageState extends State<CouponFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _codeController;
  late final TextEditingController _nameArController;
  late final TextEditingController _nameEnController;
  late final TextEditingController _discountValueController;
  late final TextEditingController _maxDiscountController;
  late final TextEditingController _minOrderController;
  late final TextEditingController _usageLimitController;

  String _discountType = 'percentage';
  String _scope = 'all';
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _isActive = true;
  List<String> _selectedProductIds = [];
  List<String> _selectedCategoryIds = [];

  bool get isEditing => widget.coupon != null;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    final c = widget.coupon;
    _codeController = TextEditingController(text: c?.code ?? '');
    _nameArController = TextEditingController(text: c?.nameAr ?? '');
    _nameEnController = TextEditingController(text: c?.nameEn ?? '');
    _discountValueController =
        TextEditingController(text: c?.discountValue.toString() ?? '');
    _maxDiscountController =
        TextEditingController(text: c?.maxDiscountAmount?.toString() ?? '');
    _minOrderController =
        TextEditingController(text: c?.minOrderAmount.toString() ?? '0');
    _usageLimitController =
        TextEditingController(text: c?.usageLimit?.toString() ?? '');

    if (c != null) {
      _discountType = c.discountType;
      _scope = c.scope;
      _startDate = c.startDate;
      _endDate = c.endDate;
      _isActive = c.isActive;
      _selectedProductIds = List.from(c.productIds);
      _selectedCategoryIds = List.from(c.categoryIds);
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameArController.dispose();
    _nameEnController.dispose();
    _discountValueController.dispose();
    _maxDiscountController.dispose();
    _minOrderController.dispose();
    _usageLimitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MerchantCouponsCubit, CouponState>(
      listenWhen: (previous, current) => current is CouponSaved,
      listener: (context, state) {
        if (state is CouponSaved && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _buildBody(),
        bottomNavigationBar: CouponFormActions(onSave: _save),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColours.brownLight,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        isEditing ? 'edit_coupon'.tr() : 'add_coupon'.tr(),
        style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      centerTitle: true,
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CouponCodeField(controller: _codeController, isEditing: isEditing),
            const SizedBox(height: 16),
            CouponNamesFields(
              nameArController: _nameArController,
              nameEnController: _nameEnController,
            ),
            const SizedBox(height: 16),
            DiscountTypeSelector(
              selectedType: _discountType,
              onChanged: (type) => setState(() => _discountType = type),
            ),
            const SizedBox(height: 16),
            DiscountValueFields(
              discountValueController: _discountValueController,
              maxDiscountController: _maxDiscountController,
              discountType: _discountType,
            ),
            const SizedBox(height: 16),
            CouponLimitsFields(
              minOrderController: _minOrderController,
              usageLimitController: _usageLimitController,
            ),
            const SizedBox(height: 16),
            CouponDatesFields(
              startDate: _startDate,
              endDate: _endDate,
              onStartDateChanged: (d) => setState(() => _startDate = d),
              onEndDateChanged: (d) => setState(() => _endDate = d),
            ),
            const SizedBox(height: 16),
            CouponScopeSelector(
              selectedScope: _scope,
              onChanged: (scope) => setState(() => _scope = scope),
            ),
            if (_scope == 'products') ...[
              const SizedBox(height: 16),
              ProductSelectionSection(
                selectedProductIds: _selectedProductIds,
                storeProducts: widget.storeProducts,
                onSelectProducts: _showProductSelectionDialog,
                onRemoveProduct: (id) =>
                    setState(() => _selectedProductIds.remove(id)),
              ),
            ],
            if (_scope == 'categories') ...[
              const SizedBox(height: 16),
              CategorySelectionSection(
                selectedCategoryIds: _selectedCategoryIds,
                categories: widget.categories,
                onSelectCategories: _showCategorySelectionDialog,
                onRemoveCategory: (id) =>
                    setState(() => _selectedCategoryIds.remove(id)),
              ),
            ],
            const SizedBox(height: 16),
            CouponActiveSwitch(
              isActive: _isActive,
              onChanged: (v) => setState(() => _isActive = v),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    if (_scope == 'products' && _selectedProductIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('no_products_selected'.tr())),
      );
      return;
    }

    if (_scope == 'categories' && _selectedCategoryIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('no_categories_selected'.tr())),
      );
      return;
    }

    final coupon = CouponModel(
      id: widget.coupon?.id ?? '',
      code: _codeController.text.trim().toUpperCase(),
      nameAr: _nameArController.text.trim(),
      nameEn: _nameEnController.text.trim(),
      descriptionAr: null,
      descriptionEn: null,
      discountType: _discountType,
      discountValue: double.parse(_discountValueController.text),
      maxDiscountAmount: _maxDiscountController.text.isEmpty
          ? null
          : double.parse(_maxDiscountController.text),
      minOrderAmount: double.tryParse(_minOrderController.text) ?? 0,
      usageLimit: _usageLimitController.text.isEmpty
          ? null
          : int.parse(_usageLimitController.text),
      usageLimitPerUser: 1,
      startDate: _startDate,
      endDate: _endDate,
      scope: _scope,
      isActive: _isActive,
      storeId: widget.storeId,
      createdAt: widget.coupon?.createdAt ?? DateTime.now(),
      productIds: _scope == 'products' ? _selectedProductIds : [],
      categoryIds: _scope == 'categories' ? _selectedCategoryIds : [],
    );

    final cubit = context.read<MerchantCouponsCubit>();
    final productIds = _scope == 'products' ? _selectedProductIds : null;
    final categoryIds = _scope == 'categories' ? _selectedCategoryIds : null;

    if (isEditing) {
      cubit.updateCoupon(coupon, widget.storeId,
          productIds: productIds, categoryIds: categoryIds);
    } else {
      cubit.createCoupon(coupon, widget.storeId,
          productIds: productIds, categoryIds: categoryIds);
    }
  }

  void _showProductSelectionDialog() {
    showDialog(
      context: context,
      builder: (ctx) => ProductSelectionDialog(
        products: widget.storeProducts,
        selectedIds: _selectedProductIds,
        onConfirm: (ids) => setState(() => _selectedProductIds = ids),
      ),
    );
  }

  void _showCategorySelectionDialog() {
    showDialog(
      context: context,
      builder: (ctx) => CategorySelectionDialog(
        categories: widget.categories,
        selectedIds: _selectedCategoryIds,
        onConfirm: (ids) => setState(() => _selectedCategoryIds = ids),
      ),
    );
  }
}
