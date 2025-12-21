import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_style.dart';

class OnboardingPageView extends StatelessWidget {
  final PageController pageController;
  final List<Map<String, String>> pages;
  final int currentPage;
  final ValueChanged<int> onPageChanged;
  final double imageSize;

  const OnboardingPageView({
    super.key,
    required this.pageController,
    required this.pages,
    required this.currentPage,
    required this.onPageChanged,
    required this.imageSize,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 3,
      child: PageView.builder(
        controller: pageController,
        itemCount: pages.length,
        onPageChanged: onPageChanged,
        itemBuilder: (context, index) {
          final page = pages[index];
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: imageSize,
                width: imageSize,
                child: Image.asset(
                  page['imagePath']!,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                page['title']!,
                style: AppTextStyle.bold_24_medium_brown,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  page['description']!,
                  style: AppTextStyle.normal_16_greyDark,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }
}
