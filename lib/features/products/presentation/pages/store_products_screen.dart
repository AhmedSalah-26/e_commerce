import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/shared_widgets/product_card/product_grid_card.dart';
import '../../../../core/shared_widgets/skeleton_widgets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';

class StoreProductsScreen extends StatefulWidget {
  final String merchantId;
  final String? storeName;

  const StoreProductsScreen({
    super.key,
    required this.merchantId,
    this.storeName,
  });

  @override
  State<StoreProductsScreen> createState() => _StoreProductsScreenState();
}

class _StoreProductsScreenState extends State<StoreProductsScreen> {
  List<ProductEntity> _products = [];
  bool _isLoading = true;
  String? _error;
  String? _storeName;

  @override
  void initState() {
    super.initState();
    _storeName = widget.storeName;
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final repository = sl<ProductRepository>();
      final result = await repository.getProductsByMerchant(widget.merchantId);

      result.fold(
        (failure) {
          if (mounted) {
            setState(() {
              _error = failure.message;
              _isLoading = false;
            });
          }
        },
        (products) {
          if (mounted) {
            // Get store name from first product if not provided
            if (_storeName == null && products.isNotEmpty) {
              _storeName = products.first.storeName;
            }
            setState(() {
              _products = products;
              _isLoading = false;
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColours.white,
      appBar: AppBar(
        backgroundColor: AppColours.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColours.brownMedium),
          onPressed: () => context.pop(),
        ),
        title: Text(
          _storeName ?? 'store_products'.tr(),
          style: AppTextStyle.semiBold_20_dark_brown.copyWith(fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const ProductsGridSkeleton();
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(_error!, style: AppTextStyle.normal_14_greyDark),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadProducts,
              child: Text('retry'.tr()),
            ),
          ],
        ),
      );
    }

    if (_products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inventory_2_outlined,
                size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('no_products'.tr(), style: AppTextStyle.normal_16_greyDark),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadProducts,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.65,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          return ProductGridCard(product: product);
        },
      ),
    );
  }
}
