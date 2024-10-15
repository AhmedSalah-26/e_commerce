class ProductModel {
  int id;
  String description;
  String productName;
  List <String> imagePath;
  double price;
  int cartQuantity;
  bool isfavorite;
  double rating;
  int stock;

  ProductModel({
    required this.id,
     this.description="",
    required this.productName,
    required this.imagePath,
    required this.price,
    this.cartQuantity = 1,  // Default value of 1
    required this.isfavorite,
    required this.rating,
    required this.stock,
  });
}
