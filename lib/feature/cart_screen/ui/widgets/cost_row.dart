import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../Core/Theme/app_text_style.dart'; // Use Material for TextStyle

class CostRow extends StatelessWidget {
  final String label;
  final double amount;
  final bool isBold;

  const CostRow({
    Key? key,
    required this.label,
    required this.amount,
    this.isBold = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize =
        screenWidth * 0.04; // Font size as a percentage of screen width

    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenWidth * 0.01),
      // Padding as a percentage of screen width
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyle.normal_12_black,
          ),
          Text("EGP ${amount.toStringAsFixed(2)}",
              style: AppTextStyle.normal_12_black.copyWith(
                fontSize: fontSize,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              )),
        ],
      ),
    );
  }
}
