import 'package:material_ui/material_ui.dart';

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
        foregroundColor: const WidgetStatePropertyAll(Colors.black),
        shadowColor: const WidgetStatePropertyAll(
          Color.fromARGB(160, 242, 135, 5),
        ),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        elevation: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.pressed) ? 2 : 8,
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: Colors.white.withAlpha(70),
              width: 1.5,
            ),
          ),
        ),
        textStyle: const WidgetStatePropertyAll(TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        )),
      ),
    ));
