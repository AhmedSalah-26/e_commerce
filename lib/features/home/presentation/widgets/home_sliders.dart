import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../cubit/home_sliders_cubit.dart';
import 'images_card_slider.dart';
import 'horizontal_products_slider.dart';
import 'flash_sale_slider.dart';

class HomeSliders extends StatelessWidget {
  const HomeSliders({super.key});

  static const List<String> sliderImages = [
    "assets/slider/V1.png",
    "assets/slider/V2.png",
    "assets/slider/V3.png",
    "assets/slider/V4.png",
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ImagesCard(images: sliderImages),
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
}
