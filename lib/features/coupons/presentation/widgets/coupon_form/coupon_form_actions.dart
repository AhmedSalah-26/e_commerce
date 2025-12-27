import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/coupon_cubit.dart';
import '../../cubit/coupon_state.dart';

class CouponFormActions extends StatelessWidget {
  final VoidCallback onSave;

  const CouponFormActions({super.key, required this.onSave});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
            top: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.3))),
      ),
      child: BlocBuilder<MerchantCouponsCubit, CouponState>(
        builder: (context, state) {
          final isLoading = state is CouponSaving;
          return Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  child: Text('cancel'.tr()),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: isLoading ? null : onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text('save'.tr()),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
