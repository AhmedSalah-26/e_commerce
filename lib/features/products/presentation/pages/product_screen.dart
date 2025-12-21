import 'dart:ui' as ui;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fan_carousel_image_slider/fan_carousel_image_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/shared_widgets/custom_button.dart';
import '../../../../core/shared_widgets/skeleton_widgets.dart';
import '../../../../core/shared_widgets/toast.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../domain/entities/product_entity.dart';
import '../cubit/products_cubit.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../cart/presentation/cubit/cart_state.dart';
import '../../../cart/presentation/pages/cart_screen.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../favorites/presentation/cubit/favorites_cubit.dart';
import '../../../favorites/presentation/cubit/favorites_state.dart';
import '../../../reviews/presentation/cubit/reviews_cubit.dart';
import '../../../reviews/presentation/widgets/reviews_section.dart';
import '../widgets/suggested_products_slider.dart';

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

  @override
  Widget build(BuildContext context) {
    double totalPrice = _quantity * _product.effectivePrice;
    double screenWidth = MediaQuery.of(context).size.width;
    final isArabic = context.locale.languageCode == 'ar';

    return BlocProvider(
      create: (context) => sl<ReviewsCubit>(),
      child: Scaffold(
        backgroundColor: AppColours.white,
        appBar: _buildAppBar(context),
        body: Stack(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: ListView(
                children: [
                  _buildImageSlider(screenWidth),
                  SizedBox(height: screenWidth * 0.05),
                  _buildNameAndPrice(screenWidth, isArabic),
                  SizedBox(height: screenWidth * 0.02),
                  _buildRating(screenWidth, isArabic),
                  SizedBox(height: screenWidth * 0.02),
                  _buildStoreInfo(screenWidth, isArabic),
                  SizedBox(height: screenWidth * 0.02),
                  _buildStockStatus(screenWidth, isArabic),
                  SizedBox(height: screenWidth * 0.02),
                  _buildDescription(screenWidth, isArabic),
                  SizedBox(height: screenWidth * 0.05),
                  if (!_product.isOutOfStock)
                    _buildQuantitySelector(screenWidth, isArabic),
                  SizedBox(height: screenWidth * 0.05),
                  _buildTotalPrice(screenWidth, isArabic, totalPrice),
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

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColours.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: AppColours.brownMedium),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        BlocBuilder<CartCubit, CartState>(
          builder: (context, cartState) {
            final cartItemCount = cartState is CartLoaded
                ? cartState.items
                    .fold<int>(0, (sum, item) => sum + item.quantity)
                : 0;
            return Padding(
              padding: const EdgeInsets.only(left: 8),
              child: IconButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CartScreen()),
                ),
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

  Widget _buildImageSlider(double screenWidth) {
    if (_product.images.isNotEmpty) {
      return FanCarouselImageSlider.sliderType1(
        autoPlayInterval: const Duration(seconds: 3),
        isClickable: true,
        imagesLink: _product.images,
        imageFitMode: BoxFit.cover,
        isAssets: !_product.images.first.startsWith('http'),
        expandImageHeight: screenWidth * 0.7,
        initalPageIndex: 0,
        autoPlay: _product.images.length > 1,
        indicatorActiveColor: AppColours.brownLight,
        sliderHeight: screenWidth * 0.5,
        sliderWidth: screenWidth,
        expandedImageFitMode: BoxFit.contain,
        showIndicator: _product.images.length > 1,
      );
    }
    return Container(
      height: screenWidth * 0.5,
      decoration: BoxDecoration(
        color: AppColours.greyLight,
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Center(
          child: Icon(Icons.image_not_supported, size: 80, color: Colors.grey)),
    );
  }

  Widget _buildNameAndPrice(double screenWidth, bool isArabic) {
    return Directionality(
      textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: AutoSizeText(
              _product.name,
              style: AppTextStyle.semiBold_20_dark_brown
                  .copyWith(fontSize: screenWidth * 0.04),
              minFontSize: 14,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (_product.hasDiscount)
                  AutoSizeText(
                    "${_product.price.toStringAsFixed(2)} ${'egp'.tr()}",
                    style: TextStyle(
                        fontSize: screenWidth * 0.03,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough),
                    minFontSize: 10,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                AutoSizeText(
                  "${_product.effectivePrice.toStringAsFixed(2)} ${'egp'.tr()}",
                  style: AppTextStyle.bold_18_medium_brown
                      .copyWith(fontSize: screenWidth * 0.04),
                  minFontSize: 14,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRating(double screenWidth, bool isArabic) {
    return Directionality(
      textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Rating section
          Row(
            children: [
              RatingBarIndicator(
                rating: _product.rating,
                direction: Axis.horizontal,
                itemCount: 5,
                itemSize: screenWidth * 0.05,
                itemPadding:
                    EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
                itemBuilder: (context, _) =>
                    const Icon(Icons.star, color: Colors.amber),
              ),
              SizedBox(width: screenWidth * 0.02),
              AutoSizeText(
                "(${_product.rating.toStringAsFixed(1)})",
                style: AppTextStyle.normal_16_brownLight
                    .copyWith(fontSize: screenWidth * 0.04),
                minFontSize: 10,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          // Favorite button
          BlocBuilder<FavoritesCubit, FavoritesState>(
            builder: (context, state) {
              final isFav =
                  state is FavoritesLoaded && state.isFavorite(_product.id);
              return IconButton(
                onPressed: () => _toggleFavorite(context),
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: Colors.red,
                  size: screenWidth * 0.07,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStoreInfo(double screenWidth, bool isArabic) {
    // Show skeleton while loading
    if (_isLoadingStoreInfo) {
      return const StoreInfoSkeleton();
    }

    // Hide if no store info
    if (!_product.hasStoreInfo) return const SizedBox.shrink();

    return Directionality(
      textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColours.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Store name
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.store,
                      size: 14, color: AppColours.brownMedium),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      _product.storeName!,
                      style: AppTextStyle.semiBold_16_dark_brown
                          .copyWith(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            // Address
            if (_product.storeAddress != null &&
                _product.storeAddress!.isNotEmpty)
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_on,
                        size: 14, color: AppColours.brownMedium),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        _product.storeAddress!,
                        style: AppTextStyle.normal_14_greyDark
                            .copyWith(fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            // Phone
            if (_product.storePhone != null && _product.storePhone!.isNotEmpty)
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.phone,
                        size: 14, color: AppColours.brownMedium),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        _product.storePhone!,
                        style: AppTextStyle.normal_14_greyDark
                            .copyWith(fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockStatus(double screenWidth, bool isArabic) {
    return Directionality(
      textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: _product.isOutOfStock
                  ? Colors.red.shade100
                  : Colors.green.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _product.isOutOfStock
                  ? 'out_of_stock'.tr()
                  : '${'in_stock'.tr()} (${_product.stock})',
              style: TextStyle(
                color: _product.isOutOfStock ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(double screenWidth, bool isArabic) {
    return Directionality(
      textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _product.description,
            style: AppTextStyle.normal_12_black
                .copyWith(fontSize: screenWidth * 0.04),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector(double screenWidth, bool isArabic) {
    return Directionality(
      textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Row(
        children: [
          AutoSizeText(
            '${'quantity'.tr()}:',
            style: AppTextStyle.normal_16_brownLight
                .copyWith(fontSize: screenWidth * 0.05),
            minFontSize: 12,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(width: screenWidth * 0.04),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColours.brownLight),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () {
                    if (_quantity > 1) setState(() => _quantity--);
                  },
                ),
                AutoSizeText('$_quantity',
                    style: AppTextStyle.normal_16_brownLight
                        .copyWith(fontSize: screenWidth * 0.05),
                    minFontSize: 12,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    if (_quantity < _product.stock) setState(() => _quantity++);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalPrice(
      double screenWidth, bool isArabic, double totalPrice) {
    return Directionality(
      textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AutoSizeText('${'total'.tr()}:',
              style: AppTextStyle.bold_18_medium_brown
                  .copyWith(fontSize: screenWidth * 0.04),
              minFontSize: 14,
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          AutoSizeText("${totalPrice.toStringAsFixed(2)} ${'egp'.tr()}",
              style: AppTextStyle.bold_18_medium_brown
                  .copyWith(fontSize: screenWidth * 0.04),
              minFontSize: 14,
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
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
