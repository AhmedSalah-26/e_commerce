import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../../products/data/models/product_model.dart';
import '../../domain/entities/coupon_entity.dart';
import '../cubit/coupon_cubit.dart';
import '../cubit/coupon_state.dart';
import '../widgets/coupon_form_dialog.dart';

class MerchantCouponsPage extends StatefulWidget {
  const MerchantCouponsPage({super.key});

  @override
  State<MerchantCouponsPage> createState() => _MerchantCouponsPageState();
}

class _MerchantCouponsPageState extends State<MerchantCouponsPage> {
  String? _storeId;
  bool _isLoading = true;
  List<ProductEntity> _storeProducts = [];

  @override
  void initState() {
    super.initState();
    _loadStoreData();
  }

  Future<void> _loadStoreData() async {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      // Load store ID
      final storeResponse = await Supabase.instance.client
          .from('stores')
          .select('id')
          .eq('merchant_id', authState.user.id)
          .maybeSingle();

      final storeId = storeResponse?['id'] as String?;

      if (storeId != null) {
        // Load store products
        final productsResponse = await Supabase.instance.client
            .from('products')
            .select('*, stores!inner(merchant_id)')
            .eq('stores.merchant_id', authState.user.id)
            .eq('is_active', true)
            .order('created_at', ascending: false);

        final products = (productsResponse as List)
            .map((json) => ProductModel.fromJson(json))
            .toList();

        if (mounted) {
          setState(() {
            _storeId = storeId;
            _storeProducts = products;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = context.locale.languageCode == 'ar';

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('coupons'.tr())),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_storeId == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('coupons'.tr()),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.store_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                isRtl
                    ? 'يرجى إعداد معلومات المتجر أولاً'
                    : 'Please set up store info first',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return BlocProvider(
      create: (_) => sl<MerchantCouponsCubit>()..loadCoupons(_storeId!),
      child: Directionality(
        textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
        child: _MerchantCouponsView(
          storeId: _storeId!,
          isRtl: isRtl,
          storeProducts: _storeProducts,
        ),
      ),
    );
  }
}

class _MerchantCouponsView extends StatelessWidget {
  final String storeId;
  final bool isRtl;
  final List<ProductEntity> storeProducts;

  const _MerchantCouponsView({
    required this.storeId,
    required this.isRtl,
    required this.storeProducts,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColours.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColours.brownMedium),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'coupons'.tr(),
          style: AppTextStyle.semiBold_20_dark_brown.copyWith(
            color: AppColours.brownMedium,
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCouponForm(context, null),
        backgroundColor: AppColours.brownMedium,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: BlocConsumer<MerchantCouponsCubit, CouponState>(
        listener: (context, state) {
          if (state is CouponSaved) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('coupon_saved'.tr())),
            );
          } else if (state is CouponDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('coupon_deleted'.tr())),
            );
          } else if (state is MerchantCouponsError) {
            // Handle duplicate code error
            if (state.message == 'DUPLICATE_CODE') {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('duplicate_coupon_code'.tr()),
                  backgroundColor: Colors.red,
                ),
              );
              // Reload coupons to restore state
              context.read<MerchantCouponsCubit>().loadCoupons(storeId);
            }
          }
        },
        builder: (context, state) {
          if (state is MerchantCouponsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is MerchantCouponsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context
                        .read<MerchantCouponsCubit>()
                        .loadCoupons(storeId),
                    child: Text('retry'.tr()),
                  ),
                ],
              ),
            );
          }

          if (state is MerchantCouponsLoaded) {
            if (state.coupons.isEmpty) {
              return _EmptyState(onAdd: () => _showCouponForm(context, null));
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<MerchantCouponsCubit>().loadCoupons(storeId);
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.coupons.length,
                itemBuilder: (context, index) {
                  final coupon = state.coupons[index];
                  return _CouponCard(
                    coupon: coupon,
                    isRtl: isRtl,
                    onEdit: () => _showCouponForm(context, coupon),
                    onDelete: () => _confirmDelete(context, coupon),
                    onToggle: (value) {
                      context.read<MerchantCouponsCubit>().toggleCouponStatus(
                            coupon.id,
                            value,
                            storeId,
                          );
                    },
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showCouponForm(BuildContext context, CouponEntity? coupon) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<MerchantCouponsCubit>(),
        child: CouponFormDialog(
          coupon: coupon,
          storeId: storeId,
          storeProducts: storeProducts,
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, CouponEntity coupon) {
    final isRtl = context.locale.languageCode == 'ar';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('delete_coupon'.tr()),
        content: Text(isRtl
            ? 'هل أنت متأكد من حذف الكوبون "${coupon.code}"؟'
            : 'Are you sure you want to delete coupon "${coupon.code}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context
                  .read<MerchantCouponsCubit>()
                  .deleteCoupon(coupon.id, storeId);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('delete'.tr()),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_offer_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'no_coupons'.tr(),
            style: const TextStyle(
              fontSize: 18,
              color: AppColours.greyDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'no_coupons_desc'.tr(),
            style: const TextStyle(color: AppColours.greyMedium),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: Text('add_coupon'.tr()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColours.brownMedium,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _CouponCard extends StatelessWidget {
  final CouponEntity coupon;
  final bool isRtl;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<bool> onToggle;

  const _CouponCard({
    required this.coupon,
    required this.isRtl,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final locale = context.locale.languageCode;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColours.brownLight.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    coupon.code,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColours.brownDark,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (coupon.isProductSpecific)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inventory_2,
                            size: 14, color: Colors.blue.shade700),
                        const SizedBox(width: 4),
                        Text(
                          '${coupon.productIds.length}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                const Spacer(),
                Switch(
                  value: coupon.isActive,
                  onChanged: onToggle,
                  activeThumbColor: AppColours.brownMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              coupon.getName(locale),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColours.brownDark,
              ),
            ),
            if (coupon.getDescription(locale) != null) ...[
              const SizedBox(height: 4),
              Text(
                coupon.getDescription(locale)!,
                style: const TextStyle(color: AppColours.greyMedium),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                _InfoChip(
                  icon: Icons.percent,
                  label: coupon.isPercentage
                      ? '${coupon.discountValue.toInt()}%'
                      : '${coupon.discountValue.toStringAsFixed(0)} ${'egp'.tr()}',
                ),
                const SizedBox(width: 8),
                if (coupon.minOrderAmount > 0)
                  _InfoChip(
                    icon: Icons.shopping_cart_outlined,
                    label:
                        '${'min'.tr()} ${coupon.minOrderAmount.toStringAsFixed(0)}',
                  ),
                const SizedBox(width: 8),
                _InfoChip(
                  icon: Icons.people_outline,
                  label: '${coupon.usageCount}/${coupon.usageLimit ?? '∞'}',
                ),
              ],
            ),
            if (coupon.endDate != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    coupon.isExpired ? Icons.error_outline : Icons.schedule,
                    size: 16,
                    color:
                        coupon.isExpired ? Colors.red : AppColours.greyMedium,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    coupon.isExpired
                        ? 'expired'.tr()
                        : '${'ends'.tr()}: ${DateFormat('yyyy/MM/dd').format(coupon.endDate!)}',
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          coupon.isExpired ? Colors.red : AppColours.greyMedium,
                    ),
                  ),
                ],
              ),
            ],
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: Text('edit'.tr()),
                  style: TextButton.styleFrom(
                      foregroundColor: AppColours.brownMedium),
                ),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: Text('delete'.tr()),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColours.greyLighter,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColours.greyDark),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColours.greyDark),
          ),
        ],
      ),
    );
  }
}
