import 'package:flutter/cupertino.dart';

import '../data/repo/repo.dart';

class HomeScreenProvider extends ChangeNotifier {
  HomeScreenRepository homeScreenRepository = HomeScreenRepository();
  getImages() {
    return homeScreenRepository.getAllImages();
  }

  getCategories() {
    return homeScreenRepository.getAllCategories();
  }

  getfilteredProducts(String selectedCategory) {
    return homeScreenRepository.getfilteredProducts(selectedCategory);
  }



}