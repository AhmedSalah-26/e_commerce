import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/shared_widgets/network_error_widget.dart';
import '../../../../core/utils/error_helper.dart';
import '../../data/datasources/coupon_remote_datasource.dart';
import '../../domain/entities/coupon_entity.dart';
import '../cubit/coupon_cubit.dart';
import '../cubit/coupon_state.dart';
import '../widgets/coupon_list/coupons_empty_state.dart';
import '../widgets/coupon_list/coupons_list_view.dart';
import 'global_coupon_form_page.dart';

class GlobalCouponsPage extends StatelessWidget {
  const GlobalCouponsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isRtl = context.locale.languageCode == 'ar';

    return BlocProvider(
      create: (_) =>
          GlobalCouponsCubit(sl<CouponRemoteDatasource>())..loadGlobalCoupons(),
      child: Directionality(
        textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
        child: const _GlobalCouponsContent(),
      ),
    );
  }
}

class _GlobalCouponsContent extends StatefulWidget {
  const _GlobalCouponsContent();

  @override
  State<_GlobalCouponsContent> createState() => _GlobalCouponsContentState();
}

class _GlobalCouponsContentState extends State<_GlobalCouponsContent>
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
    final isRtl = context.locale.languageCode == 'ar';

    return BlocConsumer<GlobalCouponsCubit, CouponState>(
      listener: _handleStateChanges,
      builder: (context, state) {
        final coupons =
            state is MerchantCouponsLoaded ? state.coupons : <CouponEntity>[];
        final activeCoupons = coupons.where((c) => c.isActive).toList();
        final inactiveCoupons = coupons.where((c) => !c.isActive).toList();

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: _buildAppBar(isRtl, theme),
          floatingActionButton: _buildFab(theme),
          body: Column(
            children: [
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

  PreferredSizeWidget _buildAppBar(bool isRtl, ThemeData theme) {
    return AppBar(
      backgroundColor: theme.colorScheme.surface,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        isRtl ? 'الكوبونات العامة' : 'Global Coupons',
        style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600, color: theme.colorScheme.primary),
      ),
      centerTitle: true,
    );
  }

  Widget _buildFab(ThemeData theme) {
    return FloatingActionButton(
      onPressed: () => _navigateToCouponForm(null),
      backgroundColor: theme.colorScheme.primary,
      child: const Icon(Icons.add, color: Colors.white),
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
          Tab(text: '${'active_coupons'.tr()} ($activeCount)'),
          Tab(text: '${'inactive_coupons'.tr()} ($inactiveCount)'),
        ],
      ),
    );
  }

  Widget _buildTabContent(CouponState state, List<CouponEntity> activeCoupons,
      List<CouponEntity> inactiveCoupons, ThemeData theme) {
    if (state is MerchantCouponsLoading)
      return const Center(child: CircularProgressIndicator());

    if (state is MerchantCouponsError)
      return _buildErrorView(state.message, theme);

    if (state is MerchantCouponsLoaded && state.coupons.isEmpty) {
      return CouponsEmptyState(onAdd: () => _navigateToCouponForm(null));
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildCouponsList(activeCoupons, isActive: true, theme: theme),
        _buildCouponsList(inactiveCoupons, isActive: false, theme: theme),
      ],
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
              isActive ? 'no_active_coupons'.tr() : 'no_inactive_coupons'.tr(),
              style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('coupon_saved'.tr())));
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

  Widget _buildErrorView(String message, ThemeData theme) {
    return NetworkErrorWidget(
      message: ErrorHelper.getUserFriendlyMessage(message),
      onRetry: () => context.read<GlobalCouponsCubit>().loadGlobalCoupons(),
    );
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
