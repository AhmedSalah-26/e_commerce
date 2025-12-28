import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import '../widgets/coupon_form/coupon_active_switch.dart';

/// صفحة إنشاء/تعديل كوبون عام (للأدمن)
class GlobalCouponFormPage extends StatefulWidget {
  final CouponEntity? coupon;

  const GlobalCouponFormPage({super.key, this.coupon});

  @override
  State<GlobalCouponFormPage> createState() => _GlobalCouponFormPageState();
}

class _GlobalCouponFormPageState extends State<GlobalCouponFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _codeController;
  late final TextEditingController _nameArController;
  late final TextEditingController _nameEnController;
  late final TextEditingController _discountValueController;
  late final TextEditingController _maxDiscountController;
  late final TextEditingController _minOrderController;
  late final TextEditingController _usageLimitController;

  String _discountType = 'percentage';
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _isActive = true;

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
    _discountValueController.dispose();
    _maxDiscountController.dispose();
    _minOrderController.dispose();
    _usageLimitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = context.locale.languageCode == 'ar';
    final theme = Theme.of(context);

    return BlocConsumer<GlobalCouponsCubit, CouponState>(
      listenWhen: (previous, current) => current is CouponSaved,
      listener: (context, state) {
        if (state is CouponSaved && context.mounted) {
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
        final isLoading = state is CouponSaving;
        return Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: _buildAppBar(isRtl, theme),
          body: _buildBody(),
          bottomNavigationBar: _buildFormActions(isLoading, theme),
        );
      },
    );
  }

  Widget _buildFormActions(bool isLoading, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
            top: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.3))),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: Text('cancel'.tr()),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: isLoading ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
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
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isRtl, ThemeData theme) {
    return AppBar(
      backgroundColor: theme.colorScheme.primary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        isEditing
            ? (isRtl ? 'تعديل كوبون عام' : 'Edit Global Coupon')
            : (isRtl ? 'إضافة كوبون عام' : 'Add Global Coupon'),
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildBody() {
    final isRtl = context.locale.languageCode == 'ar';

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info banner
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          isRtl
                              ? 'الكوبونات العامة تعمل على جميع المنتجات من جميع التجار'
                              : 'Global coupons work on all products from all merchants',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                CouponCodeField(
                    controller: _codeController, isEditing: isEditing),
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
                CouponActiveSwitch(
                  isActive: _isActive,
                  onChanged: (v) => setState(() => _isActive = v),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

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
      scope: 'all', // Global coupons always apply to all
      isActive: _isActive,
      storeId: null, // NULL = global coupon
      createdAt: widget.coupon?.createdAt ?? DateTime.now(),
      productIds: [],
      categoryIds: [],
    );

    final cubit = context.read<GlobalCouponsCubit>();

    if (isEditing) {
      cubit.updateGlobalCoupon(coupon);
    } else {
      cubit.createGlobalCoupon(coupon);
    }
  }
}
