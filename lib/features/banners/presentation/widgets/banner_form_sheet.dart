import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/entities/banner_entity.dart';
import '../cubit/admin_banners_cubit.dart';
import 'banner_date_field.dart';
import 'banner_image_picker.dart';
import 'banner_link_type_selector.dart';
import 'offers_type_dropdown.dart';

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
    _sortOrderController = TextEditingController(
      text: widget.banner?.sortOrder.toString() ?? '0',
    );

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
                  _buildHandle(theme),
                  const SizedBox(height: 20),
                  _buildTitle(theme),
                  const SizedBox(height: 24),
                  _buildImageSection(theme),
                  const SizedBox(height: 16),
                  _buildTitleFields(),
                  const SizedBox(height: 16),
                  _buildLinkSection(theme),
                  const SizedBox(height: 16),
                  _buildSortOrderField(),
                  const SizedBox(height: 16),
                  _buildDateRange(),
                  const SizedBox(height: 16),
                  _buildActiveSwitch(),
                  const SizedBox(height: 24),
                  _buildSubmitButton(theme),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHandle(ThemeData theme) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildTitle(ThemeData theme) {
    return Text(
      isEditing ? 'edit_banner'.tr() : 'add_banner'.tr(),
      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildImageSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('banner_image'.tr(), style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        BannerImagePicker(
          selectedImage: _selectedImage,
          existingImageUrl: _existingImageUrl,
          onTap: _pickImage,
        ),
      ],
    );
  }

  Widget _buildTitleFields() {
    return Column(
      children: [
        TextFormField(
          controller: _titleArController,
          decoration: InputDecoration(
            labelText: 'title_ar'.tr(),
            border: const OutlineInputBorder(),
          ),
          validator: (v) => v?.isEmpty == true ? 'required_field'.tr() : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _titleEnController,
          decoration: InputDecoration(
            labelText: 'title_en'.tr(),
            border: const OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildLinkSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('link_type'.tr(), style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        BannerLinkTypeSelector(
          selectedType: _linkType,
          onChanged: (type) => setState(() => _linkType = type),
        ),
        const SizedBox(height: 16),
        if (_linkType != BannerLinkType.none) _buildLinkValueField(),
      ],
    );
  }

  Widget _buildLinkValueField() {
    if (_linkType == BannerLinkType.offers) {
      return OffersTypeDropdown(
        value: _linkValueController.text.isEmpty
            ? null
            : _linkValueController.text,
        onChanged: (value) {
          setState(() => _linkValueController.text = value ?? '');
        },
      );
    }

    return TextFormField(
      controller: _linkValueController,
      decoration: InputDecoration(
        labelText: _getLinkValueLabel(),
        border: const OutlineInputBorder(),
        hintText: _getLinkValueHint(),
      ),
    );
  }

  Widget _buildSortOrderField() {
    return TextFormField(
      controller: _sortOrderController,
      decoration: InputDecoration(
        labelText: 'sort_order'.tr(),
        border: const OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
    );
  }

  Widget _buildDateRange() {
    return Row(
      children: [
        Expanded(
          child: BannerDateField(
            label: 'start_date'.tr(),
            date: _startDate,
            onTap: () => _selectDate(true),
            onClear: () => setState(() => _startDate = null),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: BannerDateField(
            label: 'end_date'.tr(),
            date: _endDate,
            onTap: () => _selectDate(false),
            onClear: () => setState(() => _endDate = null),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveSwitch() {
    return SwitchListTile(
      title: Text('active'.tr()),
      value: _isActive,
      onChanged: (v) => setState(() => _isActive = v),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildSubmitButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submit,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          backgroundColor: theme.colorScheme.primary,
        ),
        child: Text(
          isEditing ? 'save_changes'.tr() : 'add_banner'.tr(),
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
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
      default:
        return '';
    }
  }
}
