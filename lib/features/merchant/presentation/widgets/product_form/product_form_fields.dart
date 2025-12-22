import 'package:flutter/material.dart';
import '../../../../categories/presentation/cubit/categories_cubit.dart';
import '../../../../categories/presentation/cubit/categories_state.dart';
import '../../../../../core/services/image_upload_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'product_images_section.dart';

class ProductFormFields extends StatelessWidget {
  final bool isRtl;
  final TextEditingController nameArController;
  final TextEditingController nameEnController;
  final TextEditingController descArController;
  final TextEditingController descEnController;
  final TextEditingController priceController;
  final TextEditingController discountPriceController;
  final TextEditingController stockController;
  final String? selectedCategoryId;
  final bool isActive;
  final bool isFeatured;
  final List<PickedImageData> selectedImages;
  final List<String> existingImages;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<bool> onActiveChanged;
  final ValueChanged<bool> onFeaturedChanged;
  final VoidCallback onImagesChanged;

  const ProductFormFields({
    super.key,
    required this.isRtl,
    required this.nameArController,
    required this.nameEnController,
    required this.descArController,
    required this.descEnController,
    required this.priceController,
    required this.discountPriceController,
    required this.stockController,
    required this.selectedCategoryId,
    required this.isActive,
    required this.isFeatured,
    required this.selectedImages,
    required this.existingImages,
    required this.onCategoryChanged,
    required this.onActiveChanged,
    required this.onFeaturedChanged,
    required this.onImagesChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProductImagesSection(
          isRtl: isRtl,
          selectedImages: selectedImages,
          existingImages: existingImages,
          onImagesChanged: onImagesChanged,
        ),
        const SizedBox(height: 16),
        _buildNameFields(),
        const SizedBox(height: 12),
        _buildDescriptionFields(),
        const SizedBox(height: 12),
        _buildPriceFields(),
        const SizedBox(height: 12),
        _buildStockAndCategoryFields(context),
        const SizedBox(height: 16),
        _buildSwitches(),
      ],
    );
  }

  Widget _buildNameFields() {
    return Column(
      children: [
        TextFormField(
          controller: nameArController,
          decoration: InputDecoration(
            labelText: isRtl ? 'الاسم بالعربية' : 'Name (Arabic)',
            border: const OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return isRtl ? 'الرجاء إدخال الاسم' : 'Please enter name';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: nameEnController,
          decoration: InputDecoration(
            labelText: isRtl ? 'الاسم بالإنجليزية' : 'Name (English)',
            border: const OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionFields() {
    return Column(
      children: [
        TextFormField(
          controller: descArController,
          decoration: InputDecoration(
            labelText: isRtl ? 'الوصف بالعربية' : 'Description (Arabic)',
            border: const OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: descEnController,
          decoration: InputDecoration(
            labelText: isRtl ? 'الوصف بالإنجليزية' : 'Description (English)',
            border: const OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildPriceFields() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: priceController,
            decoration: InputDecoration(
              labelText: isRtl ? 'السعر' : 'Price',
              border: const OutlineInputBorder(),
              suffixText: isRtl ? 'ج.م' : 'EGP',
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return isRtl ? 'مطلوب' : 'Required';
              }
              if (double.tryParse(value) == null) {
                return isRtl ? 'رقم غير صحيح' : 'Invalid number';
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            controller: discountPriceController,
            decoration: InputDecoration(
              labelText: isRtl ? 'سعر الخصم' : 'Discount Price',
              border: const OutlineInputBorder(),
              suffixText: isRtl ? 'ج.م' : 'EGP',
            ),
            keyboardType: TextInputType.number,
          ),
        ),
      ],
    );
  }

  Widget _buildStockAndCategoryFields(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: stockController,
            decoration: InputDecoration(
              labelText: isRtl ? 'المخزون' : 'Stock',
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return isRtl ? 'مطلوب' : 'Required';
              }
              if (int.tryParse(value) == null) {
                return isRtl ? 'رقم غير صحيح' : 'Invalid number';
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: BlocBuilder<CategoriesCubit, CategoriesState>(
            builder: (context, state) {
              if (state is CategoriesLoaded) {
                return DropdownButtonFormField<String>(
                  value: selectedCategoryId,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: isRtl ? 'التصنيف' : 'Category',
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: state.categories
                      .map((cat) => DropdownMenuItem(
                            value: cat.id,
                            child: Text(
                              cat.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ))
                      .toList(),
                  onChanged: onCategoryChanged,
                  validator: (value) {
                    if (value == null) {
                      return isRtl ? 'اختر تصنيف' : 'Select category';
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
    );
  }

  Widget _buildSwitches() {
    return Column(
      children: [
        SwitchListTile(
          title: Text(isRtl ? 'نشط' : 'Active'),
          value: isActive,
          onChanged: onActiveChanged,
        ),
        SwitchListTile(
          title: Text(isRtl ? 'مميز' : 'Featured'),
          value: isFeatured,
          onChanged: onFeaturedChanged,
        ),
      ],
    );
  }
}
