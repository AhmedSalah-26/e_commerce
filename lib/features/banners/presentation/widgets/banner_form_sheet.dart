import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../domain/entities/banner_entity.dart';
import '../cubit/admin_banners_cubit.dart';

class BannerFormSheet extends StatefulWidget {
  final BannerEntity? banner;

  const BannerFormSheet({super.key, this.banner});

  @override
  State<BannerFormSheet> createState() => _BannerFormSheetState();
}

class _BannerFormSheetState extends State<BannerFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleArController;
  late TextEditingController _titleEnController;
  late TextEditingController _linkValueController;
  late TextEditingController _sortOrderController;

  BannerLinkType _linkType = BannerLinkType.none;
  bool _isActive = true;
  File? _selectedImage;
  String? _existingImageUrl;
  DateTime? _startDate;
  DateTime? _endDate;

  bool get isEditing => widget.banner != null;

  @override
  void initState() {
    super.initState();
    _titleArController = TextEditingController(text: widget.banner?.titleAr);
    _titleEnController = TextEditingController(text: widget.banner?.titleEn);
    _linkValueController =
        TextEditingController(text: widget.banner?.linkValue);
    _sortOrderController =
        TextEditingController(text: widget.banner?.sortOrder.toString() ?? '0');

    if (widget.banner != null) {
      _linkType = widget.banner!.linkType;
      _isActive = widget.banner!.isActive;
      _existingImageUrl = widget.banner!.imageUrl;
      _startDate = widget.banner!.startDate;
      _endDate = widget.banner!.endDate;
    }
  }

  @override
  void dispose() {
    _titleArController.dispose();
    _titleEnController.dispose();
    _linkValueController.dispose();
    _sortOrderController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Future<void> _selectDate(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: (isStart ? _startDate : _endDate) ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (date != null) {
      setState(() {
        if (isStart) {
          _startDate = date;
        } else {
          _endDate = date;
        }
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedImage == null && _existingImageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى اختيار صورة للبانر'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final cubit = context.read<AdminBannersCubit>();

    if (isEditing) {
      cubit.updateBanner(
        bannerId: widget.banner!.id,
        titleAr: _titleArController.text.trim(),
        titleEn: _titleEnController.text.trim().isEmpty
            ? null
            : _titleEnController.text.trim(),
        imageFile: _selectedImage,
        existingImageUrl: _existingImageUrl,
        linkType: _linkType.name,
        linkValue: _linkValueController.text.trim().isEmpty
            ? null
            : _linkValueController.text.trim(),
        sortOrder: int.tryParse(_sortOrderController.text) ?? 0,
        isActive: _isActive,
        startDate: _startDate,
        endDate: _endDate,
      );
    } else {
      cubit.createBanner(
        titleAr: _titleArController.text.trim(),
        titleEn: _titleEnController.text.trim().isEmpty
            ? null
            : _titleEnController.text.trim(),
        imageFile: _selectedImage,
        linkType: _linkType.name,
        linkValue: _linkValueController.text.trim().isEmpty
            ? null
            : _linkValueController.text.trim(),
        sortOrder: int.tryParse(_sortOrderController.text) ?? 0,
        isActive: _isActive,
        startDate: _startDate,
        endDate: _endDate,
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(bottom: bottomPadding),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.outline.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title
                  Text(
                    isEditing ? 'edit_banner'.tr() : 'add_banner'.tr(),
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),

                  // Image picker
                  Text('banner_image'.tr(), style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              theme.colorScheme.outline.withValues(alpha: 0.3),
                        ),
                      ),
                      child: _selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(_selectedImage!,
                                  fit: BoxFit.cover),
                            )
                          : _existingImageUrl != null &&
                                  _existingImageUrl!.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: CachedNetworkImage(
                                    imageUrl: _existingImageUrl!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_photo_alternate,
                                        size: 48,
                                        color: theme.colorScheme.outline),
                                    const SizedBox(height: 8),
                                    Text('tap_to_select_image'.tr(),
                                        style: TextStyle(
                                            color: theme.colorScheme.outline)),
                                  ],
                                ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title AR
                  TextFormField(
                    controller: _titleArController,
                    decoration: InputDecoration(
                      labelText: 'title_ar'.tr(),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v?.isEmpty == true ? 'required_field'.tr() : null,
                  ),
                  const SizedBox(height: 16),

                  // Title EN
                  TextFormField(
                    controller: _titleEnController,
                    decoration: InputDecoration(
                      labelText: 'title_en'.tr(),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Link type
                  Text('link_type'.tr(), style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  SegmentedButton<BannerLinkType>(
                    segments: [
                      ButtonSegment(
                        value: BannerLinkType.none,
                        label: Text('none'.tr()),
                      ),
                      ButtonSegment(
                        value: BannerLinkType.product,
                        label: Text('product'.tr()),
                      ),
                      ButtonSegment(
                        value: BannerLinkType.category,
                        label: Text('category'.tr()),
                      ),
                      ButtonSegment(
                        value: BannerLinkType.offers,
                        label: Text('offers'.tr()),
                      ),
                    ],
                    selected: {_linkType},
                    onSelectionChanged: (set) =>
                        setState(() => _linkType = set.first),
                  ),
                  const SizedBox(height: 16),

                  // Link value
                  if (_linkType != BannerLinkType.none)
                    TextFormField(
                      controller: _linkValueController,
                      decoration: InputDecoration(
                        labelText: _getLinkValueLabel(),
                        border: const OutlineInputBorder(),
                        hintText: _getLinkValueHint(),
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Sort order
                  TextFormField(
                    controller: _sortOrderController,
                    decoration: InputDecoration(
                      labelText: 'sort_order'.tr(),
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  // Date range
                  Row(
                    children: [
                      Expanded(
                        child: _DateField(
                          label: 'start_date'.tr(),
                          date: _startDate,
                          onTap: () => _selectDate(true),
                          onClear: () => setState(() => _startDate = null),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _DateField(
                          label: 'end_date'.tr(),
                          date: _endDate,
                          onTap: () => _selectDate(false),
                          onClear: () => setState(() => _endDate = null),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Active switch
                  SwitchListTile(
                    title: Text('active'.tr()),
                    value: _isActive,
                    onChanged: (v) => setState(() => _isActive = v),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 24),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: theme.colorScheme.primary,
                      ),
                      child: Text(
                        isEditing ? 'save_changes'.tr() : 'add_banner'.tr(),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getLinkValueLabel() {
    switch (_linkType) {
      case BannerLinkType.product:
        return 'product_id'.tr();
      case BannerLinkType.category:
        return 'category_id'.tr();
      case BannerLinkType.url:
        return 'url'.tr();
      case BannerLinkType.offers:
        return 'offer_type'.tr();
      default:
        return '';
    }
  }

  String _getLinkValueHint() {
    switch (_linkType) {
      case BannerLinkType.product:
        return 'أدخل معرف المنتج';
      case BannerLinkType.category:
        return 'أدخل معرف القسم';
      case BannerLinkType.url:
        return 'https://...';
      case BannerLinkType.offers:
        return 'flash-sale, best-deals, new-arrivals';
      default:
        return '';
    }
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;
  final VoidCallback onClear;

  const _DateField({
    required this.label,
    this.date,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.outline)),
                  const SizedBox(height: 2),
                  Text(
                    date != null
                        ? DateFormat('yyyy-MM-dd').format(date!)
                        : 'not_set'.tr(),
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            if (date != null)
              GestureDetector(
                onTap: onClear,
                child: Icon(Icons.clear,
                    size: 18, color: theme.colorScheme.outline),
              ),
          ],
        ),
      ),
    );
  }
}
