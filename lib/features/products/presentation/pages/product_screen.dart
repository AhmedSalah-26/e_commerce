import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/shared_widgets/custom_button.dart';
import '../../../../core/shared_widgets/flash_sale_banner.dart';
import '../../../../core/shared_widgets/skeleton_widgets.dart';
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
import '../../../product_reports/presentation/widgets/report_product_dialog.dart';
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

  Future<void> _onFlashSaleExpired() async {
    try {
      final datasource = sl<ProductRemoteDataSource>();
      await datasource.cleanupExpiredFlashSaleForProduct(_product.id);
    } catch (_) {}

    await _loadFullProduct();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    double totalPrice = _quantity * _product.effectivePrice;
    double screenWidth = MediaQuery.of(context).size.width;
    final isArabic = context.locale.languageCode == 'ar';

    // Check if suspended by admin (show blocked page)
    if (_product.isSuspended && !_isLoading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: theme.colorScheme.primary),
            onPressed: () => _handleBack(context),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.block,
                    size: 64,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  isArabic ? 'منتج محظور' : 'Product Blocked',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _product.suspensionReason ??
                      (isArabic
                          ? 'هذا المنتج محظور من الإدارة'
                          : 'This product is blocked by admin'),
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () => _handleBack(context),
                  icon: const Icon(Icons.arrow_back),
                  label: Text(isArabic ? 'العودة' : 'Go Back'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Check if inactive by merchant (show details with unavailable badge)
    final isInactive = !_product.isActive;

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<ReviewsCubit>()),
        BlocProvider(create: (context) => sl<ProductsCubit>()),
      ],
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        resizeToAvoidBottomInset: false,
        appBar: _buildAppBar(context),
        body: _isLoading
            ? const ProductScreenSkeleton()
            : Stack(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    child: ListView(
                      children: [
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
                        if (isInactive) ...[
                          _buildUnavailableBadge(screenWidth, isArabic),
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

  Widget _buildUnavailableBadge(double screenWidth, bool isArabic) {
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
            isArabic ? 'غير متوفر حالياً' : 'Currently Unavailable',
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
    final theme = Theme.of(context);
    return BlocSelector<FavoritesCubit, FavoritesState, bool>(
      selector: (state) =>
          state is FavoritesLoaded && state.isFavorite(_product.id),
      builder: (context, isFav) {
        return IconButton(
          onPressed: () => _actions.toggleFavorite(context, _product.id),
          icon: Icon(
            isFav ? Icons.favorite : Icons.favorite_border,
            color: theme.colorScheme.primary,
            size: screenWidth * 0.07,
          ),
        );
      },
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    final locale = context.locale.languageCode;

    return AppBar(
      backgroundColor: theme.scaffoldBackgroundColor,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: theme.colorScheme.primary),
        onPressed: () => _handleBack(context),
      ),
      actions: [
        IconButton(
          onPressed: () => _shareProduct(locale),
          icon: Icon(Icons.share_outlined, color: theme.colorScheme.primary),
        ),
        IconButton(
          onPressed: () => _reportProduct(context),
          icon: Icon(Icons.flag_outlined, color: theme.colorScheme.primary),
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
                    Icon(Icons.shopping_cart_outlined,
                        color: theme.colorScheme.primary),
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

  void _shareProduct(String locale) {
    final shareText = ShareUtils.getProductShareText(_product, locale);
    Share.share(shareText);
  }

  void _reportProduct(BuildContext context) {
    if (!_actions.checkLoginForReport(context)) return;

    ReportProductDialog.show(
      context,
      productId: _product.id,
      productName: _product.name,
    );
  }

  Widget _buildAddToCartButton(BuildContext context, bool isInactive) {
    final theme = Theme.of(context);
    final isArabic = context.locale.languageCode == 'ar';

    // If inactive, show unavailable button
    if (isInactive) {
      return Positioned(
        bottom: 16,
        left: 16,
        right: 16,
        child: CustomButton(
          color: Colors.grey,
          onPressed: () {},
          label: isArabic ? 'غير متوفر' : 'Unavailable',
        ),
      );
    }

    final isOutOfStock = _product.isOutOfStock;
    final buttonLabel = isOutOfStock ? 'out_of_stock'.tr() : 'add_to_cart'.tr();

    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: CustomButton(
        color: isOutOfStock ? Colors.grey : theme.colorScheme.primary,
        onPressed: isOutOfStock
            ? () => _actions.showOutOfStock(context)
            : () => _actions.addToCart(context, _product.id, _quantity),
        label: buttonLabel,
      ),
    );
  }
}
