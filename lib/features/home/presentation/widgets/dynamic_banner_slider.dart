import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../banners/domain/entities/banner_entity.dart';

class DynamicBannerSlider extends StatefulWidget {
  final List<BannerEntity> banners;

  const DynamicBannerSlider({super.key, required this.banners});

  @override
  State<DynamicBannerSlider> createState() => _DynamicBannerSliderState();
}

class _DynamicBannerSliderState extends State<DynamicBannerSlider> {
  late PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 7), (Timer timer) {
      if (!mounted) return;
      if (_currentPage < widget.banners.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _handleBannerTap(BannerEntity banner) {
    switch (banner.linkType) {
      case BannerLinkType.product:
        if (banner.linkValue != null) {
          context.push('/product/${banner.linkValue}');
        }
        break;
      case BannerLinkType.category:
        if (banner.linkValue != null) {
          context.push('/all-categories?categoryId=${banner.linkValue}');
        }
        break;
      case BannerLinkType.offers:
        if (banner.linkValue != null) {
          context.push('/offers/${banner.linkValue}');
        }
        break;
      case BannerLinkType.url:
        // Could open external URL
        break;
      case BannerLinkType.none:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        SizedBox(
          height: 170,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.banners.length,
            onPageChanged: (int index) => setState(() => _currentPage = index),
            itemBuilder: (BuildContext context, int index) {
              final banner = widget.banners[index];
              return GestureDetector(
                onTap: () => _handleBannerTap(banner),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.91,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: CachedNetworkImage(
                      imageUrl: banner.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Container(
                          color: Colors.white,
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: const Icon(Icons.broken_image, size: 50),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        SmoothPageIndicator(
          controller: _pageController,
          count: widget.banners.length,
          effect: ExpandingDotsEffect(
            dotHeight: 8,
            dotWidth: 8,
            activeDotColor: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
