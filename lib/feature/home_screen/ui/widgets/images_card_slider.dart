import 'dart:async';
import 'package:e_commerce/Core/Theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart'; // For the page indicator

class ImagesCard extends StatelessWidget {
  final List<String> images;

  const ImagesCard({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    return _ImagesCardBody(images: images);
  }
}

class _ImagesCardBody extends StatefulWidget {
  final List<String> images;

  const _ImagesCardBody({required this.images});

  @override
  _ImagesCardBodyState createState() => _ImagesCardBodyState();
}

class _ImagesCardBodyState extends State<_ImagesCardBody> {
  late PageController _pageController;
  late Timer _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    // Auto-slide every 7 seconds
    _timer = Timer.periodic(Duration(seconds: 7), (Timer timer) {
      if (_currentPage < widget.images.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 170,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,
            onPageChanged: (int index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.91,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: AssetImage(widget.images[index]),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 10),
        SmoothPageIndicator(
          controller: _pageController,  // PageController
          count: widget.images.length,
          effect: ExpandingDotsEffect(
            dotHeight: 8,
            dotWidth: 8,
            activeDotColor: AppColours.brownLight,
          ),  // Indicator style
        ),
      ],
    );
  }
}
