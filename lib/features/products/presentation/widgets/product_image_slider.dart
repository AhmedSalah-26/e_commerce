import 'package:fan_carousel_image_slider/fan_carousel_image_slider.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class ProductImageSlider extends StatelessWidget {
  final List<String> images;
  final double screenWidth;

  const ProductImageSlider({
    super.key,
    required this.images,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    if (images.isNotEmpty) {
      return FanCarouselImageSlider.sliderType1(
        autoPlayInterval: const Duration(seconds: 3),
        isClickable: true,
        imagesLink: images,
        imageFitMode: BoxFit.cover,
        isAssets: !images.first.startsWith('http'),
        expandImageHeight: screenWidth * 0.7,
        initalPageIndex: 0,
        autoPlay: images.length > 1,
        indicatorActiveColor: AppColours.brownLight,
        sliderHeight: screenWidth * 0.5,
        sliderWidth: screenWidth,
        expandedImageFitMode: BoxFit.contain,
        showIndicator: images.length > 1,
      );
    }
    return Container(
      height: screenWidth * 0.5,
      decoration: BoxDecoration(
        color: AppColours.greyLight,
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Center(
        child: Icon(Icons.image_not_supported, size: 80, color: Colors.grey),
      ),
    );
  }
}
