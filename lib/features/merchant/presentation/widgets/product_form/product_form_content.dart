import 'package:flutter/material.dart';
import '../../../../products/domain/entities/product_entity.dart';
import '../../cubit/merchant_products_cubit.dart';
import '../../../../../core/services/image_upload_service.dart';
import '../../../../../core/utils/date_utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'product_form_fields.dart';
import 'product_form_actions.dart';

class ProductFormContent extends StatefulWidget {
  final ProductEntity? product;
  final bool isRtl;
  final Future<bool> Function(Map<String, dynamic>) onSave;

  const ProductFormContent({
    super.key,
    this.product,
    required this.isRtl,
    required this.onSave,
  });

  @override
  State<ProductFormContent> createState() => _ProductFormContentState();
}

class _ProductFormContentState extends State<ProductFormContent> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameArController;
  late TextEditingController _nameEnController;
  late TextEditingController _descArController;
  late TextEditingController _descEnController;
  late TextEditingController _priceController;
  late TextEditingController _discountPriceController;
  late TextEditingController _stockController;
  String? _selectedCategoryId;
  bool _isActive = true;
  bool _isFeatured = false;
  bool _isFlashSale = false;
  DateTime? _flashSaleStart;
  DateTime? _flashSaleEnd;
  bool _isSaving = false;
  bool _isLoadingData = false;
  final List<PickedImageData> _selectedImages = [];
  List<String> _existingImages = [];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    if (widget.product != null) {
      _loadProductData();
    }
  }

  void _initializeControllers() {
    _nameArController = TextEditingController();
    _nameEnController = TextEditingController();
    _descArController = TextEditingController();
    _descEnController = TextEditingController();
    _priceController = TextEditingController();
    _discountPriceController = TextEditingController();
    _stockController = TextEditingController(text: '0');
  }

  Future<void> _loadProductData() async {
    setState(() => _isLoadingData = true);

    final cubit = context.read<MerchantProductsCubit>();
    final rawData = await cubit.getProductRawData(widget.product!.id);

    if (rawData != null) {
      _nameArController.text = rawData['name_ar'] ?? '';
      _nameEnController.text = rawData['name_en'] ?? '';
      _descArController.text = rawData['description_ar'] ?? '';
      _descEnController.text = rawData['description_en'] ?? '';
    } else {
      _nameArController.text = widget.product!.name;
      _nameEnController.text = widget.product!.name;
      _descArController.text = widget.product!.description;
      _descEnController.text = widget.product!.description;
    }

    _priceController.text = widget.product!.price.toString();
    _discountPriceController.text =
        widget.product!.discountPrice?.toString() ?? '';
    _stockController.text = widget.product!.stock.toString();
    _selectedCategoryId = widget.product!.categoryId;
    _isActive = widget.product!.isActive;
    _isFeatured = widget.product!.isFeatured;
    _isFlashSale = widget.product!.isFlashSale;
    _flashSaleStart = widget.product!.flashSaleStart;
    _flashSaleEnd = widget.product!.flashSaleEnd;
    _existingImages = widget.product!.images;

    setState(() => _isLoadingData = false);
  }

  @override
  void dispose() {
    _nameArController.dispose();
    _nameEnController.dispose();
    _descArController.dispose();
    _descEnController.dispose();
    _priceController.dispose();
    _discountPriceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingData) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: ProductFormFields(
                isRtl: widget.isRtl,
                nameArController: _nameArController,
                nameEnController: _nameEnController,
                descArController: _descArController,
                descEnController: _descEnController,
                priceController: _priceController,
                discountPriceController: _discountPriceController,
                stockController: _stockController,
                selectedCategoryId: _selectedCategoryId,
                isActive: _isActive,
                isFeatured: _isFeatured,
                isFlashSale: _isFlashSale,
                flashSaleStart: _flashSaleStart,
                flashSaleEnd: _flashSaleEnd,
                selectedImages: _selectedImages,
                existingImages: _existingImages,
                onCategoryChanged: (value) {
                  setState(() => _selectedCategoryId = value);
                },
                onActiveChanged: (value) {
                  setState(() => _isActive = value);
                },
                onFeaturedChanged: (value) {
                  setState(() => _isFeatured = value);
                },
                onFlashSaleChanged: (value) {
                  setState(() => _isFlashSale = value);
                },
                onFlashSaleStartChanged: (value) {
                  setState(() => _flashSaleStart = value);
                },
                onFlashSaleEndChanged: (value) {
                  setState(() => _flashSaleEnd = value);
                },
                onImagesChanged: () {
                  setState(() {});
                },
              ),
            ),
          ),
        ),
        ProductFormActions(
          isRtl: widget.isRtl,
          isSaving: _isSaving,
          onCancel: () => Navigator.pop(context),
          onSave: _saveProduct,
        ),
      ],
    );
  }

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);

      final productData = {
        'name_ar': _nameArController.text,
        'name_en': _nameEnController.text.isEmpty
            ? _nameArController.text
            : _nameEnController.text,
        'description_ar': _descArController.text,
        'description_en': _descEnController.text.isEmpty
            ? _descArController.text
            : _descEnController.text,
        'price': double.parse(_priceController.text),
        'discount_price': _discountPriceController.text.isEmpty
            ? null
            : double.parse(_discountPriceController.text),
        'stock': int.parse(_stockController.text),
        'category_id': _selectedCategoryId,
        'is_active': _isActive,
        'is_featured': _isFeatured,
        'is_flash_sale': _isFlashSale,
        'flash_sale_start': AppDateUtils.toEgyptIsoString(_flashSaleStart),
        'flash_sale_end': AppDateUtils.toEgyptIsoString(_flashSaleEnd),
        'images': _existingImages,
        'new_images': _selectedImages,
      };

      final success = await widget.onSave(productData);

      if (mounted) {
        setState(() => _isSaving = false);
        if (success) {
          Navigator.pop(context);
        }
      }
    }
  }
}
