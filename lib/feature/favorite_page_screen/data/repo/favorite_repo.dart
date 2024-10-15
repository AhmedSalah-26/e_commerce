import '../../../home_screen/data/models/ProductModel.dart';

class FvoriteRepository{

  final List<ProductModel> favoriteProducts = [

  ];


  getFavoriteProducts() {
    return favoriteProducts;
  }
  addToFavorite(ProductModel product) {
    favoriteProducts.add(product);
  }

  removeFromFavorite(ProductModel product) {
    favoriteProducts.remove(product);
  }

}