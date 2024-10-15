 import 'package:e_commerce/feature/home_screen/Domain/home_screen_provider.dart';
import 'package:e_commerce/feature/home_screen/ui/widgets/grid_view_ui.dart';
import 'package:e_commerce/feature/home_screen/ui/widgets/home_screen_appbar.dart';
import 'package:e_commerce/feature/home_screen/ui/widgets/images_card_slider.dart';
import 'package:e_commerce/Core/Sharedwidgets/product_grid_card.dart';
import 'package:e_commerce/feature/home_screen/ui/widgets/product_list_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../Core/Sharedwidgets/SearchBar.dart';
import 'widgets/category_row.dart';
import '../../../Core/Theme/app_colors.dart';
import '../data/models/ProductModel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = "الكل";
  @override
  Widget build(BuildContext context) {
    final homeScreenProvider = Provider.of<HomeScreenProvider>(context, listen: true);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Scaffold(
          backgroundColor: AppColours.white,
          body: CustomScrollView(
            slivers: <Widget>[
              HomeScreenAppbar(),
              SliverToBoxAdapter(
                child: Column(
                  children: <Widget>[
                    ImagesCard(
                      images: homeScreenProvider.getImages(),
                    ),
                    const SizedBox(height: 10),
                    HorizontalCategoriesView(
                      categories: homeScreenProvider.getCategories(),
                      onCategorySelected: (category) {
                        setState(() {
                          selectedCategory = category;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    GridProductsUi(
                      products: homeScreenProvider.getfilteredProducts(selectedCategory),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}