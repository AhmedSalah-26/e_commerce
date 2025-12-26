import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../../core/shared_widgets/product_card/product_grid_card.dart';
import '../../../../../core/shared_widgets/skeleton_widgets.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_style.dart';
import '../../../domain/entities/product_entity.dart';

class StoreProductsBody extends StatelessWidget {
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final List<ProductEntity> products;
  final List<ProductEntity> filteredProducts;
  final bool hasActiveFilters;
  final ScrollController scrollController;
  final VoidCallback onRetry;
  final VoidCallback onClearFilters;

  const StoreProductsBody({
    super.key,
    required this.isLoading,
    required this.isLoadingMore,
    this.error,
    required this.products,
    required this.filteredProducts,
    required this.hasActiveFilters,
    required this.scrollController,
    required this.onRetry,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const ProductsGridSkeleton();

    if (error != null) return _buildError();

    if (products.isEmpty) return _buildEmpty();

    if (filteredProducts.isEmpty) return _buildNoResults();

    return _buildGrid();
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          Text(error!, style: AppTextStyle.normal_14_greyDark),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onRetry, child: Text('retry'.tr())),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          Text('no_products'.tr(), style: AppTextStyle.normal_14_greyDark),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 48, color: AppColours.greyLight),
          const SizedBox(height: 12),
          Text('no_results'.tr(), style: AppTextStyle.semiBold_14_dark_brown),
          const SizedBox(height: 4),
          Text('try_different_search'.tr(),
              style: AppTextStyle.normal_12_greyDark),
          if (hasActiveFilters) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: onClearFilters,
              child: Text('clear_filters'.tr(),
                  style: const TextStyle(color: AppColours.primaryColor)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: filteredProducts.length + (isLoadingMore ? 2 : 0),
      itemBuilder: (_, index) {
        if (index >= filteredProducts.length) {
          return const Center(child: CircularProgressIndicator());
        }
        return ProductGridCard(product: filteredProducts[index]);
      },
    );
  }
}
