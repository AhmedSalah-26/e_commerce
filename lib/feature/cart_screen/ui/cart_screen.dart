import 'package:auto_size_text/auto_size_text.dart';
import 'package:e_commerce/feature/cart_screen/data/models/cart_model.dart';
import 'package:e_commerce/feature/cart_screen/ui/widgets/dekivery_options.dart';
import 'package:e_commerce/feature/cart_screen/ui/widgets/empty_cart_message.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Core/Sharedwidgets/CustomButton.dart';
import '../../../Core/Theme/app_colors.dart';
import '../../../Core/Theme/app_text_style.dart';
import '../Domain/CartScreenProvider.dart';
import 'widgets/cart_screen_appbar.dart';
import 'widgets/cost_section_ui.dart';
import 'widgets/product_cart_card.dart';

class CartScreen extends StatefulWidget {
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final double baseHeight = 812.0;
  final double baseWidth = 375.0; 

  double responsiveHeight(BuildContext context, double height) {
    return MediaQuery.of(context).size.height * (height / baseHeight);
  }

  double responsiveFontSize(BuildContext context, double fontSize) {
    return MediaQuery.of(context).size.width * (fontSize / baseWidth);
  }

  @override
  Widget build(BuildContext context) {
    final cartScreenProvider = context.watch<CartProvider>(); // تحسين استدعاء Provider
    final cartItems = cartScreenProvider.getCartItems(); // تخزين العناصر في متغير
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 600;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(isWideScreen ? 32.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: responsiveHeight(context, 16)),
            const CartScreenAppBar(), // استخدام const
            Expanded(
              child: cartItems.isEmpty
                  ? const EmptyCartMessage() // فصل رسالة السلة الفارغة في Widget
                  : ListView(
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                                      itemCount: cartItems.length,
                                      itemBuilder: (context, index) {
                      CartModel cartItem = cartItems[index];
                      return ProductCardCart(
                        product: cartItem,
                        cartQuantity: cartItem.cartQuantity,
                        onRemove: () {
                          cartScreenProvider.removeFromCart(cartItem);
                        },
                        onIncreaseQuantity: () {
                          cartScreenProvider.increaseQuantity(cartItem);
                        },
                        onDecreaseQuantity: () {
                          if (cartItem.cartQuantity > 1) {
                            cartScreenProvider.decreaseQuantity(cartItem);
                          } else {
                            cartScreenProvider.removeFromCart(cartItem);
                          }
                        },
                      );
                                      },
                                    ),


                      SizedBox(height: responsiveHeight(context, 5)),
                      if (cartItems.isNotEmpty)
                        DeliveryOptions(cartScreenProvider: cartScreenProvider, isWideScreen: isWideScreen, responsiveHeight: responsiveHeight(context, 5)),
                    ],
                  ),
            ),

          ],
        ),
      ),
    );
  }
}



