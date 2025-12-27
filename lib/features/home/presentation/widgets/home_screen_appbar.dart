import 'package:flutter/material.dart';

import '../../../../core/shared_widgets/search_bar.dart';

class HomeScreenAppbar extends StatelessWidget {
  const HomeScreenAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SliverAppBar(
      backgroundColor: theme.scaffoldBackgroundColor,
      scrolledUnderElevation: 0,
      toolbarHeight: screenHeight * 0.1,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: screenWidth * 0.7,
            child: const CustomSearchBar(),
          ),
          Container(
            width: screenWidth * 0.15,
            height: screenHeight * 0.06,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: theme.scaffoldBackgroundColor,
            ),
            child: IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.notifications,
                size: screenWidth * 0.06,
                color: theme.colorScheme.primary,
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
          color: theme.scaffoldBackgroundColor,
        ),
      ),
    );
  }
}
