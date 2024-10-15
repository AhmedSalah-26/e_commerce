import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../Core/Sharedwidgets/tost.dart';
import '../../home_screen/data/models/ProductModel.dart';
import '../data/repo/favorite_repo.dart';

class FavoriteScreenProvider extends ChangeNotifier {
  FvoriteRepository _fvoriteRepository = FvoriteRepository();

  getFavoriteProducts() {
    return _fvoriteRepository.getFavoriteProducts();
    notifyListeners();
  }

  addToFavorite(ProductModel product) {
    _fvoriteRepository.addToFavorite(product);
    notifyListeners();
    Tost.showCustomToast('تمت اضافة المنتج الي التفضيلات', backgroundColor: Colors.green, textColor: Colors.white);


  }

  removeFromFavorite(ProductModel product) {
    _fvoriteRepository.removeFromFavorite(product);
    notifyListeners();
    Tost.showCustomToast('تمت ازالة المنتج من التفضيلات', backgroundColor: Colors.red, textColor: Colors.white);


  }




}