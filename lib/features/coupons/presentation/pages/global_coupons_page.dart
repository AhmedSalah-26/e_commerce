import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
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
    final isRtl = context.locale.languageCode == 'ar';

    return BlocConsumer<GlobalCouponsCubit, CouponState>(
      listener: _handleStateChanges,
      builder: (context, state) {
        final coupons =
            state is MerchantCouponsLoaded ? state.coupons : <CouponEntity>[];
        final activeCoupons = coupons.where((c) => c.isActive).toList();
        final inactiveCoupons = coupons.where((c) => !c.isActive).toList();

        return Scaffold(
          backgroundColor: AppColours.white,
          appBar: _buildAppBar(isRtl),
          floatingActionButton: _buildFab(),
          body: Column(
            children: [
              _buildTabBar(activeCoupons.length, inactiveCoupons.length),
              Expanded(
                child: _buildTabContent(state, activeCoupons, inactiveCoupons),
              ),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(bool isRtl) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColours.brownMedium),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        isRtl ? 'الكوبونات العامة' : 'Global Coupons',
        style: AppTextStyle.semiBold_20_dark_brown
            .copyWith(color: AppColours.brownMedium),
      ),
      centerTitle: true,
    );
  }

  Widget _buildFab() {
    return FloatingActionButton(
      onPressed: () => _navigateToCouponForm(null),
      backgroundColor: AppColours.brownMedium,
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  Widget _buildTabBar(int activeCount, int inactiveCount) {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: AppColours.brownMedium,
        unselectedLabelColor: AppColours.greyMedium,
        indicatorColor: AppColours.brownMedium,
        tabs: [
          Tab(text: '${'active_coupons'.tr()} ($activeCount)'),
          Tab(text: '${'inactive_coupons'.tr()} ($inactiveCount)'),
        ],
      ),
    );
  }

  Widget _buildTabContent(CouponState state, List<CouponEntity> activeCoupons,
      List<CouponEntity> inactiveCoupons) {
    if (state is MerchantCouponsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is MerchantCouponsError) {
      return _buildErrorView(state.message);
    }

    if (state is MerchantCouponsLoaded && state.coupons.isEmpty) {
      return CouponsEmptyState(onAdd: () => _navigateToCouponForm(null));
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildCouponsList(activeCoupons, isActive: true),
        _buildCouponsList(inactiveCoupons, isActive: false),
      ],
    );
  }

  Widget _buildCouponsList(List<CouponEntity> coupons,
      {required bool isActive}) {
    if (coupons.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? Icons.local_offer_outlined : Icons.block,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              isActive ? 'no_active_coupons'.tr() : 'no_inactive_coupons'.tr(),
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return CouponsListView(
      coupons: coupons,
      storeId: '', // Global coupons have no store
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
          backgroundColor: Colors.red,
        ),
      );
      context.read<GlobalCouponsCubit>().loadGlobalCoupons();
    }
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(message),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () =>
                context.read<GlobalCouponsCubit>().loadGlobalCoupons(),
            child: Text('retry'.tr()),
          ),
        ],
      ),
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
