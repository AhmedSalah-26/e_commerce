import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../Core/Theme/app_colors.dart';
import '../../cart_screen/ui/cart_screen.dart';
import '../../favorite_page_screen/ui/favorite_page_screen.dart';
import '../../home_screen/ui/home_screen.dart';
import '../../settings/ui/settings_screen.dart';

class HomeNavigationscreen extends StatefulWidget {
  const HomeNavigationscreen({super.key});

  @override
  State<HomeNavigationscreen> createState() => _HomeNavigationscreenState();
}

class _HomeNavigationscreenState extends State<HomeNavigationscreen> {
  List<Widget> screens = [
    HomeScreen(),
    CartScreen(),
    FavoritePage(),
    SettingsScreen()
  ];
  int _bottomNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: AnimatedBottomNavigationBar(
        icons: [
          Icons.home_outlined,
          Icons.shopping_cart_outlined,
          Icons.favorite_border,
          Icons.settings_outlined,
        ],
        backgroundColor: AppColours.white,
        inactiveColor: AppColours.greyMedium,
        activeIndex: _bottomNavIndex,
        leftCornerRadius: 30,
        activeColor: AppColours.brownLight,
        rightCornerRadius: 30,

        gapLocation: GapLocation.none,
        onTap: (index) => setState(() => _bottomNavIndex = index),
        //other params
      ),
      body: screens[_bottomNavIndex],
    );
  }
}






