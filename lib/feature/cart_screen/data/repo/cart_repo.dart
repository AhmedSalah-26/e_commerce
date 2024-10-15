import 'package:e_commerce/feature/cart_screen/data/models/cart_model.dart';

import '../../../home_screen/data/models/ProductModel.dart';

class CartRepository {


  List<CartModel> cartItems = [

  ];


  getCartItems() {
    return cartItems;
  }
  addToCart(CartModel product) {
    cartItems.add(product);
  }

  removeFromCart(CartModel product) {
    cartItems.remove(product);
  }

 increaseQuantity(CartModel product) {
    product.cartQuantity++;
  }

  decreaseQuantity(CartModel product) {
    product.cartQuantity--;
  }

  void updateCartQuantity(CartModel product ) {
    // تحقق إذا كان المنتج موجودًا في العربة
    int index = cartItems.indexWhere((item) => item.productModel.id == product.productModel.id);

    if (index != -1) {
      // المنتج موجود بالفعل، قم بزيادة الكمية
      cartItems[index].cartQuantity += product.cartQuantity;
    } else {
      // المنتج غير موجود، قم بإضافته للعربة مع الكمية المحددة
      product.cartQuantity = product.cartQuantity; // تعيين الكمية للمنتج الجديد
      addToCart(product);
    }
  }


}