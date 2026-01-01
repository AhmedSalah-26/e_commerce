import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/shared_widgets/flash_sale_banner.dart';
import '../../../../../core/shared_widgets/skeleton_widgets.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../../reviews/presentation/cubit/reviews_cubit.dart';
import '../../../../reviews/presentation/widgets/review_widgets/reviews_section.dart';
import '../../widgets/suggested_products_slider.dart';
import '../../widgets/product_image_slider.dart';
import '../../widgets/product_info_section.dart';
import '../../widgets/product_store_info.dart';
import '../../widgets/product_details_widgets.dart';

class ProductScreenBody extends StatelessWidget {
  final ProductEntity product;
  final int quantity;
  final bool isLoading;
  final bool isRtl;
  final Function(int) onQuantityChanged;
  final VoidCallback onIncrementQuantity;
  final VoidCallback onDecrementQuantity;

  const ProductScreenBody({
    super.key,
    required this.product,
    required this.quantity,
    required this.isLoading,
    required this.isRtl,
    required this.onQuantityChanged,
    required this.onIncrementQuantity,
    required this.onDecrementQuantity,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SingleChildScrollView(
        child: Column(
          children: [
            SkeletonContainer(height: 300),
            SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  SkeletonContainer(height: 24, width: double.infinity),
                  SizedBox(height: 8),
                  SkeletonContainer(height: 20, width: 200),
                  SizedBox(height: 16),
                  SkeletonContainer(height: 100, width: double.infinity),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Flash Sale Banner
          if (product.isFlashSale && product.flashSaleEndTime != null)
            FlashSaleBanner(
              endTime: product.flashSaleEndTime!,
              isRtl: isRtl,
            ),

          // Product Images
          ProductImageSlider(
            images: product.images,
            isRtl: isRtl,
          ),

          // Product Info
          ProductInfoSection(
            product: product,
            quantity: quantity,
            isRtl: isRtl,
            onIncrementQuantity: onIncrementQuantity,
            onDecrementQuantity: onDecrementQuantity,
          ),

          const SizedBox(height: 16),

          // Store Info
          ProductStoreInfo(
            product: product,
            isRtl: isRtl,
          ),

          const SizedBox(height: 16),

          // Product Details
          ProductDetailsWidgets(
            product: product,
            isRtl: isRtl,
          ),

          const SizedBox(height: 24),

          // Reviews Section
          BlocProvider(
            create: (context) => ReviewsCubit()..loadReviews(product.id),
            child: ReviewsSection(
              productId: product.id,
              isRtl: isRtl,
            ),
          ),

          const SizedBox(height: 24),

          // Suggested Products
          SuggestedProductsSlider(
            categoryId: product.categoryId,
            currentProductId: product.id,
            isRtl: isRtl,
          ),

          const SizedBox(height: 100), // Space for bottom bar
        ],
      ),
    );
  }
}
