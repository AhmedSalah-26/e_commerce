import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../notifications/data/services/local_notification_service.dart';
import '../../../products/presentation/cubit/products_cubit.dart';
import '../../../categories/presentation/cubit/categories_cubit.dart';
import '../cubit/home_sliders_cubit.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/home_sliders.dart';
import '../widgets/home_products_section.dart';
import '../widgets/category_row.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static final GlobalKey<HomeScreenState> globalKey =
      GlobalKey<HomeScreenState>();

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  // Tab selection state
  String? _selectedCategoryId;
  bool _isOffersSelected = false;
  bool _isBestSellersSelected = true;
  bool _isTopRatedSelected = false;
  bool _isAllProductsSelected = false;

  final ScrollController _scrollController = ScrollController();
  int _unreadNotifications = 0;
  String? _lastLocale;

  void scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(0,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadUnreadCount();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentLocale = context.locale.languageCode;
    if (_lastLocale == null || _lastLocale != currentLocale) {
      _lastLocale = currentLocale;
      _initializeData();
    }
  }

  void _initializeData() {
    final locale = context.locale.languageCode;
    context.read<CategoriesCubit>().setLocale(locale);
    context.read<HomeSlidersCubit>().setLocale(locale);
    context.read<CategoriesCubit>().loadCategories();
    context.read<HomeSlidersCubit>().reset();

    // Load best sellers by default
    _loadTab(TabType.bestSellers);
  }

  Future<void> _loadUnreadCount() async {
    final count = await sl<LocalNotificationService>().getUnreadCount();
    if (mounted) setState(() => _unreadNotifications = count);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;

    if (currentScroll >= (maxScroll - 200)) {
      final cubit = context.read<ProductsCubit>();
      if (_isOffersSelected) {
        cubit.loadMoreDiscountedProducts();
      } else if (_isBestSellersSelected) {
        cubit.loadMoreBestSellingProducts();
      } else if (_isTopRatedSelected) {
        cubit.loadMoreTopRatedProducts();
      } else {
        cubit.loadMoreProducts();
      }
    }
  }

  Future<void> _handleRefresh() async {
    context.read<HomeSlidersCubit>().refreshSliders();
    context.read<CategoriesCubit>().loadCategories();

    final cubit = context.read<ProductsCubit>();
    if (_isOffersSelected) {
      await cubit.loadDiscountedProducts();
    } else if (_isBestSellersSelected) {
      await cubit.loadBestSellingProducts();
    } else if (_isTopRatedSelected) {
      await cubit.loadTopRatedProducts();
    } else {
      await cubit.loadProducts(forceReload: true);
    }
  }

  /// Load products for a specific tab with shimmer
  void _loadTab(TabType tab) {
    // Update tab selection state
    setState(() {
      _selectedCategoryId = null;
      _isOffersSelected = tab == TabType.offers;
      _isBestSellersSelected = tab == TabType.bestSellers;
      _isTopRatedSelected = tab == TabType.topRated;
      _isAllProductsSelected = tab == TabType.allProducts;
    });

    // Load data - cubit will emit ProductsLoading which triggers shimmer
    final cubit = context.read<ProductsCubit>();
    switch (tab) {
      case TabType.offers:
        cubit.loadDiscountedProducts();
      case TabType.bestSellers:
        cubit.loadBestSellingProducts();
      case TabType.topRated:
        cubit.loadTopRatedProducts();
      case TabType.allProducts:
        cubit.loadProducts(forceReload: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Column(
          children: [
            // Fixed search bar
            HomeSearchBar(
              unreadNotifications: _unreadNotifications,
              onNotificationTap: () {
                context.push('/notifications');
                _loadUnreadCount();
              },
            ),
            // Scrollable content
            Expanded(
              child: RefreshIndicator(
                onRefresh: _handleRefresh,
                color: theme.colorScheme.primary,
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    // Sliders
                    const SliverToBoxAdapter(child: HomeSliders()),
                    // Sticky tabs
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _StickyTabDelegate(
                        backgroundColor: theme.scaffoldBackgroundColor,
                        child: _buildTabs(theme),
                      ),
                    ),
                    // Products grid
                    HomeProductsSection(
                      onRetry: _handleRefresh,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs(ThemeData theme) {
    return Container(
      color: theme.scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: HorizontalCategoriesView(
        categories: const [],
        selectedCategoryId: _selectedCategoryId,
        isOffersSelected: _isOffersSelected,
        isBestSellersSelected: _isBestSellersSelected,
        isTopRatedSelected: _isTopRatedSelected,
        isAllProductsSelected: _isAllProductsSelected,
        onCategorySelected: (_) {},
        onOffersSelected: () => _loadTab(TabType.offers),
        onBestSellersSelected: () => _loadTab(TabType.bestSellers),
        onTopRatedSelected: () => _loadTab(TabType.topRated),
        onAllProductsSelected: () => _loadTab(TabType.allProducts),
      ),
    );
  }
}

enum TabType { offers, bestSellers, topRated, allProducts }

class _StickyTabDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final Color backgroundColor;

  _StickyTabDelegate({required this.child, required this.backgroundColor});

  @override
  double get minExtent => 66;
  @override
  double get maxExtent => 66;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: backgroundColor, child: child);
  }

  @override
  bool shouldRebuild(covariant _StickyTabDelegate oldDelegate) {
    return child != oldDelegate.child ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}
