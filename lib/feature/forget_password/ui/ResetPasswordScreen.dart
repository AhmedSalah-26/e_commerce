import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../Core/Sharedwidgets/CustomButton.dart';
import '../../../Core/Sharedwidgets/EmailTextField.dart';
import '../../../Core/Sharedwidgets/PasswordTextField.dart';

class Resetpasswordscreen extends StatefulWidget {
  const Resetpasswordscreen({super.key});

  @override
  State<Resetpasswordscreen> createState() => _ResetpasswordscreenState();
}

class _ResetpasswordscreenState extends State<Resetpasswordscreen> {
  TextEditingController passwordcontroller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white,),
      backgroundColor: Colors.white,
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
                    Text("اعادة تعيين كلمة المرور",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),),
                  ],
                ),
                SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: "ادخل رمز التحقق",
                    prefixIcon: Icon(Icons.numbers),
                    border: OutlineInputBorder(),
                      focusColor: Colors.orange,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFFEF6969),
                        ),
                      ),
                ),),
                SizedBox(height: 20),
                Passwordtextfield(Title: 'كلمة المرور الجديدة',controller: passwordcontroller, ),
                SizedBox(height: 20),
                Passwordtextfield(Title: 'تأكيد كلمة المرور',controller: passwordcontroller, ),

                SizedBox(height: 40),
                CustomButton(label: 'تعيين كلمة المرور', onPressed: () {
                  context.go('/LoginScreen');

                },),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
