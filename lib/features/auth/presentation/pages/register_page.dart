import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/services/image_upload_service.dart';
import '../../../../core/shared_widgets/language_toggle_button.dart';
import '../../../../core/utils/error_helper.dart';
import '../../domain/entities/user_entity.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/avatar_picker.dart';
import '../widgets/role_selection_card.dart';
import '../widgets/register_form_fields.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  UserRole _selectedRole = UserRole.customer;
  Uint8List? _selectedAvatarBytes;
  String? _selectedAvatarName;
  bool _isUploadingAvatar = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      String? avatarUrl;

      // Upload avatar if selected
      if (_selectedAvatarBytes != null && _selectedAvatarName != null) {
        setState(() => _isUploadingAvatar = true);
        final imageService = sl<ImageUploadService>();
        final imageData = PickedImageData(
          bytes: _selectedAvatarBytes!,
          name: _selectedAvatarName!,
        );
        // Use email as temp folder since we don't have userId yet
        avatarUrl = await imageService.uploadImageBytes(
          imageData.bytes,
          imageData.name,
          'avatars',
          _emailController.text
              .trim()
              .replaceAll('@', '_')
              .replaceAll('.', '_'),
        );
        setState(() => _isUploadingAvatar = false);
      }

      if (!mounted) return;

      context.read<AuthCubit>().signUp(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            role: _selectedRole,
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim().isEmpty
                ? null
                : _phoneController.text.trim(),
            avatarUrl: avatarUrl,
          );
    }
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
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(left: 16, right: 16),
            child: LanguageToggleButton(),
          ),
        ],
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            AppRouter.setAuthenticated(true);
            if (state.user.isMerchant) {
              context.pushReplacement('/merchant-dashboard');
            } else {
              // New customer - go to address onboarding
              context.pushReplacement('/address-onboarding');
            }
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text(ErrorHelper.getUserFriendlyMessage(state.message)),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'create_new_account'.tr(),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'enter_your_data'.tr(),
                        style: TextStyle(
                          fontSize: 16,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      // Avatar picker
                      AvatarPicker(
                        selectedImageBytes: _selectedAvatarBytes,
                        userName: _nameController.text,
                        onPickImage: _pickAvatar,
                        onRemoveImage:
                            _selectedAvatarBytes != null ? _removeAvatar : null,
                        isLoading: _isUploadingAvatar,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'account_type'.tr(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: RoleSelectionCard(
                              title: 'customer'.tr(),
                              subtitle: 'customer_desc'.tr(),
                              icon: Icons.shopping_bag_outlined,
                              isSelected: _selectedRole == UserRole.customer,
                              onTap: () {
                                setState(() {
                                  _selectedRole = UserRole.customer;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: RoleSelectionCard(
                              title: 'merchant'.tr(),
                              subtitle: 'merchant_desc'.tr(),
                              icon: Icons.store_outlined,
                              isSelected: _selectedRole == UserRole.merchant,
                              onTap: () {
                                setState(() {
                                  _selectedRole = UserRole.merchant;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      RegisterFormFields(
                        nameController: _nameController,
                        phoneController: _phoneController,
                        emailController: _emailController,
                        passwordController: _passwordController,
                        confirmPasswordController: _confirmPasswordController,
                        obscurePassword: _obscurePassword,
                        obscureConfirmPassword: _obscureConfirmPassword,
                        onTogglePassword: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        onToggleConfirmPassword: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed:
                              state is AuthLoading ? null : _handleRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: state is AuthLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : Text(
                                  'register'.tr(),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'already_have_account'.tr(),
                            style:
                                TextStyle(color: theme.colorScheme.onSurface),
                          ),
                          TextButton(
                            onPressed: () => context.pop(),
                            child: Text(
                              'login'.tr(),
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
