import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/shared_widgets/toast.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import 'store_info/store_dialog_header.dart';
import 'store_info/store_logo_picker.dart';
import 'store_info/store_form_fields.dart';
import 'store_info/store_dialog_actions.dart';

class StoreInfoDialog extends StatefulWidget {
  final bool isRtl;

  const StoreInfoDialog({super.key, required this.isRtl});

  static Future<void> show(BuildContext context, bool isRtl) {
    return showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<AuthCubit>(),
        child: StoreInfoDialog(isRtl: isRtl),
      ),
    );
  }

  @override
  State<StoreInfoDialog> createState() => _StoreInfoDialogState();
}

class _StoreInfoDialogState extends State<StoreInfoDialog> {
  final _storeNameController = TextEditingController();
  final _storeDescController = TextEditingController();
  final _storeAddressController = TextEditingController();
  final _storePhoneController = TextEditingController();
  bool _isLoading = false;
  bool _isLoadingData = true;
  String? _logoUrl;
  File? _selectedImage;
  final _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadStoreData();
  }

  Future<void> _loadStoreData() async {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) return;

    try {
      final response = await Supabase.instance.client
          .from('stores')
          .select()
          .eq('merchant_id', authState.user.id)
          .maybeSingle();

      if (response != null && mounted) {
        setState(() {
          _storeNameController.text = response['name'] ?? '';
          _storeDescController.text = response['description'] ?? '';
          _storeAddressController.text = response['address'] ?? '';
          _storePhoneController.text = response['phone'] ?? '';
          _logoUrl = response['logo_url'];
        });
      }
    } catch (e) {
      debugPrint('StoreInfoDialog: Error loading store data: $e');
    } finally {
      if (mounted) setState(() => _isLoadingData = false);
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() => _selectedImage = File(pickedFile.path));
      }
    } catch (e) {
      if (mounted) {
        Tost.showCustomToast(
          context,
          widget.isRtl ? 'فشل في اختيار الصورة' : 'Failed to pick image',
          backgroundColor: Colors.red,
        );
      }
    }
  }

  Future<String?> _uploadLogo(String merchantId) async {
    if (_selectedImage == null) return _logoUrl;

    try {
      final fileName =
          'store_${merchantId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final bytes = await _selectedImage!.readAsBytes();

      await Supabase.instance.client.storage.from('stores').uploadBinary(
            fileName,
            bytes,
            fileOptions:
                const FileOptions(contentType: 'image/jpeg', upsert: true),
          );

      return Supabase.instance.client.storage
          .from('stores')
          .getPublicUrl(fileName);
    } catch (e) {
      debugPrint('Error uploading logo: $e');
      return _logoUrl;
    }
  }

  Future<void> _saveStore() async {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) return;

    if (_storeNameController.text.trim().isEmpty) {
      Tost.showCustomToast(
        context,
        widget.isRtl ? 'اسم المتجر مطلوب' : 'Store name is required',
        backgroundColor: Colors.red,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final logoUrl = await _uploadLogo(authState.user.id);

      await Supabase.instance.client.from('stores').upsert({
        'merchant_id': authState.user.id,
        'name': _storeNameController.text.trim(),
        'description': _storeDescController.text.trim(),
        'address': _storeAddressController.text.trim(),
        'phone': _storePhoneController.text.trim(),
        'logo_url': logoUrl,
      }, onConflict: 'merchant_id');

      if (mounted) {
        Navigator.pop(context);
        Tost.showCustomToast(
          context,
          widget.isRtl ? 'تم حفظ معلومات المتجر' : 'Store info saved',
          backgroundColor: Colors.green,
        );
      }
    } catch (e) {
      if (mounted) {
        Tost.showCustomToast(
          context,
          widget.isRtl ? 'فشل في حفظ البيانات' : 'Failed to save',
          backgroundColor: Colors.red,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _storeDescController.dispose();
    _storeAddressController.dispose();
    _storePhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            StoreDialogHeader(
              isRtl: widget.isRtl,
              onClose: () => Navigator.pop(context),
            ),
            Flexible(
              child: _isLoadingData
                  ? const SizedBox(
                      height: 100,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          StoreLogoPicker(
                            selectedImage: _selectedImage,
                            logoUrl: _logoUrl,
                            onTap: _pickImage,
                            isRtl: widget.isRtl,
                          ),
                          const SizedBox(height: 20),
                          StoreFormFields(
                            nameController: _storeNameController,
                            phoneController: _storePhoneController,
                            addressController: _storeAddressController,
                            descController: _storeDescController,
                            isRtl: widget.isRtl,
                          ),
                        ],
                      ),
                    ),
            ),
            StoreDialogActions(
              isLoading: _isLoading,
              isLoadingData: _isLoadingData,
              isRtl: widget.isRtl,
              onCancel: () => Navigator.pop(context),
              onSave: _saveStore,
            ),
          ],
        ),
      ),
    );
  }
}
