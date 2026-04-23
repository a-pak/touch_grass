import 'package:flutter/material.dart';
import 'package:touch_grass/controllers/home_tab_controller.dart';
import 'package:touch_grass/screens/camera_screen.dart';
import 'package:touch_grass/screens/challenge_screen.dart';
import 'package:touch_grass/screens/leaderboard_screen.dart';
import 'package:touch_grass/services/challenge_service.dart';
import 'package:touch_grass/services/login_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Luodaan _challengeService täällä, jotta voidaan löytää päivän haasteet muissa näytöissä
  // Joskus hot reload voi aiheuttaa ongelmia näiden late-muuttujien kanssa, hot restart yleensä korjaa
  late final DailyChallengeService _challengeService;
  late final LoginService _loginService;

  @override
  void initState() {
    super.initState();
    _challengeService = DailyChallengeService();
    _loginService = LoginService();
  }

  List<Widget> get _tabs => [
    ChallengeScreen(service: _challengeService, loginService: _loginService),
    CameraScreen(service: _challengeService, loginService: _loginService),
    LeaderboardScreen(loginService: _loginService),
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: homeTabIndexNotifier,
      builder: (context, selectedIndex, _) {
        return Scaffold(
          // appBar: AppBar(
          //   title: Text(widget.title),
          // ),
          body: IndexedStack(index: selectedIndex, children: _tabs),
          bottomNavigationBar: NavigationBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) {
              homeTabIndexNotifier.value = index;
            },
            destinations: [
              NavigationDestination(
                icon: Image.asset('assets/leaf.png', width: 24, height: 24),
                label: 'Challenges',
              ),
              NavigationDestination(
                icon: Image.asset('assets/camera.png', width: 24, height: 24),
                label: 'Camera',
              ),
              NavigationDestination(
                icon: Image.asset('assets/leaderboard.png', width: 24, height: 24),
                label: 'Leaderboard',
              ),
            ],
          ),
        );
      },
    );
  }
}
