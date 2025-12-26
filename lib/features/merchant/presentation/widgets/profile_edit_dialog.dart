import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/shared_widgets/toast.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import 'profile_edit/profile_avatar_section.dart';
import 'profile_edit/profile_form_fields.dart';

class ProfileEditDialog extends StatefulWidget {
  final bool isRtl;

  const ProfileEditDialog({super.key, required this.isRtl});

  static Future<void> show(BuildContext context, bool isRtl) {
    return showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<AuthCubit>(),
        child: ProfileEditDialog(isRtl: isRtl),
      ),
    );
  }

  @override
  State<ProfileEditDialog> createState() => _ProfileEditDialogState();
}

class _ProfileEditDialogState extends State<ProfileEditDialog> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  // Store fields for merchants
  final _storeDescController = TextEditingController();
  final _storeAddressController = TextEditingController();
  final _storePhoneController = TextEditingController();
  bool _isLoading = false;
  bool _isLoadingStore = true;
  bool _isMerchant = false;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      _nameController = TextEditingController(text: authState.user.name ?? '');
      _phoneController =
          TextEditingController(text: authState.user.phone ?? '');
      _isMerchant = authState.user.isMerchant;
      if (_isMerchant) {
        _loadStoreData(authState.user.id);
      } else {
        _isLoadingStore = false;
      }
    } else {
      _nameController = TextEditingController();
      _phoneController = TextEditingController();
      _isLoadingStore = false;
    }
  }

  Future<void> _loadStoreData(String merchantId) async {
    try {
      final response = await Supabase.instance.client
          .from('stores')
          .select()
          .eq('merchant_id', merchantId)
          .maybeSingle();

      if (response != null && mounted) {
        setState(() {
          _storeDescController.text = response['description'] ?? '';
          _storeAddressController.text = response['address'] ?? '';
          _storePhoneController.text = response['phone'] ?? '';
        });
      }
    } catch (e) {
      // Store doesn't exist yet
    } finally {
      if (mounted) {
        setState(() => _isLoadingStore = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _storeDescController.dispose();
    _storeAddressController.dispose();
    _storePhoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) return;

    setState(() => _isLoading = true);

    try {
      // Save profile
      final success = await context.read<AuthCubit>().updateProfile(
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
          );

      // Save store info for merchants
      if (_isMerchant) {
        // Get existing store name or use user name as default
        String storeName = authState.user.name ?? 'Store';
        try {
          final existingStore = await Supabase.instance.client
              .from('stores')
              .select('name')
              .eq('merchant_id', authState.user.id)
              .maybeSingle();
          if (existingStore != null && existingStore['name'] != null) {
            storeName = existingStore['name'];
          }
        } catch (_) {}

        await Supabase.instance.client.from('stores').upsert(
          {
            'merchant_id': authState.user.id,
            'name': storeName,
            'description': _storeDescController.text.trim(),
            'address': _storeAddressController.text.trim(),
            'phone': _storePhoneController.text.trim(),
          },
          onConflict: 'merchant_id',
        );
      }

      if (mounted) {
        Navigator.pop(context);
        Tost.showCustomToast(
          context,
          success ? 'profile_updated'.tr() : 'profile_update_failed'.tr(),
          backgroundColor: success ? Colors.green : Colors.red,
        );
      }
    } catch (e) {
      if (mounted) {
        Tost.showCustomToast(
          context,
          'profile_update_failed'.tr(),
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
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) {
      return const SizedBox.shrink();
    }

    final user = authState.user;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('profile'.tr()),
      content: _isLoadingStore
          ? const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            )
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ProfileAvatarSection(userName: user.name),
                  const SizedBox(height: 16),
                  ProfileFormFields(
                    email: user.email,
                    nameController: _nameController,
                    phoneController: _phoneController,
                    isRtl: widget.isRtl,
                  ),
                  // Store fields for merchants
                  if (_isMerchant) ...[
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    Text(
                      widget.isRtl ? 'معلومات المتجر' : 'Store Information',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColours.greyDark,
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
                ],
              ),
            ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text('cancel'.tr()),
        ),
        ElevatedButton(
          onPressed: _isLoading || _isLoadingStore ? null : _saveProfile,
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
                  'save'.tr(),
                  style: const TextStyle(color: Colors.white),
                ),
        ),
      ],
    );
  }
}
