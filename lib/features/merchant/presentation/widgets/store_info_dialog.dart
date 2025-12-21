import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      final storeData = {
        'merchant_id': authState.user.id,
        'name': _storeNameController.text.trim(),
        'description': _storeDescController.text.trim(),
        'address': _storeAddressController.text.trim(),
        'phone': _storePhoneController.text.trim(),
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
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColours.brownLight.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.store,
                      size: 48,
                      color: AppColours.brownMedium,
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
