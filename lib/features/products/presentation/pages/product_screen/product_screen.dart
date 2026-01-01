import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../core/di/injection_container.dart';
import '../../../../../core/shared_widgets/custom_button.dart';
import '../../../../../core/shared_widgets/flash_sale_banner.dart';
import '../../../../../core/shared_widgets/skeleton_widgets.dart';
import '../../../../../core/utils/share_utils.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../data/datasources/product_remote_datasource.dart';
import '../../cubit/products_cubit.dart';
import '../../utils/product_actions.dart';
import '../../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../../cart/presentation/cubit/cart_state.dart';
import '../../../../favorites/presentation/cubit/favorites_cubit.dart';
import '../../../../favorites/presentation/cubit/favorites_state.dart';
import '../../../../reviews/presentation/cubit/reviews_cubit.dart';
import '../../../../reviews/presentation/widgets/review_widgets/reviews_section.dart';
import '../../../../product_reports/presentation/widgets/report_product_dialog.dart';
import '../../widgets/suggested_products_slider.dart';
import '../../widgets/product_image_slider.dart';
import '../../widgets/product_info_section.dart';
import '../../widgets/product_store_info.dart';
import '../../widgets/product_details_widgets.dart';
import 'product_screen_app_bar.dart';
import 'product_screen_body.dart';
import 'product_screen_bottom_bar.dart';

class ProductScreen extends StatefulWidget {
  final ProductEntity product;

  const ProductScreen({super.key, required this.product});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  int _quantity = 1;
  late ProductEntity _product;
  bool _isLoading = true;

  static const _actions = ProductActions();

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    _loadFullProduct();
  }

  Future<void> _loadFullProduct() async {
    try {
      final datasource = getIt<ProductRemoteDatasource>();
      final fullProduct = await datasource.getProductById(_product.id);
      if (mounted) {
        setState(() {
          _product = fullProduct;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _incrementQuantity() {
    if (_quantity < _product.stock) {
      setState(() => _quantity++);
    }
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() => _quantity--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = context.locale.languageCode == 'ar';

    return Scaffold(
      appBar: ProductScreenAppBar(
        product: _product,
        isRtl: isRtl,
        onShare: () => ShareUtils.shareProduct(_product),
        onReport: () => ReportProductDialog.show(context, _product.id),
      ),
      body: ProductScreenBody(
        product: _product,
        quantity: _quantity,
        isLoading: _isLoading,
        isRtl: isRtl,
        onQuantityChanged: (quantity) => setState(() => _quantity = quantity),
        onIncrementQuantity: _incrementQuantity,
        onDecrementQuantity: _decrementQuantity,
      ),
      bottomNavigationBar: ProductScreenBottomBar(
        product: _product,
        quantity: _quantity,
        isRtl: isRtl,
      ),
    );
  }
}
