import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../Core/Sharedwidgets/CustomButton.dart';
import '../../../Core/Sharedwidgets/EmailTextField.dart';
import '../../../Core/Sharedwidgets/PasswordTextField.dart';
import '../../../Core/Theme/app_text_style.dart';

class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Determine the size of the elements based on screen width
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
                      SizedBox(width: 20), // Space between image and text
                      Text(
                        "مرحبا بك",
                        style: AppTextStyle.semiBold_16_dark_brown.copyWith(fontSize: fontSize),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        EmailTextField(
                          controller: emailController,
                        ),
                        SizedBox(height: constraints.maxHeight * 0.02), // 2% of screen height
                        Passwordtextfield(
                          Title: 'الرقم السري',
                          controller: passwordController,
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        context.push('/ForgetPasswordScreen');
                      },
                      child: Text(
                        "نسيت كلمة المرور؟",
                        style: TextStyle(
                          color: Color(0xFFEF6969),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: constraints.maxHeight * 0.02), // 2% of screen height
                  CustomButton(
                    label: 'تسجيل الدخول',
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        context.go("/HomeNavigationScreen");
                      }
                    },
                  ),
                  SizedBox(height: constraints.maxHeight * 0.02), // 2% of screen height
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                      onPressed: () {
                        context.go('/SignupScreen');
                      },
                      child: Text(
                        "تسجيل حساب جديد",
                        style: TextStyle(
                          color: Color(0xFFEF6969),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                      Text(
                        "ليس لديك حساب؟",
                        style: AppTextStyle.normal_16_brownLight,
                      ),

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
}
