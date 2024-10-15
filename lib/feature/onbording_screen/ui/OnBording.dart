import 'package:e_commerce/feature/onbording_screen/ui/widgets/onboarding_action_buttons.dart';
import 'package:e_commerce/feature/onbording_screen/ui/widgets/onboarding_pageIndicator.dart';
import 'package:e_commerce/feature/onbording_screen/ui/widgets/onboarding_page_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../Core/Theme/app_colors.dart';
import '../../../Core/Theme/app_text_style.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  _OnboardingState createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  int _currentPage = 0;
  late PageController _pageController;

  final List<Map<String, String>> _pages = [
    {
      'title': 'مرحبا بكم فى متجر زهره التمور',
      'description': 'اكتشفوا معنا أجود أنواع التمور والمنتجات الفريدة في متجر زهره التمور. نحن نقدم لكم أفضل المنتجات الطبيعية المتميزة بأعلى جودة لتلبية احتياجاتكم.',
      'imagePath': 'assets/on_bording/Tosca & Brown Retro Minimalist Ajwa Dates Badge Logo (2).png',
    },
    {
      'title': 'جودة وأصالة في كل تمرة',
      'description': 'استمتعوا بمذاق لا مثيل له مع تشكيلة رائعة من أفخر أنواع التمور المختارة بعناية لتضفي لحظات من السعادة والتميز.',
      'imagePath': 'assets/on_bording/1726404072024.png',
    },
    {
      'title': 'ابدأ الآن',
      'description': 'لنبدأ الآن واستكشفوا كل ما نقدمه لكم.',
      'imagePath': 'assets/on_bording/Picsart_24-09-15_19-19-18-148.png',
    },
  ];

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

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      _skipOnboarding();
    }
  }

  void _skipOnboarding() {
    GoRouter.of(context).go('/LoginScreen');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            double imageSize = constraints.maxWidth * 0.6; // Adjust size based on screen width

            return Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage('assets/on_bording/WhatsApp Image 2024-09-15 at 7.30.26 PM.jpeg'),
                ),
              ),
              width: double.infinity,
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  OnboardingPageView(
                    pageController: _pageController,
                    pages: _pages,
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
                    pageCount: _pages.length,
                  ),
                  SizedBox(height: 20),
                  OnboardingActionButtons(
                    currentPage: _currentPage,
                    onNextPage: _nextPage,
                    onSkip: _skipOnboarding,
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



