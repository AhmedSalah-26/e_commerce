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
import 'horizontal_products_slider.dart';
import 'flash_sale_slider.dart';

class HomeSliders extends StatelessWidget {
  const HomeSliders({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
        const SizedBox(height: 4),
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
