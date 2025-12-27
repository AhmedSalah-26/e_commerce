import 'package:flutter/material.dart';
import '../theme/app_text_style.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final Color? color;
  final double width;
  final double height;
  final VoidCallback onPressed;
  final double labelSize;

  const CustomButton({
    super.key,
    required this.label,
    this.color,
    this.width = 400,
    this.height = 50,
    required this.onPressed,
    this.labelSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final buttonWidth = screenWidth * 0.7;
    final buttonHeight = screenHeight * 0.06;
    final responsiveLabelSize = labelSize * (screenWidth / 400);

    return Container(
      width: buttonWidth,
      height: buttonHeight,
      decoration: BoxDecoration(
        color: color ?? theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: MaterialButton(
        onPressed: onPressed,
        child: Text(
          label,
          style: AppTextStyle.semiBold_18_white
              .copyWith(fontSize: responsiveLabelSize),
        ),
      ),
    );
  }
}
