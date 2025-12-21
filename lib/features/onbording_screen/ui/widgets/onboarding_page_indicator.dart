import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../core/theme/app_colors.dart';

class OnboardingPageIndicator extends StatelessWidget {
  final PageController pageController;
  final int pageCount;

  const OnboardingPageIndicator({
    super.key,
    required this.pageController,
    required this.pageCount,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Align(
        alignment: Alignment.topCenter,
        child: SmoothPageIndicator(
          controller: pageController,
          count: pageCount,
          effect: const ExpandingDotsEffect(
            dotHeight: 10,
            dotWidth: 10,
            dotColor: AppColours.greyLight,
            activeDotColor: AppColours.brownMedium,
          ),
        ),
      ),
    );
  }
}
