import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../../auth/presentation/cubit/auth_state.dart';

class DeliveryAddressHeader extends StatelessWidget {
  final bool isRtl;
  final VoidCallback onChangeAddress;

  const DeliveryAddressHeader({
    super.key,
    required this.isRtl,
    required this.onChangeAddress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
      ),
      child: Row(
        children: [
          Icon(Icons.location_on, color: theme.colorScheme.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isRtl ? 'عنوان التوصيل' : 'Delivery Address',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              if (state is! AuthAuthenticated || state.user.addresses.isEmpty) {
                return const SizedBox.shrink();
              }
              return _ChangeButton(isRtl: isRtl, onPressed: onChangeAddress);
            },
          ),
        ],
      ),
    );
  }
}

class _ChangeButton extends StatelessWidget {
  final bool isRtl;
  final VoidCallback onPressed;

  const _ChangeButton({required this.isRtl, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(Icons.swap_horiz, size: 18, color: theme.colorScheme.primary),
      label: Text(
        isRtl ? 'تبديل' : 'Change',
        style: TextStyle(
            color: theme.colorScheme.primary, fontWeight: FontWeight.w600),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
