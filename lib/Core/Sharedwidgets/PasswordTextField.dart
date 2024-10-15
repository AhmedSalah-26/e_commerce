import 'package:e_commerce/Core/Helpers/PasswordValidationHelper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../Theme/app_colors.dart';
import '../Theme/app_text_style.dart';


class Passwordtextfield extends StatefulWidget {
  final String Title;
  final TextEditingController controller;

  Passwordtextfield({
    super.key,
    required this.Title,
    required this.controller,
  });

  @override
  State<Passwordtextfield> createState() => _PasswordtextfieldState();
}

class _PasswordtextfieldState extends State<Passwordtextfield> {
  bool obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: PasswordValidationHelper.validatePassword,
      controller: widget.controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            color: AppColours.brownMedium, // Use your defined color
          ),
          onPressed: () {
            setState(() {
              obscureText = !obscureText;
            });
          },
        ),
        prefixIcon: Icon(
          Icons.lock,
          color: AppColours.brownMedium, // Use your defined color
        ),
        hintText: widget.Title,
        hintStyle: AppTextStyle.normal_16_greyDark, // Use your defined style
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10), // Optional: Customize border radius
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: AppColours.brownMedium, // Use your defined color
          ),
        ),
      ),
    );
  }
}
