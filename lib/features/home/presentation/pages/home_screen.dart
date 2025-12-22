import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../notifications/data/services/local_notification_service.dart';
import '../../../products/data/repositories/product_repository_impl.dart';
import '../../../products/domain/repositories/product_repository.dart';
import '../../../products/presentation/cubit/products_cubit.dart';
import '../../../categories/presentation/cubit/categories_cubit.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/home_filter_sheet.dart';
import '../widgets/home_search_content.dart';
import '../widgets/home_content_builder.dart';
import '../logic/home_search_logic.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with HomeSearchLogic {
  String? selectedCategoryId;
  final ScrollController _scrollController = ScrollController();
  int _unreadNotifications = 0;

  @override
  void initState() {
    super.initState();
    // Initialize search manager
    final repository = sl<ProductRepository>();
    final locale = context.locale.languageCode;
    if (repository is ProductRepositoryImpl) {
      repository.setLocale(locale);
    }
    initializeSearchManager(repository);

    context.read<ProductsCubit>().loadProducts();
    context.read<CategoriesCubit>().loadCategories();
    _scrollController.addListener(_onScroll);
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    final count = await sl<LocalNotificationService>().getUnreadCount();
    if (mounted) {
      setState(() {
        _unreadNotifications = count;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    disposeSearch();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      if (searchState.isSearchMode && searchState.currentQuery.isNotEmpty) {
        loadMoreSearchResults();
      } else {
        context.read<ProductsCubit>().loadMoreProducts();
      }
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll - 200);
  }

  final List<String> sliderImages = [
    "assets/slider/V1.png",
    "assets/slider/V2.png",
    "assets/slider/V3.png",
    "assets/slider/V4.png",
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColours.white,
        body: RefreshIndicator(
          onRefresh: _handleRefresh,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: HomeSearchBar(
                  isSearchMode: searchState.isSearchMode,
                  searchController: searchController,
                  searchFocusNode: searchFocusNode,
                  onSearchChanged: onSearchChanged,
                  onEnterSearchMode: enterSearchMode,
                  onExitSearchMode: exitSearchMode,
                  onShowFilter: _showFilterSheet,
                  hasActiveFilters: filterState.hasActiveFilters,
                  unreadNotifications: _unreadNotifications,
                  onNotificationTap: () {
                    context.push('/notifications');
                    _loadUnreadCount();
                  },
                ),
              ),
              if (searchState.isSearchMode)
                SliverToBoxAdapter(
                  child: HomeSearchContent(
                    isSearching: searchState.isSearching,
                    currentQuery: searchState.currentQuery,
                    searchResults: searchState.searchResults,
                    isLoadingMore: searchState.isLoadingMore,
                    hasMore: searchState.hasMore,
                  ),
                )
              else
                ..._buildHomeContent(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleRefresh() async {
    if (searchState.isSearchMode && searchState.currentQuery.isNotEmpty) {
      await refreshSearch();
    } else {
      if (selectedCategoryId != null) {
        context
            .read<ProductsCubit>()
            .loadProductsByCategory(selectedCategoryId!);
      } else {
        context.read<ProductsCubit>().loadProducts();
      }
      context.read<CategoriesCubit>().loadCategories();
    }
  }

  void _showFilterSheet() {
    showFilterSheet(
      context,
      HomeFilterSheet(
        initialCategoryId: filterState.categoryId,
        initialPriceRange: filterState.priceRange,
        minPrice: filterState.minPrice,
        maxPrice: filterState.maxPrice,
        onApply: (categoryId, priceRange) {
          applyFilters(
            categoryId: categoryId,
            priceRange: priceRange,
          );
        },
      ),
    );
  }

  List<Widget> _buildHomeContent() {
    return HomeContentBuilder.buildHomeContent(
      context: context,
      sliderImages: sliderImages,
      selectedCategoryId: selectedCategoryId,
      onCategorySelected: (categoryId) {
        setState(() {
          selectedCategoryId = categoryId;
        });
        if (categoryId == null) {
          context.read<ProductsCubit>().loadProducts();
        } else {
          context.read<ProductsCubit>().loadProductsByCategory(categoryId);
        }
      },
    );
  }
}
