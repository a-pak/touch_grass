import 'package:flutter/material.dart';
import 'package:touch_grass/screens/camera_screen.dart';
import 'package:touch_grass/screens/challenge_screen.dart';
import 'package:touch_grass/screens/leaderboard_screen.dart';
import 'package:touch_grass/services/challenge_service.dart';

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

  @override
  void initState() {
    super.initState();
    _challengeService = DailyChallengeService();
  }

  int _selectedIndex = 0;

  List<Widget> get _tabs => [
    ChallengeScreen(service: _challengeService),
    const CameraScreen(),
    const LeaderboardScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(widget.title),
      // ),
      body: IndexedStack(index: _selectedIndex, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.task_alt), label: 'Challenge'),
          NavigationDestination(icon: Icon(Icons.camera_alt), label: 'Camera'),
          NavigationDestination(
            icon: Icon(Icons.leaderboard),
            label: 'Leaderboard',
          ),
        ],
      ),
    );
  }
}
