import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/image_upload_service.dart';
import '../../../../core/shared_widgets/toast.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../auth/presentation/widgets/avatar_picker.dart';
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
  bool _isLoading = false;
  bool _isUploadingAvatar = false;
  Uint8List? _selectedAvatarBytes;
  String? _selectedAvatarName;
  String? _currentAvatarUrl;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      _nameController = TextEditingController(text: authState.user.name ?? '');
      _phoneController =
          TextEditingController(text: authState.user.phone ?? '');
      _currentAvatarUrl = authState.user.avatarUrl;
    } else {
      _nameController = TextEditingController();
      _phoneController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final imageService = sl<ImageUploadService>();
    final pickedImage = await imageService.pickAvatarImage();
    if (pickedImage != null) {
      setState(() {
        _selectedAvatarBytes = pickedImage.bytes;
        _selectedAvatarName = pickedImage.name;
      });
    }
  }

  void _removeAvatar() {
    setState(() {
      _selectedAvatarBytes = null;
      _selectedAvatarName = null;
      _currentAvatarUrl = null;
    });
  }

  Future<void> _saveProfile() async {
    final authCubit = context.read<AuthCubit>();
    final authState = authCubit.state;
    if (authState is! AuthAuthenticated) return;

    setState(() => _isLoading = true);

    try {
      String? newAvatarUrl;
      final user = authState.user;

      // Upload new avatar if selected
      if (_selectedAvatarBytes != null && _selectedAvatarName != null) {
        setState(() => _isUploadingAvatar = true);
        final imageService = sl<ImageUploadService>();
        final imageData = PickedImageData(
          bytes: _selectedAvatarBytes!,
          name: _selectedAvatarName!,
        );
        // Pass old avatar URL to delete it after uploading new one
        newAvatarUrl = await imageService.uploadAvatarImage(
          imageData,
          user.id,
          oldAvatarUrl: user.avatarUrl,
        );
        if (!mounted) return;
        setState(() => _isUploadingAvatar = false);
      }

      final success = await authCubit.updateProfile(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        avatarUrl: newAvatarUrl,
      );

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
        setState(() {
          _isLoading = false;
          _isUploadingAvatar = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) return const SizedBox.shrink();

    final user = authState.user;

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
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person_outline,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'profile'.tr(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AvatarPicker(
                      currentAvatarUrl: _currentAvatarUrl,
                      selectedImageBytes: _selectedAvatarBytes,
                      userName: user.name ?? user.email,
                      onPickImage: _pickAvatar,
                      onRemoveImage: (_currentAvatarUrl != null ||
                              _selectedAvatarBytes != null)
                          ? _removeAvatar
                          : null,
                      isLoading: _isUploadingAvatar,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.isRtl
                          ? 'اضغط لتغيير الصورة'
                          : 'Tap to change photo',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ProfileFormFields(
                      email: user.email,
                      nameController: _nameController,
                      phoneController: _phoneController,
                      isRtl: widget.isRtl,
                    ),
                  ],
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
                      onPressed:
                          _isLoading ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: theme.colorScheme.outline),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        'cancel'.tr(),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : Text(
                              'save'.tr(),
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w600),
                            ),
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
}
