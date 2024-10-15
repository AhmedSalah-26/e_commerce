import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Core/Theme/app_colors.dart';
import '../../../Core/Theme/app_text_style.dart';
import '../../../Core/Sharedwidgets/product_grid_card.dart'; // Ensure you have the correct path for your product_grid_card.dart
import '../../home_screen/data/models/ProductModel.dart';
import '../../home_screen/ui/home_screen.dart'; // Ensure you have the correct path for your home_screen.dart
import '../../product_screen/ui/product_screen.dart'; // Ensure you have the correct path for your product_screen.dart
import '../../product_screen/ui/product_screen.dart';
import '../Domain/favorite_screen_provider.dart'; // This import seems to be duplicated, ensure you only have it once

class FavoritePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final favoriteProvider = Provider.of<FavoriteScreenProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 600
        ? 3
        : 2; // Adjust number of columns based on screen width
    final childAspectRatio = screenWidth > 600
        ? 0.45
        : 0.55; // Adjust aspect ratio for larger screens
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'التفضيلات',
          style: AppTextStyle.semiBold_20_dark_brown.copyWith(
            fontSize: 24,
            color: AppColours.brownMedium,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: favoriteProvider.getFavoriteProducts().isEmpty
            ? Center(child: Text('لا يوجد منتجات في التفضيلات',style: AppTextStyle.normal_16_greyDark,))
            : GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                  childAspectRatio: childAspectRatio,
                ),
                itemCount: favoriteProvider.getFavoriteProducts().length,
                itemBuilder: (context, index) {
                  final product = favoriteProvider.getFavoriteProducts()[index];
                  return ProductGridCard(product: product);
                },
              ),
      ),
    );
  }
}
