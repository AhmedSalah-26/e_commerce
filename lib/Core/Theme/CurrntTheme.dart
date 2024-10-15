import 'package:flutter/material.dart';

abstract class CurrentTheme{

ThemeData getTheme();


}
 class LightTheme extends CurrentTheme{
  @override
  ThemeData getTheme() {
    // TODO: implement getTheme
    throw UnimplementedError();
  }
}
class DarkTheme extends CurrentTheme{
  @override
  ThemeData getTheme() {
    // TODO: implement getTheme
    throw UnimplementedError();
  }
}