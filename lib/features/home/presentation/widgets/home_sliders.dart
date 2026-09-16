import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/di/injection_container.dart';
import '../../../banners/data/datasources/banner_remote_datasource.dart';
import '../../../banners/presentation/cubit/banners_cubit.dart';
import '../cubit/home_sliders_cubit.dart';
import 'dynamic_banner_slider.dart';
import 'circular_categories_row.dart';
import 'horizontal_products_slider.dart';
import 'flash_sale_slider.dart';

class HomeSliders extends StatelessWidget {
  final String? selectedCategoryId;
  final Function(String?)? onCategorySelected;
  final VoidCallback? onAllSelected;

  const HomeSliders({
    super.key,
    this.selectedCategoryId,
    this.onCategorySelected,
    this.onAllSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. Dynamic Banners Slider
        BlocProvider(
          create: (_) {
            final cubit = BannersCubit(sl<BannerRemoteDatasource>());
            cubit.setLocale(context.locale.languageCode);
            cubit.loadActiveBanners();
            return cubit;
          },
          child: BlocBuilder<BannersCubit, BannersState>(
            builder: (context, state) {
              if (state is BannersLoaded && state.banners.isNotEmpty) {
                return DynamicBannerSlider(banners: state.banners);
              }
              if (state is BannersLoading) {
                return _buildBannerShimmer();
              }
              // No banners available
              return const SizedBox.shrink();
            },
          ),
        ),

        // 2. Circular Categories Row directly below the Banner
        CircularCategoriesRow(
          selectedCategoryId: selectedCategoryId,
          onCategorySelected: onCategorySelected,
          onAllSelected: onAllSelected,
        ),

        const SizedBox(height: 6),

        // 3. Flash Sale Section
        BlocBuilder<HomeSlidersCubit, HomeSlidersState>(
          builder: (context, state) {
            if (state.flashSaleProducts.isEmpty && !state.isLoadingFlashSale) {
              return const SizedBox.shrink();
            }
            return FlashSaleSlider(
              products: state.flashSaleProducts,
              isLoading: state.isLoadingFlashSale,
              onViewAll: () => context.push('/offers/flash-sale'),
            );
          },
        ),

        const SizedBox(height: 4),

        // 4. Best Deals Section
        BlocBuilder<HomeSlidersCubit, HomeSlidersState>(
          builder: (context, state) {
            return HorizontalProductsSlider(
              title: 'best_deals'.tr(),
              subtitle: 'best_deals_subtitle'.tr(),
              products: state.discountedProducts,
              isLoading: state.isLoadingDiscounted,
              backgroundColor: const Color(0xFF4FC3F7).withValues(alpha: 0.15),
              onViewAll: () => context.push('/offers/best-deals'),
            );
          },
        ),

        const SizedBox(height: 4),

        // 5. New Arrivals Section
        BlocBuilder<HomeSlidersCubit, HomeSlidersState>(
          builder: (context, state) {
            return HorizontalProductsSlider(
              title: 'new_arrivals'.tr(),
              subtitle: 'new_arrivals_subtitle'.tr(),
              products: state.newestProducts,
              isLoading: state.isLoadingNewest,
              backgroundColor: const Color(0xFFAED581).withValues(alpha: 0.2),
              onViewAll: () => context.push('/offers/new-arrivals'),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBannerShimmer() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          height: 170,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
