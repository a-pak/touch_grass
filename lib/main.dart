import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:touch_grass/screens/welcome_screen.dart';
import 'package:touch_grass/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]); // App can only run in portrait mode
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Touch Grass',
      theme: AppTheme.theme,
      home: const WelcomeScreen(),
    );
  }
}
