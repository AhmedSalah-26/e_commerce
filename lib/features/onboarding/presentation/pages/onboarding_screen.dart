import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/shared_widgets/language_toggle_button.dart';
import '../widgets/onboarding_action_buttons.dart';
import '../widgets/onboarding_page_indicator.dart';
import '../widgets/onboarding_page_view.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentPage = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<Map<String, String>> _getPages(bool isRtl) {
    return [
      {
        'title': isRtl
            ? 'مرحباً بكم في متجر زهرة التمور'
            : 'Welcome to Zahret Al-Tamoor',
        'description': isRtl
            ? 'اكتشفوا معنا أجود أنواع التمور والمنتجات الفريدة. نقدم لكم أفضل المنتجات الطبيعية بأعلى جودة.'
            : 'Discover the finest dates and unique products with us. We offer the best natural products with the highest quality.',
        'imagePath': 'assets/on_bording/logo.png',
      },
      {
        'title': isRtl
            ? 'جودة وأصالة في كل تمرة'
            : 'Quality & Authenticity in Every Date',
        'description': isRtl
            ? 'استمتعوا بمذاق لا مثيل له مع تشكيلة رائعة من أفخر أنواع التمور المختارة بعناية.'
            : 'Enjoy an unmatched taste with a wonderful selection of the finest carefully selected dates.',
        'imagePath': 'assets/on_bording/1726404072024.png',
      },
      {
        'title': isRtl ? 'ابدأ الآن' : 'Get Started',
        'description': isRtl
            ? 'لنبدأ الآن واستكشفوا كل ما نقدمه لكم من منتجات مميزة.'
            : 'Let\'s start now and explore all the special products we offer.',
        'imagePath': 'assets/on_bording/onboarding3.png',
      },
    ];
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = context.locale.languageCode == 'ar';
    final pages = _getPages(isRtl);

    return SafeArea(
      child: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            final imageSize = constraints.maxWidth * 0.6;

            return Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage(
                      'assets/on_bording/WhatsApp Image 2024-09-15 at 7.30.26 PM.jpeg'),
                ),
              ),
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Align(
                    alignment: isRtl ? Alignment.topLeft : Alignment.topRight,
                    child: const LanguageToggleButton(),
                  ),
                  const SizedBox(height: 8),
                  OnboardingPageView(
                    pageController: _pageController,
                    pages: pages,
                    currentPage: _currentPage,
                    onPageChanged: (page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    imageSize: imageSize,
                  ),
                  OnboardingPageIndicator(
                    pageController: _pageController,
                    pageCount: pages.length,
                  ),
                  const SizedBox(height: 20),
                  OnboardingActionButtons(
                    currentPage: _currentPage,
                    totalPages: pages.length,
                    onNextPage: _nextPage,
                    onSkip: _completeOnboarding,
                    isRtl: isRtl,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
