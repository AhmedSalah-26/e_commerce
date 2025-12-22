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
  final bool isFlashSale;
  final DateTime? flashSaleStart;
  final DateTime? flashSaleEnd;
  final List<PickedImageData> selectedImages;
  final List<String> existingImages;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<bool> onActiveChanged;
  final ValueChanged<bool> onFeaturedChanged;
  final ValueChanged<bool> onFlashSaleChanged;
  final ValueChanged<DateTime?> onFlashSaleStartChanged;
  final ValueChanged<DateTime?> onFlashSaleEndChanged;
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
    required this.isFlashSale,
    this.flashSaleStart,
    this.flashSaleEnd,
    required this.selectedImages,
    required this.existingImages,
    required this.onCategoryChanged,
    required this.onActiveChanged,
    required this.onFeaturedChanged,
    required this.onFlashSaleChanged,
    required this.onFlashSaleStartChanged,
    required this.onFlashSaleEndChanged,
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
                  initialValue: selectedCategoryId,
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
        const Divider(),
        _buildFlashSaleSection(),
      ],
    );
  }

  Widget _buildFlashSaleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          title: Row(
            children: [
              const Icon(Icons.flash_on, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Text(isRtl ? 'عرض خاص (Flash Sale)' : 'Flash Sale'),
            ],
          ),
          subtitle: Text(
            isRtl
                ? 'تفعيل عداد تنازلي للعرض'
                : 'Enable countdown timer for offer',
            style: const TextStyle(fontSize: 12),
          ),
          value: isFlashSale,
          onChanged: onFlashSaleChanged,
        ),
        if (isFlashSale) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _buildDateTimePicker(
                  label: isRtl ? 'بداية العرض' : 'Sale Start',
                  value: flashSaleStart,
                  onChanged: onFlashSaleStartChanged,
                ),
                const SizedBox(height: 12),
                _buildDateTimePicker(
                  label: isRtl ? 'نهاية العرض' : 'Sale End',
                  value: flashSaleEnd,
                  onChanged: onFlashSaleEndChanged,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDateTimePicker({
    required String label,
    required DateTime? value,
    required ValueChanged<DateTime?> onChanged,
  }) {
    return Builder(
      builder: (context) {
        final displayText = value != null
            ? '${value.day}/${value.month}/${value.year} ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}'
            : (isRtl ? 'اختر التاريخ والوقت' : 'Select date & time');

        return InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: value ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (date != null && context.mounted) {
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(value ?? DateTime.now()),
              );
              if (time != null) {
                onChanged(DateTime(
                  date.year,
                  date.month,
                  date.day,
                  time.hour,
                  time.minute,
                ));
              }
            }
          },
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
              suffixIcon: const Icon(Icons.calendar_today),
            ),
            child: Text(displayText),
          ),
        );
      },
    );
  }
}
