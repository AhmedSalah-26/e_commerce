import 'dart:async';
import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/shared_widgets/product_grid_card.dart';
import '../../../../core/shared_widgets/skeleton_widgets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../notifications/data/services/local_notification_service.dart';
import '../../../products/data/repositories/product_repository_impl.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../../products/domain/repositories/product_repository.dart';
import '../../../products/presentation/cubit/products_cubit.dart';
import '../../../products/presentation/cubit/products_state.dart';
import '../../../categories/presentation/cubit/categories_cubit.dart';
import '../../../categories/presentation/cubit/categories_state.dart';
import '../widgets/images_card_slider.dart';
import '../widgets/category_row.dart';
import '../widgets/products_grid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? selectedCategoryId;
  final ScrollController _scrollController = ScrollController();

  // Search state
  bool _isSearchMode = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _debounceTimer;
  List<ProductEntity> _searchResults = [];
  bool _isSearching = false;
  bool _isLoadingMoreSearch = false;
  bool _hasMoreSearch = true;
  int _searchPage = 0;
  String _currentQuery = '';
  static const int _pageSize = 10;
  int _unreadNotifications = 0;

  // Filter state
  String? _filterCategoryId;
  final double _minPrice = 0;
  final double _maxPrice = 10000;
  RangeValues _priceRange = const RangeValues(0, 10000);
  bool _hasActiveFilters = false;

  @override
  void initState() {
    super.initState();
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
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      if (_isSearchMode && _currentQuery.isNotEmpty) {
        _loadMoreSearchResults();
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

  void _enterSearchMode() {
    setState(() {
      _isSearchMode = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  void _exitSearchMode() {
    _debounceTimer?.cancel();
    _searchController.clear();
    _searchFocusNode.unfocus();
    setState(() {
      _isSearchMode = false;
      _searchResults = [];
      _currentQuery = '';
      _isSearching = false;
      _filterCategoryId = null;
      _priceRange = RangeValues(_minPrice, _maxPrice);
      _hasActiveFilters = false;
    });
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();

    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _currentQuery = '';
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _currentQuery = query;
    });

    _debounceTimer = Timer(const Duration(seconds: 1), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
      _searchPage = 0;
    });

    final repository = sl<ProductRepository>();
    final locale = context.locale.languageCode;

    if (repository is ProductRepositoryImpl) {
      repository.setLocale(locale);
    }

    final result = await repository.searchProducts(
      query,
      page: 0,
      limit: _pageSize,
      categoryId: _filterCategoryId,
      minPrice: _priceRange.start > _minPrice ? _priceRange.start : null,
      maxPrice: _priceRange.end < _maxPrice ? _priceRange.end : null,
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _isSearching = false;
          _searchResults = [];
        });
      },
      (products) {
        setState(() {
          _isSearching = false;
          _searchResults = products;
          _hasMoreSearch = products.length >= _pageSize;
        });
      },
    );
  }

  Future<void> _loadMoreSearchResults() async {
    if (_isLoadingMoreSearch || !_hasMoreSearch || _currentQuery.isEmpty) {
      return;
    }

    setState(() {
      _isLoadingMoreSearch = true;
    });

    final repository = sl<ProductRepository>();
    final nextPage = _searchPage + 1;

    final result = await repository.searchProducts(
      _currentQuery,
      page: nextPage,
      limit: _pageSize,
      categoryId: _filterCategoryId,
      minPrice: _priceRange.start > _minPrice ? _priceRange.start : null,
      maxPrice: _priceRange.end < _maxPrice ? _priceRange.end : null,
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _isLoadingMoreSearch = false;
        });
      },
      (newProducts) {
        setState(() {
          _isLoadingMoreSearch = false;
          _searchResults = [..._searchResults, ...newProducts];
          _searchPage = nextPage;
          _hasMoreSearch = newProducts.length >= _pageSize;
        });
      },
    );
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
          onRefresh: () async {
            if (_isSearchMode && _currentQuery.isNotEmpty) {
              await _performSearch(_currentQuery);
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
          },
          child: CustomScrollView(
            controller: _scrollController,
            slivers: <Widget>[
              // Custom App Bar with Search
              SliverToBoxAdapter(
                child: _buildAppBarWithSearch(),
              ),
              // Content based on search mode
              if (_isSearchMode)
                _buildSearchContent()
              else
                ..._buildHomeContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBarWithSearch() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Notification icon (right side in RTL)
          if (!_isSearchMode)
            GestureDetector(
              onTap: () {
                context.push('/notifications');
                _loadUnreadCount();
              },
              child: Container(
                width: screenWidth * 0.12,
                height: screenHeight * 0.055,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColours.greyLighter,
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        Icons.notifications,
                        size: screenWidth * 0.055,
                        color: AppColours.brownLight,
                      ),
                    ),
                    if (_unreadNotifications > 0)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            _unreadNotifications > 9
                                ? '9+'
                                : '$_unreadNotifications',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          // Back button when in search mode
          if (_isSearchMode)
            IconButton(
              icon: const Icon(Icons.arrow_forward,
                  color: AppColours.brownMedium),
              onPressed: _exitSearchMode,
            ),
          // Search bar (center)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: _isSearchMode
                  ? _buildActiveSearchBar()
                  : _buildInactiveSearchBar(),
            ),
          ),
          // Filter button when in search mode
          if (_isSearchMode)
            GestureDetector(
              onTap: _showFilterSheet,
              child: Container(
                height: 45,
                width: 45,
                decoration: BoxDecoration(
                  color: AppColours.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: AppColours.primaryColor, width: 1.5),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(Icons.filter_list,
                        color: AppColours.primaryColor, size: 24),
                    if (_hasActiveFilters)
                      Positioned(
                        right: 4,
                        top: 4,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInactiveSearchBar() {
    return GestureDetector(
      onTap: _enterSearchMode,
      child: Container(
        height: 45,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColours.greyLighter,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('search'.tr(), style: AppTextStyle.normal_12_greyDark),
            const SizedBox(width: 8),
            const Icon(Icons.search, color: AppColours.primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveSearchBar() {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: AppColours.greyLighter,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onChanged: _onSearchChanged,
        textAlign: TextAlign.right,
        textDirection: ui.TextDirection.rtl,
        textInputAction: TextInputAction.search,
        onSubmitted: (value) {
          _debounceTimer?.cancel();
          if (value.isNotEmpty) {
            _performSearch(value);
          }
        },
        style: AppTextStyle.normal_12_black,
        decoration: InputDecoration(
          hintText: 'search'.tr(),
          hintStyle: AppTextStyle.normal_12_greyDark,
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear,
                      color: AppColours.greyMedium, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchResults = [];
                      _currentQuery = '';
                    });
                  },
                )
              : null,
          prefixIcon: const Icon(Icons.search, color: AppColours.primaryColor),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _buildFilterSheet(),
    );
  }

  Widget _buildFilterSheet() {
    String? tempCategoryId = _filterCategoryId;
    RangeValues tempPriceRange = _priceRange;

    return StatefulBuilder(
      builder: (context, setSheetState) => Container(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('filters'.tr(),
                      style: AppTextStyle.semiBold_20_dark_brown),
                  TextButton(
                    onPressed: () {
                      setSheetState(() {
                        tempCategoryId = null;
                        tempPriceRange = RangeValues(_minPrice, _maxPrice);
                      });
                    },
                    child: Text('clear_all'.tr(),
                        style: const TextStyle(color: Colors.red)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Category filter
              Text('categories'.tr(),
                  style: AppTextStyle.semiBold_16_dark_brown),
              const SizedBox(height: 12),
              BlocBuilder<CategoriesCubit, CategoriesState>(
                builder: (context, state) {
                  if (state is CategoriesLoaded) {
                    return SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: state.categories.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return _buildCategoryChip(
                              'all'.tr(),
                              tempCategoryId == null,
                              () => setSheetState(() => tempCategoryId = null),
                            );
                          }
                          final category = state.categories[index - 1];
                          return _buildCategoryChip(
                            category.name,
                            tempCategoryId == category.id,
                            () => setSheetState(
                                () => tempCategoryId = category.id),
                          );
                        },
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 24),
              // Price filter
              Text('price'.tr(), style: AppTextStyle.semiBold_16_dark_brown),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${tempPriceRange.start.toInt()} ${'egp'.tr()}'),
                  Text('${tempPriceRange.end.toInt()} ${'egp'.tr()}'),
                ],
              ),
              RangeSlider(
                values: tempPriceRange,
                min: _minPrice,
                max: _maxPrice,
                divisions: 100,
                activeColor: AppColours.brownMedium,
                inactiveColor: AppColours.greyLight,
                onChanged: (values) {
                  setSheetState(() => tempPriceRange = values);
                },
              ),
              const SizedBox(height: 24),
              // Apply button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _filterCategoryId = tempCategoryId;
                      _priceRange = tempPriceRange;
                      _hasActiveFilters = tempCategoryId != null ||
                          tempPriceRange.start > _minPrice ||
                          tempPriceRange.end < _maxPrice;
                    });
                    Navigator.pop(context);
                    if (_currentQuery.isNotEmpty) {
                      _performSearch(_currentQuery);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColours.brownMedium,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('apply'.tr(),
                      style:
                          const TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColours.brownMedium : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColours.brownMedium),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColours.brownMedium,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchContent() {
    if (_isSearching) {
      return const SliverToBoxAdapter(
        child: ProductsGridSkeleton(itemCount: 4),
      );
    }

    if (_currentQuery.isEmpty) {
      return SliverToBoxAdapter(
        child: SizedBox(
          height: 400,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search, size: 80, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'search_products'.tr(),
                  style: TextStyle(fontSize: 18, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return SliverToBoxAdapter(
        child: SizedBox(
          height: 400,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 80, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  '${'no_results_for'.tr()} "$_currentQuery"',
                  style: TextStyle(fontSize: 18, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              '${'search_results'.tr()} (${_searchResults.length})',
              style: AppTextStyle.semiBold_16_dark_brown,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.6,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                return ProductGridCard(product: _searchResults[index]);
              },
            ),
          ),
          if (_isLoadingMoreSearch)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          if (!_hasMoreSearch && _searchResults.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'no_more_results'.tr(),
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  List<Widget> _buildHomeContent() {
    return [
      SliverToBoxAdapter(
        child: Column(
          children: <Widget>[
            ImagesCard(images: sliderImages),
            const SizedBox(height: 10),
            BlocBuilder<CategoriesCubit, CategoriesState>(
              builder: (context, state) {
                if (state is CategoriesLoading) {
                  return const CategoriesRowSkeleton();
                }
                if (state is CategoriesLoaded) {
                  return HorizontalCategoriesView(
                    categories: state.categories,
                    selectedCategoryId: selectedCategoryId,
                    onCategorySelected: (categoryId) {
                      setState(() {
                        selectedCategoryId = categoryId;
                      });
                      if (categoryId == null) {
                        context.read<ProductsCubit>().loadProducts();
                      } else {
                        context
                            .read<ProductsCubit>()
                            .loadProductsByCategory(categoryId);
                      }
                    },
                  );
                }
                if (state is CategoriesError) {
                  return Center(
                    child: Text(
                      state.message,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
      // Products Grid
      BlocBuilder<ProductsCubit, ProductsState>(
        builder: (context, state) {
          if (state is ProductsLoading) {
            return const SliverToBoxAdapter(
              child: ProductsGridSkeleton(itemCount: 6),
            );
          }
          if (state is ProductsLoaded) {
            if (state.products.isEmpty) {
              return SliverToBoxAdapter(
                child: SizedBox(
                  height: 200,
                  child: Center(
                    child: Text(
                      'no_products'.tr(),
                      style: const TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ),
                ),
              );
            }
            return SliverToBoxAdapter(
              child: Column(
                children: [
                  ProductsGrid(products: state.products),
                  if (state.isLoadingMore)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  if (!state.hasMore && state.products.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: Text(
                          'no_more_products'.tr(),
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          }
          if (state is ProductsError) {
            return SliverToBoxAdapter(
              child: SizedBox(
                height: 200,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        state.message,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          context.read<ProductsCubit>().loadProducts();
                        },
                        child: Text('retry'.tr()),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        },
      ),
    ];
  }
}
