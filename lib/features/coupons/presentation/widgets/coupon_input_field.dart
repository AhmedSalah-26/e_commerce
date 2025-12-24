import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/coupon_validation_result.dart';
import '../cubit/coupon_cubit.dart';
import '../cubit/coupon_state.dart';

class CouponInputField extends StatefulWidget {
  final String userId;
  final double orderAmount;
  final String? storeId;
  final void Function(CouponValidationResult?)? onCouponChanged;

  const CouponInputField({
    super.key,
    required this.userId,
    required this.orderAmount,
    this.storeId,
    this.onCouponChanged,
  });

  @override
  State<CouponInputField> createState() => _CouponInputFieldState();
}

class _CouponInputFieldState extends State<CouponInputField> {
  final _controller = TextEditingController();
  bool _isExpanded = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _applyCoupon() {
    final code = _controller.text.trim();
    if (code.isEmpty) return;

    context.read<CouponCubit>().validateAndApplyCoupon(
          code: code,
          userId: widget.userId,
          orderAmount: widget.orderAmount,
          storeId: widget.storeId,
        );
  }

  void _removeCoupon() {
    _controller.clear();
    context.read<CouponCubit>().removeCoupon();
    widget.onCouponChanged?.call(null);
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.locale.languageCode;

    return BlocConsumer<CouponCubit, CouponState>(
      listener: (context, state) {
        if (state is CouponApplied) {
          widget.onCouponChanged?.call(state.result);
        } else if (state is CouponRemoved) {
          widget.onCouponChanged?.call(null);
        }
      },
      builder: (context, state) {
        final isApplied = state is CouponApplied;
        final isLoading = state is CouponValidating;
        final hasError = state is CouponError;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isApplied
                  ? Colors.green.shade300
                  : hasError
                      ? Colors.red.shade300
                      : AppColours.greyLight,
            ),
          ),
          child: Column(
            children: [
              // Header
              InkWell(
                onTap: isApplied
                    ? null
                    : () => setState(() => _isExpanded = !_isExpanded),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        isApplied
                            ? Icons.check_circle
                            : Icons.local_offer_outlined,
                        color:
                            isApplied ? Colors.green : AppColours.brownMedium,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Builder(builder: (context) {
                              final appliedState =
                                  state is CouponApplied ? state : null;
                              return Text(
                                isApplied
                                    ? appliedState?.result.getName(locale) ??
                                        'coupon_applied'.tr()
                                    : 'have_coupon'.tr(),
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: isApplied
                                      ? Colors.green.shade700
                                      : AppColours.brownDark,
                                ),
                              );
                            }),
                            if (state is CouponApplied) ...[
                              const SizedBox(height: 2),
                              Text(
                                '${'discount'.tr()}: ${state.result.discountAmount?.toStringAsFixed(2)} ${'currency'.tr()}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.green.shade600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (isApplied)
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: _removeCoupon,
                          tooltip: 'remove_coupon'.tr(),
                        )
                      else
                        Icon(
                          _isExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: AppColours.greyMedium,
                        ),
                    ],
                  ),
                ),
              ),

              // Input Field
              if (_isExpanded && !isApplied)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              textCapitalization: TextCapitalization.characters,
                              decoration: InputDecoration(
                                hintText: 'enter_coupon_code'.tr(),
                                hintStyle: const TextStyle(
                                    color: AppColours.greyMedium),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: AppColours.greyLight),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: AppColours.greyLight),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: AppColours.brownMedium),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _applyCoupon,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColours.brownMedium,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text('apply'.tr()),
                            ),
                          ),
                        ],
                      ),
                      if (state is CouponError) ...[
                        const SizedBox(height: 8),
                        Text(
                          state.getMessage(locale),
                          style: TextStyle(
                            color: Colors.red.shade600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
