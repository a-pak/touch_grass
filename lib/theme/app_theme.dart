import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get theme => ThemeData(
    brightness: Brightness.dark,
    // appBarTheme: const AppBarTheme(
    //   backgroundColor: Colors.transparent,
    //   centerTitle: true,
    // ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: Color.fromARGB(255, 41, 58, 51),
      indicatorColor: Color.fromARGB(255, 101, 104, 105),
    ),
    cardTheme: const CardThemeData(
      color: Color.fromARGB(255, 41, 58, 51),
    ),
    //listTileTheme: const ListTileThemeData(
    //  tileColor: Color.fromARGB(255, 12, 67, 218),
    //),
  );
}