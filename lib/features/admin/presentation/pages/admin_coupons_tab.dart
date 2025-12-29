import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/shared_widgets/network_error_widget.dart';
import '../../../../core/utils/error_helper.dart';
import '../../../coupons/data/datasources/coupon_remote_datasource.dart';
import '../../../coupons/domain/entities/coupon_entity.dart';
import '../../../coupons/presentation/cubit/coupon_cubit.dart';
import '../../../coupons/presentation/cubit/coupon_state.dart';
import '../../../coupons/presentation/widgets/coupon_list/coupons_list_view.dart';
import '../../../coupons/presentation/pages/global_coupon_form_page.dart';

class AdminCouponsTab extends StatelessWidget {
  final bool isRtl;
  const AdminCouponsTab({super.key, required this.isRtl});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          GlobalCouponsCubit(sl<CouponRemoteDatasource>())..loadGlobalCoupons(),
      child: _AdminCouponsContent(isRtl: isRtl),
    );
  }
}

class _AdminCouponsContent extends StatefulWidget {
  final bool isRtl;
  const _AdminCouponsContent({required this.isRtl});

  @override
  State<_AdminCouponsContent> createState() => _AdminCouponsContentState();
}

class _AdminCouponsContentState extends State<_AdminCouponsContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return BlocConsumer<GlobalCouponsCubit, CouponState>(
      listener: _handleStateChanges,
      builder: (context, state) {
        final coupons =
            state is MerchantCouponsLoaded ? state.coupons : <CouponEntity>[];
        final activeCoupons = coupons.where((c) => c.isActive).toList();
        final inactiveCoupons = coupons.where((c) => !c.isActive).toList();

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          floatingActionButton: FloatingActionButton(
            onPressed: () => _navigateToCouponForm(null),
            backgroundColor: theme.colorScheme.primary,
            child: const Icon(Icons.add, color: Colors.white),
          ),
          body: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(isMobile ? 12 : 16),
                child: Row(
                  children: [
                    Text(
                      widget.isRtl ? 'الكوبونات العامة' : 'Global Coupons',
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              _buildTabBar(activeCoupons.length, inactiveCoupons.length, theme),
              Expanded(
                  child: _buildTabContent(
                      state, activeCoupons, inactiveCoupons, theme)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabBar(int activeCount, int inactiveCount, ThemeData theme) {
    return Container(
      color: theme.colorScheme.surface,
      child: TabBar(
        controller: _tabController,
        labelColor: theme.colorScheme.primary,
        unselectedLabelColor:
            theme.colorScheme.onSurface.withValues(alpha: 0.6),
        indicatorColor: theme.colorScheme.primary,
        tabs: [
          Tab(text: '${widget.isRtl ? 'نشط' : 'Active'} ($activeCount)'),
          Tab(
              text:
                  '${widget.isRtl ? 'غير نشط' : 'Inactive'} ($inactiveCount)'),
        ],
      ),
    );
  }

  Widget _buildTabContent(CouponState state, List<CouponEntity> activeCoupons,
      List<CouponEntity> inactiveCoupons, ThemeData theme) {
    if (state is MerchantCouponsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is MerchantCouponsError) {
      return NetworkErrorWidget(
        message: ErrorHelper.getUserFriendlyMessage(state.message),
        onRetry: () => context.read<GlobalCouponsCubit>().loadGlobalCoupons(),
      );
    }

    if (state is MerchantCouponsLoaded && state.coupons.isEmpty) {
      return _buildEmptyState(theme);
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildCouponsList(activeCoupons, isActive: true, theme: theme),
        _buildCouponsList(inactiveCoupons, isActive: false, theme: theme),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_offer_outlined,
              size: 64,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(
            widget.isRtl ? 'لا توجد كوبونات' : 'No coupons yet',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _navigateToCouponForm(null),
            icon: const Icon(Icons.add),
            label: Text(widget.isRtl ? 'إضافة كوبون' : 'Add Coupon'),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponsList(List<CouponEntity> coupons,
      {required bool isActive, required ThemeData theme}) {
    if (coupons.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? Icons.local_offer_outlined : Icons.block,
              size: 64,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              isActive
                  ? (widget.isRtl
                      ? 'لا توجد كوبونات نشطة'
                      : 'No active coupons')
                  : (widget.isRtl
                      ? 'لا توجد كوبونات غير نشطة'
                      : 'No inactive coupons'),
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }

    return CouponsListView(
      coupons: coupons,
      storeId: '',
      isGlobal: true,
      onEdit: (coupon) => _navigateToCouponForm(coupon),
      onToggle: (coupon, value) => _toggleCouponStatus(coupon, value),
      onRefresh: () => context.read<GlobalCouponsCubit>().loadGlobalCoupons(),
    );
  }

  void _handleStateChanges(BuildContext context, CouponState state) {
    if (state is CouponSaved) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('coupon_saved'.tr())),
      );
    } else if (state is MerchantCouponsError &&
        state.message == 'DUPLICATE_CODE') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('duplicate_coupon_code'.tr()),
            backgroundColor: Colors.red),
      );
      context.read<GlobalCouponsCubit>().loadGlobalCoupons();
    }
  }

  void _navigateToCouponForm(CouponEntity? coupon) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<GlobalCouponsCubit>(),
          child: GlobalCouponFormPage(coupon: coupon),
        ),
      ),
    );
  }

  void _toggleCouponStatus(CouponEntity coupon, bool value) {
    context
        .read<GlobalCouponsCubit>()
        .toggleGlobalCouponStatus(coupon.id, value);
  }
}
