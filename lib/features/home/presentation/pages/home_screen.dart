import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../notifications/data/services/local_notification_service.dart';
import '../../../products/presentation/cubit/products_cubit.dart';
import '../../../categories/presentation/cubit/categories_cubit.dart';
import '../cubit/home_sliders_cubit.dart';
import '../widgets/home_content_builder.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  String? selectedCategoryId;
  bool isOffersSelected = false;
  final ScrollController _scrollController = ScrollController();
  int _unreadNotifications = 0;

  @override
  void initState() {
    super.initState();
    context.read<ProductsCubit>().loadProducts();
    context.read<CategoriesCubit>().loadCategories();
    context.read<HomeSlidersCubit>().loadSliders();
    _scrollController.addListener(_onScroll);
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    final count = await sl<LocalNotificationService>().getUnreadCount();
    if (mounted) {
      setState(() => _unreadNotifications = count);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      if (isOffersSelected) {
        context.read<ProductsCubit>().loadMoreDiscountedProducts();
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
          color: AppColours.brownLight,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: <Widget>[
              SliverToBoxAdapter(child: _buildSearchBar(context)),
              ..._buildHomeContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Notification icon
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
          // Search bar - opens search page
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: GestureDetector(
                onTap: () => context.go('/home/search'),
                child: Container(
                  height: 45,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColours.greyLighter,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'بحث',
                        style:
                            TextStyle(fontSize: 12, color: AppColours.greyDark),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.search, color: AppColours.primaryColor),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRefresh() async {
    context.read<HomeSlidersCubit>().refreshSliders();
    context.read<CategoriesCubit>().loadCategories();

    if (isOffersSelected) {
      context.read<ProductsCubit>().loadDiscountedProducts();
    } else if (selectedCategoryId != null) {
      context.read<ProductsCubit>().loadProductsByCategory(selectedCategoryId!);
    } else {
      context.read<ProductsCubit>().loadProducts();
    }
  }

  List<Widget> _buildHomeContent() {
    return HomeContentBuilder.buildHomeContent(
      context: context,
      sliderImages: sliderImages,
      selectedCategoryId: selectedCategoryId,
      isOffersSelected: isOffersSelected,
      onCategorySelected: (categoryId) {
        setState(() {
          selectedCategoryId = categoryId;
          isOffersSelected = false;
        });
        if (categoryId == null) {
          context.read<ProductsCubit>().loadProducts();
        } else {
          context.read<ProductsCubit>().loadProductsByCategory(categoryId);
        }
      },
      onOffersSelected: () {
        setState(() {
          isOffersSelected = true;
          selectedCategoryId = null;
        });
        context.read<ProductsCubit>().loadDiscountedProducts();
      },
    );
  }
}
