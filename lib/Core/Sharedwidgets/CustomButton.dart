import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../Theme/app_colors.dart';
import '../Theme/app_text_style.dart';

class CustomButton extends StatefulWidget {
  final String label;
  final Color color;
  final double width;
  final double height;
  final VoidCallback onPressed;
  final double labelSize;

  CustomButton({
    this.labelSize = 20,
    Key? key,
    required this.label,
    this.color = AppColours.brownLight,
    this.width = 400,
    this.height = 50,
    required this.onPressed,
  }) : super(key: key);

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  @override
  Widget build(BuildContext context) {
    // Get screen width and height using MediaQuery
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Calculate responsive width, height, and label size
    final buttonWidth = screenWidth *0.7;
    final buttonHeight = screenHeight * 0.06; // 7% of the screen height
    final labelSize = widget.labelSize * (screenWidth / 400); // Adjust label size based on screen width

    return Container(
      width: buttonWidth,
      height: buttonHeight,
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: MaterialButton(
        child: Text(
          widget.label,
          style: AppTextStyle.semiBold_18_white.copyWith(fontSize: labelSize),
        ),
        onPressed: widget.onPressed,
      ),
    );
  }
}
