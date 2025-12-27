import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

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
    final theme = Theme.of(context);
    return Expanded(
      child: Align(
        alignment: Alignment.topCenter,
        child: SmoothPageIndicator(
          controller: pageController,
          count: pageCount,
          effect: ExpandingDotsEffect(
            dotHeight: 10,
            dotWidth: 10,
            dotColor: theme.colorScheme.outline,
            activeDotColor: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
