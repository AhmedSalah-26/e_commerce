import 'package:flutter/material.dart';
import '../../../../../core/theme/app_text_style.dart';

class CartItemQuantityControl extends StatelessWidget {
  final int quantity;
  final double fontSize;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const CartItemQuantityControl({
    super.key,
    required this.quantity,
    required this.fontSize,
    required this.onIncrease,
    required this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
      ),
      child: Column(
        children: [
          IconButton(
            icon: Icon(
              Icons.add,
              color: Colors.green,
              size: fontSize * 1.2,
            ),
            onPressed: onIncrease,
          ),
          SizedBox(
            width: 30,
            height: 24,
            child: Center(
              child: Text(
                '${quantity < 1 ? 1 : quantity}',
                style: AppTextStyle.bold_18_medium_brown
                    .copyWith(fontSize: fontSize),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.remove,
              color: Colors.red,
              size: fontSize * 1.2,
            ),
            onPressed: onDecrease,
          ),
        ],
      ),
    );
  }
}
