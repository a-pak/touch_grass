import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:touch_grass/screens/welcome_screen.dart';
import 'package:touch_grass/services/challenge_service.dart';
import 'package:touch_grass/theme/app_theme.dart';
import 'dart:developer' as developer;

void main() async {
  developer.log('', level: 0); // jotta tulee vähemmän logeja niin näkee omat tulostukset
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]); // App can only run in portrait mode
  await DailyChallengeService().ensureDailyChallengesOnStartup();
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
