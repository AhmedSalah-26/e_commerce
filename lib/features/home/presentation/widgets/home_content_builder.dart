import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      SliverToBoxAdapter(
        child: Column(
          children: <Widget>[
            ImagesCard(images: sliderImages),
            const SizedBox(height: 10),
            BlocBuilder<HomeSlidersCubit, HomeSlidersState>(
              builder: (context, state) {
                return HorizontalProductsSlider(
                  title: 'best_deals'.tr(),
                  products: state.discountedProducts,
                  isLoading: state.isLoadingDiscounted,
                );
              },
            ),
            const SizedBox(height: 10),
            BlocBuilder<HomeSlidersCubit, HomeSlidersState>(
              builder: (context, state) {
                return HorizontalProductsSlider(
                  title: 'new_arrivals'.tr(),
                  products: state.newestProducts,
                  isLoading: state.isLoadingNewest,
                );
              },
            ),
            const SizedBox(height: 10),
            BlocBuilder<CategoriesCubit, CategoriesState>(
              builder: (context, state) {
                if (state is CategoriesLoading)
                  return const CategoriesRowSkeleton();
                if (state is CategoriesLoaded) {
                  return HorizontalCategoriesView(
                    categories: state.categories,
                    selectedCategoryId: selectedCategoryId,
                    isOffersSelected: isOffersSelected,
                    onCategorySelected: onCategorySelected,
                    onOffersSelected: onOffersSelected,
                  );
                }
                if (state is CategoriesError) {
                  return Center(
                      child: Text(
                          ErrorHelper.getUserFriendlyMessage(state.message),
                          style:
                              TextStyle(color: theme.colorScheme.onSurface)));
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
      BlocBuilder<ProductsCubit, ProductsState>(
        builder: (context, state) {
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
          if (state is ProductsError) {
            return SliverToBoxAdapter(
              child: SizedBox(
                height: 200,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.wifi_off_rounded,
                        size: 48,
                        color: theme.colorScheme.error.withValues(alpha: 0.7),
                      ),
                      const SizedBox(height: 12),
                      Text(ErrorHelper.getUserFriendlyMessage(state.message),
                          style: TextStyle(color: theme.colorScheme.onSurface),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () =>
                            context.read<ProductsCubit>().loadProducts(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: Text('retry'.tr()),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        },
      ),
    ];
  }
}
