import 'package:flutter/cupertino.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../Core/Theme/app_colors.dart';

class OnboardingPageIndicator extends StatelessWidget {
  final PageController pageController;
  final int pageCount;

  const OnboardingPageIndicator({
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
          effect: ExpandingDotsEffect(
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
