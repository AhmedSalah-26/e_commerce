import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/image_upload_service.dart';
import '../../../../core/di/injection_container.dart';
import '../../../categories/domain/entities/category_entity.dart';
import '../../../categories/presentation/cubit/categories_cubit.dart';
import 'category_form/category_image_picker.dart';
import 'category_form/category_form_fields.dart';

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

    if (widget.category != null) _loadCategoryData();
  }

  Future<void> _loadCategoryData() async {
    setState(() => _isLoadingData = true);

    final cubit = context.read<CategoriesCubit>();
    final rawData = await cubit.getCategoryRawData(widget.category!.id);

    if (rawData != null) {
      _nameArController.text = rawData['name_ar'] ?? '';
      _nameEnController.text = rawData['name_en'] ?? '';
      _descriptionController.text = rawData['description'] ?? '';
      _existingImageUrl = rawData['image_url'];
      _isActive = rawData['is_active'] ?? true;
    } else {
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
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600, maxWidth: 500),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
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
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
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
                            Text(
                              widget.isRtl ? 'صورة التصنيف' : 'Category Image',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Center(
                              child: CategoryImagePicker(
                                selectedImage: _selectedImage,
                                existingImageUrl: _existingImageUrl,
                                isRtl: widget.isRtl,
                                onImagePicked: _pickImage,
                                onImageRemoved: () {
                                  setState(() {
                                    _selectedImage = null;
                                    _existingImageUrl = null;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                            CategoryFormFields(
                              nameArController: _nameArController,
                              nameEnController: _nameEnController,
                              descriptionController: _descriptionController,
                              isActive: _isActive,
                              isRtl: widget.isRtl,
                              onActiveChanged: (value) =>
                                  setState(() => _isActive = value),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
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
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
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
      setState(() => _isSaving = true);

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
        setState(() => _isSaving = false);
        if (success) Navigator.pop(context);
      }
    }
  }
}
