import 'package:device_preview/device_preview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Core/Routing/Routing.dart';
import 'feature/cart_screen/Domain/CartScreenProvider.dart';
import 'feature/favorite_page_screen/Domain/favorite_screen_provider.dart';
import 'feature/home_screen/Domain/home_screen_provider.dart';





void main() async {
  runApp(  MultiProvider(providers: [
  ChangeNotifierProvider(create: (_) => FavoriteScreenProvider()),

  ChangeNotifierProvider(create: (_) => HomeScreenProvider()),
  ChangeNotifierProvider(create: (_) => CartProvider()),

  ],child:MyApp()

  //   DevicePreview(
  //   enabled: !kReleaseMode,
  //   builder: (context) => MyApp(), // Wrap your app
  // ),
  //

  ));
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: ThemeData.light(),
      color: Colors.white,
      debugShowCheckedModeBanner: false,
      routerConfig: Routing.router,
    );
  }
}
