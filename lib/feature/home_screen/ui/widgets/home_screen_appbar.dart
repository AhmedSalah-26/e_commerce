import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../Core/Sharedwidgets/SearchBar.dart';
import '../../../../Core/Theme/app_colors.dart';

class HomeScreenAppbar extends StatelessWidget {
  const HomeScreenAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    // Get screen width for responsive design
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SliverAppBar(
      backgroundColor: AppColours.white,
      scrolledUnderElevation: 0,
      toolbarHeight: screenHeight * 0.1, // Adjust toolbar height based on screen height
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Custom search bar
          SizedBox(
            width: screenWidth * 0.7, // Adjust width based on screen width
            child: const CustomSearchBar(),
          ),
          // Notifications icon
          Container(
            width: screenWidth * 0.15, // Adjust width based on screen width
            height: screenHeight * 0.06, // Adjust height based on screen height
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColours.greyLighter,
            ),
            child: IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.notifications,
                size: screenWidth * 0.06, // Adjust icon size based on screen width
                color: AppColours.brownLight,
              ),
            ),
          ),
        ],
      ),
      floating: true,
      pinned: false,
      snap: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: AppColours.white, // Adjust the background color as needed
        ),
      ),
    );
  }
}
