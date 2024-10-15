import '../../ui/widgets/category_row.dart';
import '../../../cart_screen/ui/widgets/product_cart_card.dart';
import '../models/Category.dart';
import '../models/ProductModel.dart';

class HomeScreenRepository {

  // Private lists
  List<Category> _categories = [
    Category("الكل", true),
    Category("فئة", false),
    Category("الأعلى", false),
    Category("موصى به", false),
  ];
  List<String> _images = [
    "assets/slider/V1.png",
    "assets/slider/V2.png",
    "assets/slider/V3.png",
    "assets/slider/V4.png",
  ];
  List<ProductModel> _allProducts = [
    ProductModel(
      id: 1500,
        stock: 40,
        productName: "علبة تمر نجمه الوادى",
        imagePath: ["assets/product/WhatsApp Image 2024-09-15 at 7.20.36 PM.jpeg","assets/product/WhatsApp Image 2024-09-15 at 7.20.38 PM.jpeg"],
        price: 200,
        rating: 3.5,
        isfavorite: false,
        description: "استمتع بتمور الوادى الفاخرة التي تم اختيارها بعناية فائقة لتقدم لك تجربة طعام لذيذة. تتميز تمرات البرحي بنكهتها الغنية وقوامها الطري الذي يجعلها مثالية كوجبة خفيفة أو إضافة للحلويات. تمتاز هذه العلبة بجودتها العالية وسعرها المناسب، مما يجعلها خياراً ممتازاً لعشاق التمر.",
        cartQuantity: 1
    ),
    ProductModel(
      id: 7500,
        stock: 10,
        productName: "علبة تمر المصريه ",
        imagePath: ["assets/product/WhatsApp Image 2024-09-15 at 7.20.38 PM.jpeg"],
        price: 350,
        rating: 4.6,
        isfavorite: false,
        description: "تذوق تمرات المصريه الممتازة، التي تتميز بحلاوتها الطبيعية وقوامها الطري. تم اختيار كل حبة بعناية فائقة لتوفير أفضل تجربة طعام. تتمتع هذه العلبة بجودة عالية وسعر مرتفع بعض الشيء، لكن نكهتها وقيمتها تجعلها تستحق التجربة.",
        cartQuantity: 1
    ),
    ProductModel(
      id: 9659,
        stock: 20,
        productName: "علبة تمر طلال",
        imagePath: ["assets/product/WhatsApp Image 2024-09-15 at 7.20.38 PM (1).jpeg"],
        price: 240,
        rating: 3.4,
        isfavorite: false,
        description: "تمتع بتمور طلال الرائعة التي تتميز بنكهتها الغنية وقوامها الطري. تقدم لك هذه العلبة تمرات ذات جودة عالية وسعر معقول، مما يجعلها خياراً ممتازاً للوجبات الخفيفة والحلويات. تم انتقاء كل حبة بعناية لضمان تقديم منتج رائع.",
        cartQuantity: 1
    ),
    ProductModel(
      id: 121,
        stock: 20,
        productName: "علبة تمر طلال",
        imagePath: ["assets/product/WhatsApp Image 2024-09-15 at 7.20.39 PM.jpeg"],
        price: 225,
        rating: 3.2,
        isfavorite: false,
        description: "اكتشف تمرات الهندي المميزة ذات النكهة الفريدة وقوامها الطري. توفر هذه العلبة تجربة طعام رائعة بسعر مناسب، مما يجعلها خياراً ممتازاً لعشاق التمر. الجودة العالية والاهتمام بالتفاصيل يجعل من هذه العلبة خياراً ممتازاً لإضافتها إلى وجباتك الخفيفة.",
        cartQuantity: 1
    ),
  ];
  List<ProductModel> _recommendedProducts = [
    ProductModel(
        id: 1500,
        stock: 40,
        productName: "علبة تمر نجمه الوادى",
        imagePath: ["assets/product/WhatsApp Image 2024-09-15 at 7.20.36 PM.jpeg"],
        price: 200,
        rating: 3.5,
        isfavorite: false,
        description: "استمتع بتمور الوادى الفاخرة التي تم اختيارها بعناية فائقة لتقدم لك تجربة طعام لذيذة. تتميز تمرات البرحي بنكهتها الغنية وقوامها الطري الذي يجعلها مثالية كوجبة خفيفة أو إضافة للحلويات. تمتاز هذه العلبة بجودتها العالية وسعرها المناسب، مما يجعلها خياراً ممتازاً لعشاق التمر.",
        cartQuantity: 1
    ),
  ];

  List<ProductModel>  getfilteredProducts(String selectedCategory) {
    switch (selectedCategory) {
      case "موصى به":
        return getAllProducts();
      case "فئة":
      // يمكن تخصيص قائمة فئة حسب الحاجة
        return getAllProducts(); // تغيير هذه القائمة بناءً على الفئة المحددة
      case "الأعلى":
      // قائمة المنتجات الأعلى تصنيفًا
        return getAllProducts().where((product) => product.rating >= 4).toList();
      case "الكل":
      default:
        return getAllProducts();
    }
  }

  List<ProductModel> getAllProducts() {
    return _allProducts;
  }

  List<ProductModel> getRecommendedProducts() {
    return _recommendedProducts;
  }

  List<Category> getAllCategories() {
    return _categories;
  }

  List<String> getAllImages() {
    return _images;
  }


}
