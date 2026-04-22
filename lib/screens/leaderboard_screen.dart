import 'package:flutter/material.dart';
import 'package:touch_grass/controllers/home_tab_controller.dart';
import 'package:touch_grass/screens/welcome_screen.dart';
import 'package:touch_grass/services/login_service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key, required this.loginService});

  final LoginService loginService;

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  bool _isLoggingOut = false;
  late Future<List<LeaderboardRank>> _leaderboardFuture;
  String? _currentUsername;

  void _handleTabChanged() {
    if (!mounted) {
      return;
    }

    if (homeTabIndexNotifier.value == 2) {
      _refreshLeaderboard();
    }
  }

  @override
  void initState() {
    super.initState();
    _leaderboardFuture = widget.loginService.getLeaderboard();
    _loadCurrentUsername();
    homeTabIndexNotifier.addListener(_handleTabChanged);
  }

  @override
  void dispose() {
    homeTabIndexNotifier.removeListener(_handleTabChanged);
    super.dispose();
  }

  Future<void> _loadCurrentUsername() async {
    final String? savedUsername = await widget.loginService.getSavedUsername();
    if (!mounted) {
      return;
    }

    setState(() {
      _currentUsername = savedUsername;
    });
  }

  Future<void> _refreshLeaderboard() async {
    setState(() {
      _leaderboardFuture = widget.loginService.getLeaderboard();
    });
    await _leaderboardFuture;
  }

  Future<void> _onLogout() async {
    setState(() {
      _isLoggingOut = true;
    });

    await widget.loginService.logout();

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            const SizedBox(height: 8),
            const Text(
              'Leaderboard',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshLeaderboard,
                child: FutureBuilder<List<LeaderboardRank>>(
                  future: _leaderboardFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return ListView(
                        children: [
                          const SizedBox(height: 40),
                          const Center(
                            child: Text('Failed to load leaderboard.'),
                          ),
                          const SizedBox(height: 12),
                          Center(
                            child: TextButton(
                              onPressed: _refreshLeaderboard,
                              child: const Text('Try again'),
                            ),
                          ),
                        ],
                      );
                    }

                    final List<LeaderboardRank> rows = snapshot.data ??
                        <LeaderboardRank>[];

                    if (rows.isEmpty) {
                      return ListView(
                        children: const [
                          SizedBox(height: 40),
                          Center(child: Text('No players found yet.')),
                        ],
                      );
                    }

                    return ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: rows.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final LeaderboardRank row = rows[index];
                        final bool isCurrentUser =
                            _currentUsername != null &&
                            row.item.username == _currentUsername;

                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text('${row.rank}'),
                            ),
                            title: Text(
                              row.item.username,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: isCurrentUser
                                    ? Colors.amber.shade700
                                    : null,
                              ),
                            ),
                            subtitle: Text(
                              'Total plants found: ${row.item.totalRecognitions}',
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoggingOut ? null : _onLogout,
                icon: _isLoggingOut
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.logout),
                label: const Text('Logout'),
              ),
            ),
            const SizedBox(height: 16),
            const CircularProgressIndicator(),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
