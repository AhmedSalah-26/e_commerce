import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../cubit/coupon_cubit.dart';
import '../../cubit/coupon_state.dart';

class CouponFormActions extends StatelessWidget {
  final VoidCallback onSave;

  const CouponFormActions({super.key, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
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
                    backgroundColor: AppColours.brownMedium,
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
