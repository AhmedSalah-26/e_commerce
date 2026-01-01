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
        clipBehavior: Clip.none,
        itemBuilder: (context, index) {
          final page = pages[index];
          final imagePath = page['imagePath'];
          final useIcon = imagePath == null || imagePath.isEmpty;

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: imageSize,
                width: imageSize,
                child: useIcon
                    ? _buildShoppingIcon(imageSize)
                    : Image.asset(
                        imagePath,
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

  Widget _buildShoppingIcon(double size) {
    return Container(
      width: size * 0.7,
      height: size * 0.7,
      decoration: BoxDecoration(
        color: const Color(0xFF8B4513).withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.shopping_bag_outlined,
        size: size * 0.4,
        color: const Color(0xFF8B4513),
      ),
    );
  }
}
