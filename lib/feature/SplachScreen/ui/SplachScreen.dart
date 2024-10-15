import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


class SplachScreen extends StatefulWidget {
  const SplachScreen({super.key});

  @override
  State<SplachScreen> createState() => _SplachScreenState();
}

class _SplachScreenState extends State<SplachScreen> {
  void initState() {
    Timer(
      Duration(seconds: 3),
      () {
        context.go('/OnBoardingScreen');
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
              color: Colors.black,
              image: DecorationImage(
                  image: AssetImage('assets/V.png'),
                  fit: BoxFit.cover,
                  opacity: 0.5)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[

              Image.asset("assets/on_bording/Tosca & Brown Retro Minimalist Ajwa Dates Badge Logo (2).png",
              width: 250,
                height: 250,
              )
             
            ],
          ),
        ),
      ),
    );
  }
}
