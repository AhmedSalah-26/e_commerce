import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/shared_widgets/custom_button.dart';
import '../../../../core/shared_widgets/flash_sale_banner.dart';
import '../../../../core/shared_widgets/toast.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/product_entity.dart';
import '../../data/datasources/product_remote_datasource.dart';
import '../cubit/products_cubit.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../cart/presentation/cubit/cart_state.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../favorites/presentation/cubit/favorites_cubit.dart';
import '../../../favorites/presentation/cubit/favorites_state.dart';
import '../../../reviews/presentation/cubit/reviews_cubit.dart';
import '../../../reviews/presentation/widgets/review_widgets/reviews_section.dart';
import '../widgets/suggested_products_slider.dart';
import '../widgets/product_image_slider.dart';
import '../widgets/product_info_section.dart';
import '../widgets/product_store_info.dart';
import '../widgets/product_details_widgets.dart';

class ProductScreen extends StatefulWidget {
  final ProductEntity product;

  const ProductScreen({super.key, required this.product});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  int _quantity = 1;
  late ProductEntity _product;
  bool _isLoadingStoreInfo = true;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    _loadProductWithStoreInfo();
  }

  Future<void> _loadProductWithStoreInfo() async {
    try {
      final productsCubit = sl<ProductsCubit>();
      final fullProduct = await productsCubit.getProductById(widget.product.id);
      if (mounted && fullProduct != null) {
        setState(() {
          _product = fullProduct;
          _isLoadingStoreInfo = false;
        });
      } else {
        if (mounted) {
          setState(() => _isLoadingStoreInfo = false);
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingStoreInfo = false);
      }
    }
  }

  /// Called when flash sale timer expires
  Future<void> _onFlashSaleExpired() async {
    // Cleanup this specific product's flash sale in database
    try {
      final datasource = sl<ProductRemoteDataSource>();
      await datasource.cleanupExpiredFlashSaleForProduct(_product.id);
    } catch (_) {
      // Silently fail
    }

    // Reload product to get updated data (without discount)
    await _loadProductWithStoreInfo();
  }

  @override
  Widget build(BuildContext context) {
    double totalPrice = _quantity * _product.effectivePrice;
    double screenWidth = MediaQuery.of(context).size.width;
    final isArabic = context.locale.languageCode == 'ar';

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<ReviewsCubit>()),
        BlocProvider(create: (context) => sl<ProductsCubit>()),
      ],
      child: Scaffold(
        backgroundColor: AppColours.white,
        appBar: _buildAppBar(context),
        body: Stack(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: ListView(
                children: [
                  // Flash Sale Banner
                  if (_product.isFlashSaleActive &&
                      _product.flashSaleEnd != null)
                    FlashSaleBanner(
                      endTime: _product.flashSaleEnd!,
                      onExpired: _onFlashSaleExpired,
                    ),
                  ProductImageSlider(
                    images: _product.images,
                    screenWidth: screenWidth,
                  ),
                  SizedBox(height: screenWidth * 0.05),
                  ProductInfoSection(
                    product: _product,
                    screenWidth: screenWidth,
                    isArabic: isArabic,
                  ),
                  SizedBox(height: screenWidth * 0.02),
                  ProductRatingSection(
                    product: _product,
                    screenWidth: screenWidth,
                    isArabic: isArabic,
                    favoriteButton: _buildFavoriteButton(screenWidth),
                  ),
                  SizedBox(height: screenWidth * 0.02),
                  ProductStoreInfo(
                    product: _product,
                    screenWidth: screenWidth,
                    isArabic: isArabic,
                    isLoading: _isLoadingStoreInfo,
                  ),
                  SizedBox(height: screenWidth * 0.02),
                  ProductStockStatus(
                    product: _product,
                    screenWidth: screenWidth,
                    isArabic: isArabic,
                  ),
                  SizedBox(height: screenWidth * 0.02),
                  ProductDescription(
                    product: _product,
                    screenWidth: screenWidth,
                    isArabic: isArabic,
                  ),
                  SizedBox(height: screenWidth * 0.05),
                  if (!_product.isOutOfStock)
                    ProductQuantitySelector(
                      quantity: _quantity,
                      maxStock: _product.stock,
                      screenWidth: screenWidth,
                      isArabic: isArabic,
                      onQuantityChanged: (newQuantity) {
                        setState(() => _quantity = newQuantity);
                      },
                    ),
                  SizedBox(height: screenWidth * 0.05),
                  ProductTotalPrice(
                    totalPrice: totalPrice,
                    screenWidth: screenWidth,
                    isArabic: isArabic,
                  ),
                  SizedBox(height: screenWidth * 0.05),
                  SuggestedProductsSlider(
                    currentProductId: _product.id,
                    categoryId: _product.categoryId,
                  ),
                  SizedBox(height: screenWidth * 0.05),
                  ReviewsSection(productId: _product.id),
                  SizedBox(height: screenWidth * 0.2),
                ],
              ),
            ),
            _buildAddToCartButton(context),
          ],
        ),
      ),
    );
  }

  void _handleBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  Widget _buildFavoriteButton(double screenWidth) {
    return BlocSelector<FavoritesCubit, FavoritesState, bool>(
      selector: (state) =>
          state is FavoritesLoaded && state.isFavorite(_product.id),
      builder: (context, isFav) {
        return IconButton(
          onPressed: () => _toggleFavorite(context),
          icon: Icon(
            isFav ? Icons.favorite : Icons.favorite_border,
            color: Colors.red,
            size: screenWidth * 0.07,
          ),
        );
      },
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColours.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: AppColours.brownMedium),
        onPressed: () => _handleBack(context),
      ),
      actions: [
        BlocSelector<CartCubit, CartState, int>(
          selector: (state) => state is CartLoaded
              ? state.items.fold<int>(0, (sum, item) => sum + item.quantity)
              : 0,
          builder: (context, cartItemCount) {
            return Padding(
              padding: const EdgeInsets.only(left: 8),
              child: IconButton(
                onPressed: () => context.push('/cart'),
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.shopping_cart_outlined,
                        color: AppColours.brownMedium),
                    if (cartItemCount > 0)
                      Positioned(
                        right: -8,
                        top: -4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                              color: Colors.red, shape: BoxShape.circle),
                          constraints:
                              const BoxConstraints(minWidth: 18, minHeight: 18),
                          child: Text(
                            cartItemCount > 99 ? '99+' : '$cartItemCount',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAddToCartButton(BuildContext context) {
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: CustomButton(
        color: _product.isOutOfStock ? Colors.grey : AppColours.brownLight,
        onPressed: _product.isOutOfStock
            ? () => Tost.showCustomToast(context, 'out_of_stock'.tr(),
                backgroundColor: Colors.red, textColor: Colors.white)
            : () => _addToCart(context),
        label: _product.isOutOfStock ? 'out_of_stock'.tr() : 'add_to_cart'.tr(),
      ),
    );
  }

  void _addToCart(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      context.read<CartCubit>().setUserId(authState.user.id);
      context.read<CartCubit>().addToCart(_product.id, quantity: _quantity);
      Tost.showCustomToast(context, 'added_to_cart'.tr(),
          backgroundColor: Colors.green, textColor: Colors.white);
    } else {
      Tost.showCustomToast(context, 'login_required'.tr(),
          backgroundColor: Colors.orange, textColor: Colors.white);
    }
  }

  void _toggleFavorite(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      final favoritesCubit = context.read<FavoritesCubit>();
      favoritesCubit.setUserId(authState.user.id);
      final isFav = favoritesCubit.isFavorite(_product.id);
      favoritesCubit.toggleFavorite(_product.id);

      if (isFav) {
        Tost.showCustomToast(context, 'removed_from_favorites'.tr(),
            backgroundColor: Colors.grey, textColor: Colors.white);
      } else {
        Tost.showCustomToast(context, 'added_to_favorites'.tr(),
            backgroundColor: Colors.red, textColor: Colors.white);
      }
    } else {
      Tost.showCustomToast(context, 'login_required'.tr(),
          backgroundColor: Colors.orange, textColor: Colors.white);
    }
  }
}
