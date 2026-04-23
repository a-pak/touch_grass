import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get theme => ThemeData(
    brightness: Brightness.dark,
    textTheme: const TextTheme(bodyMedium: TextStyle(color: Color(0xFF1A1A2E))),
    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(
        iconColor: WidgetStateProperty.all(const Color(0xFF1A1A2E)),
        iconSize: WidgetStateProperty.all(28),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Color.fromARGB(128, 0, 0, 0),
        shadowColor: Colors.transparent,
        ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(foregroundColor: Colors.white),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: Colors.white),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: Color(0xFF1A1A2E),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Color.fromARGB(217, 0, 0, 0),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      contentTextStyle: TextStyle(color: Colors.white, fontSize: 16),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: Color.fromARGB(97, 0, 0, 0),
      indicatorColor: Color.fromARGB(255, 101, 104, 105),
    ),
    cardTheme: const CardThemeData(color: Color.fromARGB(255, 41, 58, 51)),
    //listTileTheme: const ListTileThemeData(
    //  tileColor: Color.fromARGB(255, 12, 67, 218),
    //),
  );
}
