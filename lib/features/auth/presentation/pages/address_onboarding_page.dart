import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/shared_widgets/toast.dart';
import '../../domain/entities/user_entity.dart';
import '../cubit/auth_cubit.dart';
import '../../../shipping/domain/entities/governorate_entity.dart';
import '../../../shipping/presentation/cubit/shipping_cubit.dart';

class AddressOnboardingPage extends StatefulWidget {
  const AddressOnboardingPage({super.key});

  @override
  State<AddressOnboardingPage> createState() => _AddressOnboardingPageState();
}

class _AddressOnboardingPageState extends State<AddressOnboardingPage> {
  final _titleController = TextEditingController();
  final _addressController = TextEditingController();
  GovernorateEntity? _selectedGovernorate;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRtl = context.locale.languageCode == 'ar';

    return BlocProvider(
      create: (_) => sl<ShippingCubit>()..loadGovernorates(),
      child: Directionality(
        textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
        child: Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  _buildHeader(theme, isRtl),
                  const SizedBox(height: 40),
                  _buildForm(theme, isRtl),
                  const SizedBox(height: 32),
                  _buildButtons(theme, isRtl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, bool isRtl) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.location_on,
            size: 48,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          isRtl ? 'أضف عنوانك الأول' : 'Add Your First Address',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          isRtl
              ? 'أضف عنوان التوصيل لتسهيل عملية الطلب'
              : 'Add your delivery address for easier checkout',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildIllustration(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStep(theme, Icons.home_outlined, '1', true),
          _buildArrow(theme),
          _buildStep(theme, Icons.shopping_cart_outlined, '2', false),
          _buildArrow(theme),
          _buildStep(theme, Icons.local_shipping_outlined, '3', false),
        ],
      ),
    );
  }

  Widget _buildStep(
      ThemeData theme, IconData icon, String number, bool isActive) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: isActive
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isActive ? Colors.white : theme.colorScheme.outline,
            size: 28,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isActive
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                color: isActive ? Colors.white : theme.colorScheme.outline,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildArrow(ThemeData theme) {
    return Icon(
      Icons.arrow_forward,
      color: theme.colorScheme.outline.withValues(alpha: 0.4),
      size: 20,
    );
  }

  Widget _buildForm(ThemeData theme, bool isRtl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _titleController,
          decoration: InputDecoration(
            labelText: isRtl ? 'اسم العنوان' : 'Address Title',
            hintText: isRtl ? 'مثال: المنزل، العمل' : 'e.g. Home, Work',
            prefixIcon: const Icon(Icons.label_outline),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),
        BlocBuilder<ShippingCubit, ShippingState>(
          builder: (context, state) {
            List<GovernorateEntity> governorates = [];
            if (state is GovernoratesLoaded) {
              governorates = state.governorates;
            }

            return DropdownButtonFormField<GovernorateEntity>(
              value: _selectedGovernorate,
              decoration: InputDecoration(
                labelText: isRtl ? 'المحافظة' : 'Governorate',
                prefixIcon: const Icon(Icons.location_city),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: governorates.map((gov) {
                return DropdownMenuItem(
                  value: gov,
                  child: Text(gov.getName(isRtl ? 'ar' : 'en')),
                );
              }).toList(),
              onChanged: (value) =>
                  setState(() => _selectedGovernorate = value),
            );
          },
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _addressController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: isRtl ? 'العنوان التفصيلي' : 'Detailed Address',
            hintText: isRtl
                ? 'الشارع، المبنى، الشقة...'
                : 'Street, Building, Apartment...',
            prefixIcon: const Icon(Icons.home_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildButtons(ThemeData theme, bool isRtl) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveAddress,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : Text(
                    isRtl ? 'حفظ والمتابعة' : 'Save & Continue',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: _isLoading ? null : _skip,
          child: Text(
            isRtl ? 'تخطي الآن' : 'Skip for now',
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveAddress() async {
    final isRtl = context.locale.languageCode == 'ar';

    if (_titleController.text.trim().isEmpty) {
      _showError(
          isRtl ? 'يرجى إدخال اسم العنوان' : 'Please enter address title');
      return;
    }
    if (_selectedGovernorate == null) {
      _showError(isRtl ? 'يرجى اختيار المحافظة' : 'Please select governorate');
      return;
    }
    if (_addressController.text.trim().isEmpty) {
      _showError(isRtl
          ? 'يرجى إدخال العنوان التفصيلي'
          : 'Please enter detailed address');
      return;
    }

    setState(() => _isLoading = true);

    final address = UserAddress.create(
      governorateId: _selectedGovernorate!.id,
      detailedAddress: _addressController.text.trim(),
      title: _titleController.text.trim(),
      isDefault: true,
    );

    final success = await context.read<AuthCubit>().addAddress(address);

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        Tost.showCustomToast(
          context,
          isRtl ? 'تم حفظ العنوان بنجاح' : 'Address saved successfully',
          backgroundColor: Colors.green,
        );
      }
      _navigateToHome();
    }
  }

  void _skip() {
    _navigateToHome();
  }

  void _navigateToHome() {
    context.go('/home');
  }

  void _showError(String message) {
    Tost.showCustomToast(context, message, backgroundColor: Colors.red);
  }
}
