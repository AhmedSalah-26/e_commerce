import 'package:flutter/cupertino.dart';

import '../../../../Core/Theme/app_text_style.dart';

class OnboardingPageView extends StatelessWidget {
  final PageController pageController;
  final List<Map<String, String>> pages;
  final int currentPage;
  final ValueChanged<int> onPageChanged;
  final double imageSize;

  const OnboardingPageView({
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
              Container(
                height: imageSize,
                width: imageSize,
                child: Image.asset(
                  page['imagePath']!,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 20),
              Text(
                page['title']!,
                style: AppTextStyle.bold_24_medium_brown,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  page['description']!,
                  style: AppTextStyle.normal_16_greyDark,
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }
}
