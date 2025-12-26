import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/shared_widgets/toast.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';

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
      // Store doesn't exist yet, that's fine
    } finally {
      if (mounted) {
        setState(() => _isLoadingData = false);
      }
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
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
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
          'store_$merchantId\_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final bytes = await _selectedImage!.readAsBytes();

      await Supabase.instance.client.storage
          .from('stores')
          .uploadBinary(fileName, bytes,
              fileOptions: const FileOptions(
                contentType: 'image/jpeg',
                upsert: true,
              ));

      final publicUrl = Supabase.instance.client.storage
          .from('stores')
          .getPublicUrl(fileName);

      return publicUrl;
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
      // Upload logo if selected
      final logoUrl = await _uploadLogo(authState.user.id);

      final storeData = {
        'merchant_id': authState.user.id,
        'name': _storeNameController.text.trim(),
        'description': _storeDescController.text.trim(),
        'address': _storeAddressController.text.trim(),
        'phone': _storePhoneController.text.trim(),
        'logo_url': logoUrl,
      };

      // Upsert - insert or update if exists
      await Supabase.instance.client.from('stores').upsert(
            storeData,
            onConflict: 'merchant_id',
          );

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
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(widget.isRtl ? 'معلومات المتجر' : 'Store Information'),
      content: _isLoadingData
          ? const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            )
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Store Logo
                  GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: AppColours.brownLight.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColours.brownLight,
                              width: 2,
                            ),
                            image: _selectedImage != null
                                ? DecorationImage(
                                    image: FileImage(_selectedImage!),
                                    fit: BoxFit.cover,
                                  )
                                : _logoUrl != null
                                    ? DecorationImage(
                                        image: NetworkImage(_logoUrl!),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                          ),
                          child: _selectedImage == null && _logoUrl == null
                              ? const Icon(
                                  Icons.store,
                                  size: 48,
                                  color: AppColours.brownMedium,
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppColours.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.isRtl ? 'اضغط لتغيير الصورة' : 'Tap to change logo',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _storeNameController,
                    decoration: InputDecoration(
                      labelText: widget.isRtl ? 'اسم المتجر *' : 'Store Name *',
                      prefixIcon: const Icon(Icons.store_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _storePhoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: widget.isRtl ? 'رقم المتجر' : 'Store Phone',
                      prefixIcon: const Icon(Icons.phone_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _storeAddressController,
                    decoration: InputDecoration(
                      labelText:
                          widget.isRtl ? 'عنوان المتجر' : 'Store Address',
                      prefixIcon: const Icon(Icons.location_on_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _storeDescController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText:
                          widget.isRtl ? 'وصف المتجر' : 'Store Description',
                      prefixIcon: const Icon(Icons.description_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text(widget.isRtl ? 'إلغاء' : 'Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading || _isLoadingData ? null : _saveStore,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColours.primary,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  widget.isRtl ? 'حفظ' : 'Save',
                  style: const TextStyle(color: Colors.white),
                ),
        ),
      ],
    );
  }
}
