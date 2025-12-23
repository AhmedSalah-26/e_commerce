import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/shared_widgets/skeleton_widgets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../domain/entities/product_entity.dart';
import '../cubit/products_cubit.dart';
import '../cubit/products_state.dart';
import '../pages/product_screen.dart';

class SuggestedProductsSlider extends StatefulWidget {
  final String currentProductId;
  final String? categoryId;

  const SuggestedProductsSlider({
    super.key,
    required this.currentProductId,
    this.categoryId,
  });

  @override
  State<SuggestedProductsSlider> createState() =>
      _SuggestedProductsSliderState();
}

class _SuggestedProductsSliderState extends State<SuggestedProductsSlider> {
  @override
  void initState() {
    super.initState();
    // Load products only if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<ProductsCubit>();
      final currentState = cubit.state;

      // Only load if we don't have products or if we need category-specific products
      if (currentState is! ProductsLoaded ||
          (widget.categoryId != null && currentState.products.isEmpty)) {
        if (widget.categoryId != null) {
          cubit.loadProductsByCategory(widget.categoryId!);
        } else {
          cubit.loadProducts();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductsCubit, ProductsState>(
      builder: (context, state) {
        if (state is ProductsLoading) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: ProductsGridSkeleton(itemCount: 4),
          );
        }

        if (state is ProductsLoaded) {
          final suggestedProducts = state.products
              .where((p) => p.id != widget.currentProductId)
              .take(10)
              .toList();

          if (suggestedProducts.isEmpty) {
            return const SizedBox.shrink();
          }

          final screenWidth = MediaQuery.of(context).size.width;
          final cardWidth = screenWidth * 0.38;
          final cardHeight = cardWidth * 1.5;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: screenWidth * 0.02),
                child: Text(
                  'you_may_like'.tr(),
                  style: AppTextStyle.semiBold_20_dark_brown
                      .copyWith(fontSize: screenWidth * 0.045),
                ),
              ),
              SizedBox(
                height: cardHeight,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  itemCount: suggestedProducts.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (context, index) => SizedBox(
                    width: cardWidth,
                    child: _SuggestedProductCard(
                        product: suggestedProducts[index]),
                  ),
                ),
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _SuggestedProductCard extends StatelessWidget {
  final ProductEntity product;

  const _SuggestedProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (context) => ProductScreen(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColours.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: product.images.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: product.images.first,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        memCacheWidth: 200,
                        placeholder: (_, __) => _buildPlaceholder(),
                        errorWidget: (_, __, ___) => _buildPlaceholder(),
                      )
                    : _buildPlaceholder(),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.name,
                      style: AppTextStyle.semiBold_12_dark_brown,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        if (product.hasDiscount)
                          Text(
                            '${product.price.toStringAsFixed(0)} ',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        Flexible(
                          child: Text(
                            '${product.effectivePrice.toStringAsFixed(0)} ${'egp'.tr()}',
                            style: AppTextStyle.bold_14_medium_brown,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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

  Widget _buildPlaceholder() {
    return Container(
      color: AppColours.greyLight,
      child: const Center(
        child: Icon(Icons.image_not_supported, color: Colors.grey),
      ),
    );
  }
}
