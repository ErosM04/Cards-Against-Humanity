import 'package:flutter/material.dart';

ThemeData appTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    primary: Color.fromARGB(255, 242, 135, 5),
    secondary: Color.fromARGB(255, 242, 116, 5),
    tertiary: Color.fromARGB(255, 89, 50, 2),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
  ),
);
