import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../Core/Theme/app_text_style.dart';
import '../../../../core/services/image_upload_service.dart';
import '../../../../core/di/injection_container.dart';
import '../../../categories/domain/entities/category_entity.dart';
import '../../../categories/presentation/cubit/categories_cubit.dart';

class CategoryFormDialog extends StatefulWidget {
  final CategoryEntity? category;
  final bool isRtl;
  final Future<bool> Function(Map<String, dynamic>) onSave;

  const CategoryFormDialog({
    super.key,
    this.category,
    required this.isRtl,
    required this.onSave,
  });

  @override
  State<CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<CategoryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameArController;
  late TextEditingController _nameEnController;
  late TextEditingController _descriptionController;
  bool _isActive = true;
  bool _isSaving = false;
  bool _isLoadingData = false;
  PickedImageData? _selectedImage;
  String? _existingImageUrl;

  @override
  void initState() {
    super.initState();
    _nameArController = TextEditingController();
    _nameEnController = TextEditingController();
    _descriptionController = TextEditingController();

    if (widget.category != null) {
      _loadCategoryData();
    }
  }

  Future<void> _loadCategoryData() async {
    setState(() => _isLoadingData = true);

    // Try to get raw data from server for bilingual fields
    final cubit = context.read<CategoriesCubit>();
    final rawData = await cubit.getCategoryRawData(widget.category!.id);

    if (rawData != null) {
      _nameArController.text = rawData['name_ar'] ?? '';
      _nameEnController.text = rawData['name_en'] ?? '';
      _descriptionController.text = rawData['description'] ?? '';
      _existingImageUrl = rawData['image_url'];
      _isActive = rawData['is_active'] ?? true;
    } else {
      // Fallback to category entity data
      _nameArController.text = widget.category!.name;
      _nameEnController.text = widget.category!.name;
      _descriptionController.text = widget.category!.description ?? '';
      _existingImageUrl = widget.category!.imageUrl;
      _isActive = widget.category!.isActive;
    }

    setState(() => _isLoadingData = false);
  }

  @override
  void dispose() {
    _nameArController.dispose();
    _nameEnController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final imageService = sl<ImageUploadService>();
      final image = await imageService.pickImage();

      if (image != null) {
        setState(() {
          _selectedImage = image;
          _existingImageUrl = null;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600, maxWidth: 500),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColours.primary,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.category == null
                        ? (widget.isRtl
                            ? 'إضافة تصنيف جديد'
                            : 'Add New Category')
                        : (widget.isRtl ? 'تعديل التصنيف' : 'Edit Category'),
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
                            // Image Section
                            Text(
                              widget.isRtl ? 'صورة التصنيف' : 'Category Image',
                              style: AppTextStyle.semiBold_16_dark_brown,
                            ),
                            const SizedBox(height: 8),
                            Center(
                              child: GestureDetector(
                                onTap: _pickImage,
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: AppColours.greyLighter,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColours.primary,
                                      width: 2,
                                    ),
                                  ),
                                  child: _selectedImage != null
                                      ? Stack(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Image.memory(
                                                _selectedImage!.bytes,
                                                width: 120,
                                                height: 120,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            Positioned(
                                              top: 4,
                                              right: 4,
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _selectedImage = null;
                                                  });
                                                },
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(4),
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Colors.red,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(Icons.close,
                                                      color: Colors.white,
                                                      size: 16),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      : _existingImageUrl != null
                                          ? Stack(
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  child: Image.network(
                                                    _existingImageUrl!,
                                                    width: 120,
                                                    height: 120,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                                Positioned(
                                                  top: 4,
                                                  right: 4,
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        _existingImageUrl =
                                                            null;
                                                      });
                                                    },
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              4),
                                                      decoration:
                                                          const BoxDecoration(
                                                        color: Colors.red,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: const Icon(
                                                          Icons.close,
                                                          color: Colors.white,
                                                          size: 16),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Icon(Icons.add_photo_alternate,
                                                    color: AppColours.primary,
                                                    size: 40),
                                                const SizedBox(height: 4),
                                                Text(
                                                  widget.isRtl
                                                      ? 'إضافة صورة'
                                                      : 'Add Image',
                                                  style: const TextStyle(
                                                    color: AppColours.primary,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                ),
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
                              controller: _descriptionController,
                              decoration: InputDecoration(
                                labelText:
                                    widget.isRtl ? 'الوصف' : 'Description',
                                border: const OutlineInputBorder(),
                              ),
                              maxLines: 3,
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
                      onPressed: _isSaving ? null : _saveCategory,
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

  Future<void> _saveCategory() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      final categoryData = {
        'name_ar': _nameArController.text,
        'name_en': _nameEnController.text.isEmpty
            ? _nameArController.text
            : _nameEnController.text,
        'description': _descriptionController.text,
        'is_active': _isActive,
        'image_url': _existingImageUrl,
        'new_image': _selectedImage,
      };

      final success = await widget.onSave(categoryData);

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
