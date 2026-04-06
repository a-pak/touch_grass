import 'package:flutter/material.dart';
import 'package:touch_grass/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Touch Grass',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 65, 200, 65)),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 65, 200, 65),
          centerTitle: true,
        ),
        navigationBarTheme: const NavigationBarThemeData(
          backgroundColor: Color.fromARGB(255, 65, 200, 65),
          indicatorColor: Colors.white70,
        ),
      ),
      home: const HomeScreen(title: 'Touch Grass'),
    );
  }
}
