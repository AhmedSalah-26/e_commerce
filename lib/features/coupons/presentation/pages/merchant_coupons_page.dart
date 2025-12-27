import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/shared_widgets/network_error_widget.dart';
import '../../../../core/utils/error_helper.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../categories/domain/entities/category_entity.dart';
import '../../../categories/data/models/category_model.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../../products/data/models/product_model.dart';
import '../../domain/entities/coupon_entity.dart';
import '../cubit/coupon_cubit.dart';
import '../cubit/coupon_state.dart';
import '../widgets/coupon_list/coupons_empty_state.dart';
import '../widgets/coupon_list/coupons_list_view.dart';
import 'coupon_form_page.dart';

class MerchantCouponsPage extends StatefulWidget {
  const MerchantCouponsPage({super.key});

  @override
  State<MerchantCouponsPage> createState() => _MerchantCouponsPageState();
}

class _MerchantCouponsPageState extends State<MerchantCouponsPage> {
  String? _storeId;
  bool _isLoading = true;
  List<ProductEntity> _storeProducts = [];
  List<CategoryEntity> _categories = [];

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

    final userId = authState.user.id;

    try {
      final storeResponse = await Supabase.instance.client
          .from('stores')
          .select('id')
          .eq('merchant_id', userId)
          .maybeSingle();

      final storeId = storeResponse?['id'] as String?;

      if (storeId != null) {
        final productsResponse = await Supabase.instance.client
            .from('products')
            .select()
            .eq('merchant_id', userId)
            .eq('is_active', true)
            .order('created_at', ascending: false);

        final products = (productsResponse as List)
            .map((json) => ProductModel.fromJson(json))
            .toList();

        final categoriesResponse = await Supabase.instance.client
            .from('categories')
            .select()
            .eq('is_active', true)
            .order('sort_order', ascending: true);

        final categories = (categoriesResponse as List)
            .map((json) => CategoryModel.fromJson(json))
            .toList();

        if (mounted) {
          setState(() {
            _storeId = storeId;
            _storeProducts = products;
            _categories = categories;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('❌ Error loading store data: $e');
      if (mounted) setState(() => _isLoading = false);
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
      return _buildNoStoreView(isRtl);
    }

    return BlocProvider(
      create: (_) => sl<MerchantCouponsCubit>()..loadCoupons(_storeId!),
      child: Directionality(
        textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
        child: _CouponsPageContent(
          storeId: _storeId!,
          storeProducts: _storeProducts,
          categories: _categories,
        ),
      ),
    );
  }

  Widget _buildNoStoreView(bool isRtl) {
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
}

class _CouponsPageContent extends StatefulWidget {
  final String storeId;
  final List<ProductEntity> storeProducts;
  final List<CategoryEntity> categories;

  const _CouponsPageContent({
    required this.storeId,
    required this.storeProducts,
    required this.categories,
  });

  @override
  State<_CouponsPageContent> createState() => _CouponsPageContentState();
}

class _CouponsPageContentState extends State<_CouponsPageContent>
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

    return BlocConsumer<MerchantCouponsCubit, CouponState>(
      listener: _handleStateChanges,
      builder: (context, state) {
        final coupons =
            state is MerchantCouponsLoaded ? state.coupons : <CouponEntity>[];
        final activeCoupons = coupons.where((c) => c.isActive).toList();
        final inactiveCoupons = coupons.where((c) => !c.isActive).toList();

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: _buildAppBar(theme),
          floatingActionButton: _buildFab(theme),
          body: Column(
            children: [
              _buildTabBar(activeCoupons.length, inactiveCoupons.length, theme),
              Expanded(
                  child:
                      _buildTabContent(state, activeCoupons, inactiveCoupons)),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      backgroundColor: theme.colorScheme.surface,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'coupons'.tr(),
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.primary,
        ),
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
      storeId: widget.storeId,
      onEdit: (coupon) => _navigateToCouponForm(coupon),
      onToggle: (coupon, value) => _toggleCouponStatus(coupon, value),
      onRefresh: () =>
          context.read<MerchantCouponsCubit>().loadCoupons(widget.storeId),
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
      context.read<MerchantCouponsCubit>().loadCoupons(widget.storeId);
    }
  }

  Widget _buildErrorView(String message) {
    return NetworkErrorWidget(
      message: ErrorHelper.getUserFriendlyMessage(message),
      onRetry: () =>
          context.read<MerchantCouponsCubit>().loadCoupons(widget.storeId),
    );
  }

  void _navigateToCouponForm(CouponEntity? coupon) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<MerchantCouponsCubit>(),
          child: CouponFormPage(
            coupon: coupon,
            storeId: widget.storeId,
            storeProducts: widget.storeProducts,
            categories: widget.categories,
          ),
        ),
      ),
    );
  }

  void _toggleCouponStatus(CouponEntity coupon, bool value) {
    context
        .read<MerchantCouponsCubit>()
        .toggleCouponStatus(coupon.id, value, widget.storeId);
  }
}
