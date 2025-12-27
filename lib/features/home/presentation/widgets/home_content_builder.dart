import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/shared_widgets/network_error_widget.dart';
import '../../../../core/shared_widgets/skeleton_widgets.dart';
import '../../../../core/utils/error_helper.dart';
import '../../../categories/presentation/cubit/categories_cubit.dart';
import '../../../categories/presentation/cubit/categories_state.dart';
import '../../../products/presentation/cubit/products_cubit.dart';
import '../../../products/presentation/cubit/products_state.dart';
import '../cubit/home_sliders_cubit.dart';
import 'images_card_slider.dart';
import 'category_row.dart';
import 'products_grid.dart';
import 'horizontal_products_slider.dart';

class HomeContentBuilder {
  /// Check if there's a network error in products state
  static bool hasNetworkError(BuildContext context) {
    final state = context.read<ProductsCubit>().state;
    return state is ProductsError;
  }

  /// Build full screen error widget
  static Widget buildFullScreenError({
    required BuildContext context,
    required String message,
    required VoidCallback onRetry,
  }) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: NetworkErrorWidget(
        message: message,
        onRetry: onRetry,
      ),
    );
  }

  static List<Widget> buildHomeContent({
    required BuildContext context,
    required List<String> sliderImages,
    required String? selectedCategoryId,
    required Function(String?) onCategorySelected,
    required VoidCallback onOffersSelected,
    required bool isOffersSelected,
  }) {
    final theme = Theme.of(context);

    return [
      // Check for network error first - show full screen error
      BlocBuilder<ProductsCubit, ProductsState>(
        builder: (context, state) {
          if (state is ProductsError) {
            return buildFullScreenError(
              context: context,
              message: ErrorHelper.getUserFriendlyMessage(state.message),
              onRetry: () => context.read<ProductsCubit>().loadProducts(),
            );
          }

          // Normal content when no error
          return SliverToBoxAdapter(
            child: Column(
              children: <Widget>[
                ImagesCard(images: sliderImages),
                const SizedBox(height: 10),
                BlocBuilder<HomeSlidersCubit, HomeSlidersState>(
                  builder: (context, slidersState) {
                    return HorizontalProductsSlider(
                      title: 'best_deals'.tr(),
                      products: slidersState.discountedProducts,
                      isLoading: slidersState.isLoadingDiscounted,
                    );
                  },
                ),
                const SizedBox(height: 10),
                BlocBuilder<HomeSlidersCubit, HomeSlidersState>(
                  builder: (context, slidersState) {
                    return HorizontalProductsSlider(
                      title: 'new_arrivals'.tr(),
                      products: slidersState.newestProducts,
                      isLoading: slidersState.isLoadingNewest,
                    );
                  },
                ),
                const SizedBox(height: 10),
                BlocBuilder<CategoriesCubit, CategoriesState>(
                  builder: (context, catState) {
                    if (catState is CategoriesLoading) {
                      return const CategoriesRowSkeleton();
                    }
                    if (catState is CategoriesLoaded) {
                      return HorizontalCategoriesView(
                        categories: catState.categories,
                        selectedCategoryId: selectedCategoryId,
                        isOffersSelected: isOffersSelected,
                        onCategorySelected: onCategorySelected,
                        onOffersSelected: onOffersSelected,
                      );
                    }
                    if (catState is CategoriesError) {
                      return Center(
                          child: Text(
                              ErrorHelper.getUserFriendlyMessage(
                                  catState.message),
                              style: TextStyle(
                                  color: theme.colorScheme.onSurface)));
                    }
                    return const SizedBox.shrink();
                  },
                ),
                const SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
      // Products grid - only show when no error
      BlocBuilder<ProductsCubit, ProductsState>(
        builder: (context, state) {
          // Don't show anything if there's an error (handled above)
          if (state is ProductsError) {
            return const SliverToBoxAdapter(child: SizedBox.shrink());
          }
          if (state is ProductsLoading) {
            return const SliverToBoxAdapter(
                child: ProductsGridSkeleton(itemCount: 6));
          }
          if (state is ProductsLoaded) {
            if (state.products.isEmpty) {
              return SliverToBoxAdapter(
                child: SizedBox(
                  height: 200,
                  child: Center(
                    child: Text('no_products'.tr(),
                        style:
                            const TextStyle(fontSize: 18, color: Colors.grey)),
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
                          child: Text('no_more_products'.tr(),
                              style: const TextStyle(color: Colors.grey))),
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          }
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        },
      ),
    ];
  }
}
