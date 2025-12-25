import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/shared_widgets/custom_button.dart';
import '../../../../core/shared_widgets/flash_sale_banner.dart';
import '../../../../core/shared_widgets/skeleton_widgets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/share_utils.dart';
import '../../domain/entities/product_entity.dart';
import '../../data/datasources/product_remote_datasource.dart';
import '../cubit/products_cubit.dart';
import '../utils/product_actions.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../cart/presentation/cubit/cart_state.dart';
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
  bool _isLoading = true;

  static const _actions = ProductActions();

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    _loadFullProduct();
  }

  Future<void> _loadFullProduct() async {
    try {
      final productsCubit = sl<ProductsCubit>();
      final fullProduct = await productsCubit.getProductById(widget.product.id);
      if (mounted && fullProduct != null) {
        setState(() {
          _product = fullProduct;
          _isLoading = false;
        });
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
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
    await _loadFullProduct();
  }

  @override
  Widget build(BuildContext context) {
    double totalPrice = _quantity * _product.effectivePrice;
    double screenWidth = MediaQuery.of(context).size.width;
    final isArabic = context.locale.languageCode == 'ar';
    final isInactive = !_product.isActive;

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<ReviewsCubit>()),
        BlocProvider(create: (context) => sl<ProductsCubit>()),
      ],
      child: Scaffold(
        backgroundColor: AppColours.white,
        appBar: _buildAppBar(context),
        body: _isLoading
            ? const ProductScreenSkeleton()
            : Stack(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    child: ListView(
                      children: [
                        // Flash Sale Banner (only if active)
                        if (!isInactive &&
                            _product.isFlashSaleActive &&
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
                        // Show unavailable badge if inactive
                        if (isInactive) ...[
                          _buildUnavailableBadge(screenWidth),
                          SizedBox(height: screenWidth * 0.03),
                        ],
                        ProductInfoSection(
                          product: _product,
                          screenWidth: screenWidth,
                          isArabic: isArabic,
                          hidePrice: isInactive,
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
                        ),
                        SizedBox(height: screenWidth * 0.02),
                        if (!isInactive)
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
                        if (!isInactive && !_product.isOutOfStock)
                          ProductQuantitySelector(
                            quantity: _quantity,
                            maxStock: _product.stock,
                            screenWidth: screenWidth,
                            isArabic: isArabic,
                            onQuantityChanged: (newQuantity) {
                              setState(() => _quantity = newQuantity);
                            },
                          ),
                        if (!isInactive) ...[
                          SizedBox(height: screenWidth * 0.05),
                          ProductTotalPrice(
                            totalPrice: totalPrice,
                            screenWidth: screenWidth,
                            isArabic: isArabic,
                          ),
                        ],
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
                  _buildAddToCartButton(context, isInactive),
                ],
              ),
      ),
    );
  }

  Widget _buildUnavailableBadge(double screenWidth) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenWidth * 0.03,
      ),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange[300]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.orange[700],
            size: screenWidth * 0.05,
          ),
          SizedBox(width: screenWidth * 0.02),
          Text(
            'product_unavailable'.tr(),
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              color: Colors.orange[700],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
          onPressed: () => _actions.toggleFavorite(context, _product.id),
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
    final locale = context.locale.languageCode;

    return AppBar(
      backgroundColor: AppColours.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: AppColours.brownMedium),
        onPressed: () => _handleBack(context),
      ),
      actions: [
        // Share button
        IconButton(
          onPressed: () => _shareProduct(locale),
          icon: const Icon(Icons.share_outlined, color: AppColours.brownMedium),
        ),
        BlocSelector<CartCubit, CartState, int>(
          selector: (state) => state is CartLoaded
              ? state.items.fold<int>(0, (sum, item) => sum + item.quantity)
              : 0,
          builder: (context, cartItemCount) {
            return Padding(
              padding: const EdgeInsets.only(left: 8),
              child: IconButton(
                onPressed: () => context.go('/cart'),
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

  /// Share product link
  void _shareProduct(String locale) {
    final shareText = ShareUtils.getProductShareText(_product, locale);
    Share.share(shareText);
  }

  Widget _buildAddToCartButton(BuildContext context, bool isInactive) {
    final isOutOfStock = _product.isOutOfStock || isInactive;
    final buttonLabel = isInactive
        ? 'product_unavailable'.tr()
        : (isOutOfStock ? 'out_of_stock'.tr() : 'add_to_cart'.tr());

    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: CustomButton(
        color: isOutOfStock ? Colors.grey : AppColours.brownLight,
        onPressed: isOutOfStock
            ? () => _actions.showOutOfStock(context)
            : () => _actions.addToCart(context, _product.id, _quantity),
        label: buttonLabel,
      ),
    );
  }
}
