import 'package:e_commerce/Core/Routing/Routing.dart';
import 'package:e_commerce/Core/Sharedwidgets/CustomButton.dart';
import 'package:e_commerce/Core/Sharedwidgets/EmailTextField.dart';
import 'package:e_commerce/Core/Sharedwidgets/PasswordTextField.dart';
import 'package:e_commerce/Core/Theme/app_text_style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../Core/Theme/app_colors.dart';

class Signupscreen extends StatefulWidget {
  const Signupscreen({super.key});

  @override
  State<Signupscreen> createState() => _SignupscreenState();
}

class _SignupscreenState extends State<Signupscreen> {
  String? errorMessage = null;
  String? EmailerrorMessage = null;

  TextEditingController passwordController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          double imageSize = constraints.maxWidth * 0.4; // 40% of screen width
          double fontSize = constraints.maxWidth > 600 ? 30 : 24; // Larger font for wider screens

          return Padding(
            padding: EdgeInsets.all(constraints.maxWidth * 0.05), // 5% of screen width
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: constraints.maxHeight * 0.1), // 10% of screen height
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        width: imageSize,
                        height: imageSize,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          image: DecorationImage(
                            image: AssetImage("assets/on_bording/Tosca & Brown Retro Minimalist Ajwa Dates Badge Logo (2).png"),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      SizedBox(width: constraints.maxWidth * 0.05), // Space between image and text
                      Text(
                        "مرحبا بك",
                        style: AppTextStyle.semiBold_16_dark_brown.copyWith(fontSize: fontSize),
                      ),
                    ],
                  ),
                  SizedBox(height: constraints.maxHeight * 0.02), // 2% of screen height
                  TextFormField(
                    decoration: InputDecoration(
                      focusColor: AppColours.brownLight,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColours.primaryColor,
                        ), // Set the focus color here
                      ),
                      prefixIcon: Icon(Icons.person, color: AppColours.primaryColor),
                      hintText: "الاسم",
                      hintStyle: AppTextStyle.normal_16_greyDark, // Use your defined style

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  SizedBox(height: constraints.maxHeight * 0.02), // 2% of screen height
                  EmailTextField(controller: emailController),
                  SizedBox(height: constraints.maxHeight * 0.02), // 2% of screen height
                  Passwordtextfield(Title: 'الرقم السري', controller: passwordController),
                  SizedBox(height: constraints.maxHeight * 0.02), // 2% of screen height
                  Passwordtextfield(Title: 'تأكيد الرقم السري', controller: confirmPasswordController),
                  SizedBox(height: constraints.maxHeight * 0.02), // 2% of screen height
                  CustomButton(
                    label: 'تسجيل',
                    onPressed: () {
                      if (_validateInputs()) {
                        context.go('/LoginScreen');
                      }
                    },
                  ),
                  SizedBox(height: constraints.maxHeight * 0.02), // 2% of screen height
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                      onPressed: () {
                        context.go('/LoginScreen');
                      },
                      child: Text(
                        "تسجيل الدخول",
                        style: TextStyle(
                          color: Color(0xFFEF6969),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                      Text("هل لديك حساب؟", style: AppTextStyle.normal_16_brownLight),

                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  bool _validateInputs() {
    if (emailController.text.isEmpty || passwordController.text.isEmpty || confirmPasswordController.text.isEmpty) {
      setState(() {
        errorMessage = 'يجب تعبئة جميع الحقول';
      });
      return false;
    }
    if (passwordController.text != confirmPasswordController.text) {
      setState(() {
        errorMessage = 'الرقم السري غير متطابق';
      });
      return false;
    }
    return true;
  }
}
