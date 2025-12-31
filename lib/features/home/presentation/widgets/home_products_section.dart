import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/shared_widgets/skeleton_widgets.dart';
import '../../../products/presentation/cubit/products_cubit.dart';
import '../../../products/presentation/cubit/products_state.dart';
import 'products_grid.dart';

class HomeProductsSection extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onRetry;

  const HomeProductsSection({
    super.key,
    required this.isLoading,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    // Show shimmer when loading
    if (isLoading) {
      return const SliverToBoxAdapter(
        child: ProductsGridSkeleton(itemCount: 6),
      );
    }

    return BlocBuilder<ProductsCubit, ProductsState>(
      builder: (context, state) {
        if (state is ProductsError) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: onRetry,
                    child: Text('retry'.tr()),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is ProductsLoading || state is ProductsInitial) {
          return const SliverToBoxAdapter(
            child: ProductsGridSkeleton(itemCount: 6),
          );
        }

        if (state is ProductsLoaded) {
          if (state.products.isEmpty) {
            return SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inventory_2_outlined,
                        size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text('no_products'.tr()),
                  ],
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

        return const SliverToBoxAdapter(
          child: ProductsGridSkeleton(itemCount: 6),
        );
      },
    );
  }
}
