import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:touch_grass/screens/home_screen.dart';
import 'package:touch_grass/screens/welcome_screen.dart';
import 'package:touch_grass/services/login_service.dart';
import 'package:touch_grass/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]); // App can only run in portrait mode
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final LoginService _loginService = LoginService();
  late final Future<bool> _isLoggedInFuture;

  @override
  void initState() {
    super.initState();
    _isLoggedInFuture = _loginService.isLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Touch Grass',
      theme: AppTheme.theme,
      home: FutureBuilder<bool>(
        future: _isLoggedInFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.data == true) {
            return const HomeScreen(title: 'Touch Grass');
          }

          return const WelcomeScreen();
        },
      ),
    );
  }
}
