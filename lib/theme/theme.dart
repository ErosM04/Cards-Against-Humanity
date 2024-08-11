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
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor:
            const WidgetStatePropertyAll(Color.fromARGB(255, 242, 135, 5)),
        shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
        padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(vertical: 10, horizontal: 15)),
        textStyle: const WidgetStatePropertyAll(TextStyle(
            fontSize: 25, fontWeight: FontWeight.bold, color: Colors.black)),
      ),
    ));
