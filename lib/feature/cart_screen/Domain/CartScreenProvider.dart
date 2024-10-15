import 'package:e_commerce/feature/cart_screen/data/models/cart_model.dart';
import 'package:flutter/material.dart';

import '../../../Core/Sharedwidgets/tost.dart';
import '../../home_screen/data/models/ProductModel.dart';
import '../data/repo/cart_repo.dart';

class CartProvider extends ChangeNotifier {
  CartRepository _cartItems = CartRepository();
  String _selectedDeliveryOption = 'Home Delivery'; // تعيين الخيار الافتراضي
  double _deliveryFee = 20.0; // رسوم التوصيل الافتراضية

  String getDeliveryOption() => _selectedDeliveryOption;

  void setDeliveryOption(String option) {
    _selectedDeliveryOption = option;
    notifyListeners();
  }

  double getDeliveryFee() => _deliveryFee;

  void setDeliveryFee(double fee) {
    _deliveryFee = fee;
    notifyListeners();
  }

  List<CartModel> getCartItems() {
    return _cartItems.getCartItems();
    notifyListeners();
  }

  void removeFromCart(CartModel cartItem) {
    _cartItems.removeFromCart(cartItem);
    notifyListeners();
    Tost.showCustomToast('حذف من السلة', backgroundColor: Colors.red, textColor: Colors.white);

  }

  void increaseQuantity(CartModel cartItem) {
    cartItem.cartQuantity++;
    notifyListeners();
  }

  void decreaseQuantity(CartModel cartItem) {
    cartItem.cartQuantity--;
    notifyListeners();
  }

  double calculateTotal() {
    double total = 0.0;
    for (var item in _cartItems.getCartItems()) {
      total += item.productModel.price * item.cartQuantity;
    }
    return total;
    notifyListeners();
  }

  void addforCart(CartModel product) {

    _cartItems.addToCart(product);

    notifyListeners();
    Tost.showCustomToast('تمت اضافة المنتج الي السلة', backgroundColor: Colors.green, textColor: Colors.white);


  }
  void updateCart(CartModel product) {

    _cartItems.updateCartQuantity(product);
    notifyListeners();
    Tost.showCustomToast('تمت اضافة المنتج الي السلة', backgroundColor: Colors.green, textColor: Colors.white);


  }
}


