import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/shared_widgets/skeleton_widgets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../categories/presentation/cubit/categories_cubit.dart';
import '../../../categories/presentation/cubit/categories_state.dart';
import '../../../products/presentation/cubit/products_cubit.dart';
import '../../../products/presentation/cubit/products_state.dart';
import 'images_card_slider.dart';
import 'category_row.dart';
import 'products_grid.dart';

class HomeContentBuilder {
  static List<Widget> buildHomeContent({
    required BuildContext context,
    required List<String> sliderImages,
    required String? selectedCategoryId,
    required Function(String?) onCategorySelected,
  }) {
    return [
      SliverToBoxAdapter(
        child: Column(
          children: <Widget>[
            ImagesCard(images: sliderImages),
            const SizedBox(height: 10),
            BlocBuilder<CategoriesCubit, CategoriesState>(
              builder: (context, state) {
                if (state is CategoriesLoading) {
                  return const CategoriesRowSkeleton();
                }
                if (state is CategoriesLoaded) {
                  return HorizontalCategoriesView(
                    categories: state.categories,
                    selectedCategoryId: selectedCategoryId,
                    onCategorySelected: onCategorySelected,
                  );
                }
                if (state is CategoriesError) {
                  return Center(
                    child: Text(
                      state.message,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
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
              child: ProductsGridSkeleton(itemCount: 6),
            );
          }
          if (state is ProductsLoaded) {
            if (state.products.isEmpty) {
              return SliverToBoxAdapter(
                child: SizedBox(
                  height: 200,
                  child: Center(
                    child: Text(
                      'no_products'.tr(),
                      style: const TextStyle(fontSize: 18, color: Colors.grey),
                    ),
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
          if (state is ProductsError) {
            return SliverToBoxAdapter(
              child: SizedBox(
                height: 200,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        state.message,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          context.read<ProductsCubit>().loadProducts();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColours.brownLight,
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
