import 'package:e_commerce/Core/Routing/Routing.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../Core/Sharedwidgets/CustomButton.dart';
import '../../../Core/Sharedwidgets/EmailTextField.dart';
import '../../../Core/Sharedwidgets/PasswordTextField.dart';

class Forgetpasswordscreen extends StatefulWidget {
  const Forgetpasswordscreen({super.key});

  @override
  State<Forgetpasswordscreen> createState() => _ForgetpasswordscreenState();
}

class _ForgetpasswordscreenState extends State<Forgetpasswordscreen> {
  TextEditingController emailController = TextEditingController();
  String? EmailerrorMessage = null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          width: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 50,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "نسيت كلمة المرور؟",
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Text(
                  "ادخل بريدك الالكتروني لاستعادة كلمة المرور",
                  style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                ),
                SizedBox(height: 20),
                EmailTextField(
                  controller: emailController,
                ),
                SizedBox(height: 20),
                SizedBox(height: 20),
                CustomButton(
                  label: 'استعادة كلمة المرور',
                  onPressed: () {
                    context.push('/ResetPasswordScreen');
                  },
                ),
                SizedBox(height: 20),
                Text(
                  "او",
                  style: TextStyle(fontSize: 20, color: Colors.grey[700]),
                ),
                TextButton(
                    onPressed: () {
                      context.push('/ForgetPasswordUsingNUmberScreen');
                    },
                    child: Text(
                      "تسجيل الدخول باستخدام رقم الهاتف",
                      style: TextStyle(fontSize: 15, color: Color(0xFFEF6969)),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
