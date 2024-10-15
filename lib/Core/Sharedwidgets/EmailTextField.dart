import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../Theme/app_colors.dart';
import '../Theme/app_text_style.dart';
import 'package:e_commerce/Core/Helpers/EmailValidationHelper.dart';

class EmailTextField extends StatefulWidget {
  final TextEditingController controller;

  EmailTextField({super.key, required this.controller});

  @override
  State<EmailTextField> createState() => _EmailTextFieldState();
}

class _EmailTextFieldState extends State<EmailTextField> {

  bool _showClearIcon = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      setState(() {
        _showClearIcon = widget.controller.text.isNotEmpty;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: EmailValidationHelper.validateEmail,
      controller: widget.controller,
      decoration: InputDecoration(
        focusColor: AppColours.brownMedium, // Use your defined color
        suffixIcon: _showClearIcon
            ? IconButton(
          icon: Icon(Icons.clear, color: AppColours.brownMedium), // Use your defined color
          onPressed: () {
            setState(() {
              widget.controller.clear();
            });
          },
        )
            : null,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: AppColours.brownMedium, // Use your defined color
          ),
        ),
        prefixIcon: Icon(Icons.email, color: AppColours.brownMedium), // Use your defined color
        hintText: "البريد الالكتروني",
        hintStyle: AppTextStyle.normal_16_greyDark, // Use your defined style
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10), // Optional: Customize border radius
        ),
      ),
      keyboardType: TextInputType.emailAddress,
    );
  }
}
