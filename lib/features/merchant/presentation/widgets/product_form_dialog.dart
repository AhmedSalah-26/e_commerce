import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../Core/Theme/app_text_style.dart';
import '../../../../core/services/image_upload_service.dart';
import '../../../../core/di/injection_container.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../../categories/presentation/cubit/categories_cubit.dart';
import '../../../categories/presentation/cubit/categories_state.dart';
import '../cubit/merchant_products_cubit.dart';

class ProductFormDialog extends StatefulWidget {
  final ProductEntity? product;
  final bool isRtl;
  final Future<bool> Function(Map<String, dynamic>) onSave;

  const ProductFormDialog({
    super.key,
    this.product,
    required this.isRtl,
    required this.onSave,
  });

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
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
  bool _isSaving = false;
  bool _isLoadingData = false;
  final List<PickedImageData> _selectedImages = [];
  List<String> _existingImages = [];

  @override
  void initState() {
    super.initState();
    _nameArController = TextEditingController();
    _nameEnController = TextEditingController();
    _descArController = TextEditingController();
    _descEnController = TextEditingController();
    _priceController = TextEditingController();
    _discountPriceController = TextEditingController();
    _stockController = TextEditingController(text: '0');

    if (widget.product != null) {
      _loadProductData();
    }
  }

  Future<void> _loadProductData() async {
    setState(() => _isLoadingData = true);

    // Try to get raw data from server for bilingual fields
    final cubit = context.read<MerchantProductsCubit>();
    final rawData = await cubit.getProductRawData(widget.product!.id);

    if (rawData != null) {
      _nameArController.text = rawData['name_ar'] ?? '';
      _nameEnController.text = rawData['name_en'] ?? '';
      _descArController.text = rawData['description_ar'] ?? '';
      _descEnController.text = rawData['description_en'] ?? '';
    } else {
      // Fallback to product entity data
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

  Future<void> _pickImages() async {
    try {
      final imageService = sl<ImageUploadService>();
      final images = await imageService.pickMultipleImages();

      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images);
        });
      }
    } catch (e) {
      debugPrint('Error picking images: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 700, maxWidth: 500),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColours.primary,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.product == null
                        ? (widget.isRtl ? 'إضافة منتج جديد' : 'Add New Product')
                        : (widget.isRtl ? 'تعديل المنتج' : 'Edit Product'),
                    style: AppTextStyle.semiBold_18_white,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // Form
            Expanded(
              child: _isLoadingData
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Images Section
                            Text(
                              widget.isRtl ? 'صور المنتج' : 'Product Images',
                              style: AppTextStyle.semiBold_16_dark_brown,
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 100,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: [
                                  // Add Image Button
                                  GestureDetector(
                                    onTap: _pickImages,
                                    child: Container(
                                      width: 100,
                                      height: 100,
                                      margin: const EdgeInsets.only(left: 8),
                                      decoration: BoxDecoration(
                                        color: AppColours.greyLighter,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: AppColours.primary,
                                          style: BorderStyle.solid,
                                          width: 2,
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.add_photo_alternate,
                                              color: AppColours.primary,
                                              size: 32),
                                          const SizedBox(height: 4),
                                          Text(
                                            widget.isRtl ? 'إضافة' : 'Add',
                                            style: TextStyle(
                                              color: AppColours.primary,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Existing Images
                                  ..._existingImages
                                      .map((url) => _buildImageTile(
                                            imageUrl: url,
                                            onRemove: () {
                                              setState(() {
                                                _existingImages.remove(url);
                                              });
                                            },
                                          )),
                                  // New Selected Images
                                  ..._selectedImages
                                      .map((imageData) => _buildImageTile(
                                            imageData: imageData,
                                            onRemove: () {
                                              setState(() {
                                                _selectedImages
                                                    .remove(imageData);
                                              });
                                            },
                                          )),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _nameArController,
                              decoration: InputDecoration(
                                labelText: widget.isRtl
                                    ? 'الاسم بالعربية'
                                    : 'Name (Arabic)',
                                border: const OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return widget.isRtl
                                      ? 'الرجاء إدخال الاسم'
                                      : 'Please enter name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _nameEnController,
                              decoration: InputDecoration(
                                labelText: widget.isRtl
                                    ? 'الاسم بالإنجليزية'
                                    : 'Name (English)',
                                border: const OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _descArController,
                              decoration: InputDecoration(
                                labelText: widget.isRtl
                                    ? 'الوصف بالعربية'
                                    : 'Description (Arabic)',
                                border: const OutlineInputBorder(),
                              ),
                              maxLines: 3,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _descEnController,
                              decoration: InputDecoration(
                                labelText: widget.isRtl
                                    ? 'الوصف بالإنجليزية'
                                    : 'Description (English)',
                                border: const OutlineInputBorder(),
                              ),
                              maxLines: 3,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _priceController,
                                    decoration: InputDecoration(
                                      labelText:
                                          widget.isRtl ? 'السعر' : 'Price',
                                      border: const OutlineInputBorder(),
                                      suffixText: widget.isRtl ? 'ج.م' : 'EGP',
                                    ),
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return widget.isRtl
                                            ? 'مطلوب'
                                            : 'Required';
                                      }
                                      if (double.tryParse(value) == null) {
                                        return widget.isRtl
                                            ? 'رقم غير صحيح'
                                            : 'Invalid number';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: _discountPriceController,
                                    decoration: InputDecoration(
                                      labelText: widget.isRtl
                                          ? 'سعر الخصم'
                                          : 'Discount Price',
                                      border: const OutlineInputBorder(),
                                      suffixText: widget.isRtl ? 'ج.م' : 'EGP',
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _stockController,
                                    decoration: InputDecoration(
                                      labelText:
                                          widget.isRtl ? 'المخزون' : 'Stock',
                                      border: const OutlineInputBorder(),
                                    ),
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return widget.isRtl
                                            ? 'مطلوب'
                                            : 'Required';
                                      }
                                      if (int.tryParse(value) == null) {
                                        return widget.isRtl
                                            ? 'رقم غير صحيح'
                                            : 'Invalid number';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: BlocBuilder<CategoriesCubit,
                                      CategoriesState>(
                                    builder: (context, state) {
                                      if (state is CategoriesLoaded) {
                                        return DropdownButtonFormField<String>(
                                          value: _selectedCategoryId,
                                          decoration: InputDecoration(
                                            labelText: widget.isRtl
                                                ? 'التصنيف'
                                                : 'Category',
                                            border: const OutlineInputBorder(),
                                          ),
                                          items: state.categories
                                              .map((cat) => DropdownMenuItem(
                                                    value: cat.id,
                                                    child: Text(cat.name),
                                                  ))
                                              .toList(),
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedCategoryId = value;
                                            });
                                          },
                                          validator: (value) {
                                            if (value == null) {
                                              return widget.isRtl
                                                  ? 'اختر تصنيف'
                                                  : 'Select category';
                                            }
                                            return null;
                                          },
                                        );
                                      }
                                      return const CircularProgressIndicator();
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SwitchListTile(
                              title: Text(widget.isRtl ? 'نشط' : 'Active'),
                              value: _isActive,
                              onChanged: (value) {
                                setState(() {
                                  _isActive = value;
                                });
                              },
                            ),
                            SwitchListTile(
                              title: Text(widget.isRtl ? 'مميز' : 'Featured'),
                              value: _isFeatured,
                              onChanged: (value) {
                                setState(() {
                                  _isFeatured = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
            // Actions
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(widget.isRtl ? 'إلغاء' : 'Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColours.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(widget.isRtl ? 'حفظ' : 'Save'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageTile({
    PickedImageData? imageData,
    String? imageUrl,
    required VoidCallback onRemove,
  }) {
    return Container(
      width: 100,
      height: 100,
      margin: const EdgeInsets.only(left: 8),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: imageData != null
                ? Image.memory(imageData.bytes,
                    width: 100, height: 100, fit: BoxFit.cover)
                : Image.network(imageUrl!,
                    width: 100, height: 100, fit: BoxFit.cover),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

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
        'images': _existingImages,
        'new_images': _selectedImages,
      };

      final success = await widget.onSave(productData);

      if (mounted) {
        setState(() {
          _isSaving = false;
        });

        if (success) {
          Navigator.pop(context);
        }
      }
    }
  }
}
