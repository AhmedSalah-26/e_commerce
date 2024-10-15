import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';

import '../../../../../Core/Sharedwidgets/CustomButton.dart';
import '../../../Core/Theme/app_colors.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  String otp = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white,),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: [
                    Text(
                      "ادخل رمز التحقق",
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Text("ادخل رمز التحقق الذي تم ارساله للبريد الالكتروني",style: TextStyle(fontSize: 15, color: Colors.grey[700]),),
                SizedBox(height: 100),
                Pinput(

                  length: 4, // Number of OTP fields
                  onCompleted: (String value) {
                    setState(() {
                      otp = value;
                    });
                    // Handle OTP completion
                  },
                  onChanged: (String value) {
                    setState(() {
                      otp = value;
                    });
                  },
                  defaultPinTheme: PinTheme(
                    width: 60,
                    height: 60,
                    textStyle: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                    ),
                    decoration: BoxDecoration(

                      border: Border.all(color: AppColours.primaryColor),
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  focusedPinTheme: PinTheme(
                    width: 60,
                    height: 60,
                    textStyle: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                    ),
                    decoration: BoxDecoration(
                      color: AppColours.primaryColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                SizedBox(height: 100),
                CustomButton(
                  label: 'ارسال',
                  onPressed: () {
                    // Handle OTP verification
                    context.go('/ResetPasswordScreen'); // Navigate to Reset Password screen
                  },
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
