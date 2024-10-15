import 'package:e_commerce/Core/Routing/Routing.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../Core/Sharedwidgets/CustomButton.dart';
import '../../../Core/Sharedwidgets/PasswordTextField.dart';

class ForgetPasswordUsingNumberScreen extends StatefulWidget {
  const ForgetPasswordUsingNumberScreen({super.key});

  @override
  State<ForgetPasswordUsingNumberScreen> createState() => _ForgetPasswordUsingNumberScreenState();
}

class _ForgetPasswordUsingNumberScreenState extends State<ForgetPasswordUsingNumberScreen> {
  String? numberErrorMessage = null;
  final TextEditingController _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white,),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          width: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                SizedBox(height: 50),

                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "نسيت كلمة المرور؟",
                      style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Text(
                  "ادخل رقم هاتفك لاستعادة كلمة المرور",
                  style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                ),
                SizedBox(height: 20),

                // Phone number input field
                TextFormField(

                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.phone),
                    labelText: 'رقم الهاتف',
                    hintText: 'ادخل رقم الهاتف',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),

                CustomButton(label: 'استعادة كلمة المرور', onPressed: () {
                  // Handle the phone number submission here
                  context.push('/OtpScreen');
                }),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
