import 'dart:async';

import 'package:flutter/material.dart';
import 'package:touch_grass/controllers/home_tab_controller.dart';
import 'package:touch_grass/models/challenge.dart';
import 'package:touch_grass/services/challenge_service.dart';
import 'package:touch_grass/services/login_service.dart';
import 'package:touch_grass/widgets/challenge_card.dart';

class ChallengeScreen extends StatefulWidget {
  final DailyChallengeService service;
  final LoginService loginService;

  const ChallengeScreen({
    super.key,
    required this.service,
    required this.loginService,
  });

  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> {
  late Duration _timeUntilReset;
  Future<DailyChallenges>? _dailyChallengesFuture;
  Future<UserStats>? _userStatsFuture;
  Timer? _countdownTimer;
  bool _isLoadingChallengesFromApi = false;

  void _refreshUserStats() {
    setState(() {
      _userStatsFuture = _loadUserStats();
    });
  }

  void _handleTabChanged() {
    if (!mounted) {
      return;
    }

    if (homeTabIndexNotifier.value == 0) {
      _refreshUserStats();
    }
  }

  void _handleChallengesUpdated() {
    if (!mounted) {
      return;
    }

    setState(() {
      _dailyChallengesFuture = _loadDailyChallenges();
      _userStatsFuture = _loadUserStats();
    });
  }

  @override
  void initState() {
    super.initState();
    _timeUntilReset = _calculateTimeUntilReset();
    _dailyChallengesFuture = _loadDailyChallenges();
    _userStatsFuture = _loadUserStats();
    widget.service.addListener(_handleChallengesUpdated);
    homeTabIndexNotifier.addListener(_handleTabChanged);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _timeUntilReset = _calculateTimeUntilReset();
      });
    });
  }

  Future<UserStats> _loadUserStats() {
    return widget.loginService.getMyStats();
  }

  @override
  void didUpdateWidget(covariant ChallengeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.service != widget.service) {
      oldWidget.service.removeListener(_handleChallengesUpdated);
      widget.service.addListener(_handleChallengesUpdated);
      _dailyChallengesFuture = _loadDailyChallenges();
      _userStatsFuture = _loadUserStats();
    }

    if (oldWidget.loginService != widget.loginService) {
      _userStatsFuture = _loadUserStats();
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    widget.service.removeListener(_handleChallengesUpdated);
    homeTabIndexNotifier.removeListener(_handleTabChanged);
    super.dispose();
  }

  Duration _calculateTimeUntilReset() {
    final DateTime now = DateTime.now();
    final DateTime nextMidnight = DateTime(now.year, now.month, now.day + 1);
    return nextMidnight.difference(now);
  }

  Future<DailyChallenges> _loadDailyChallenges() async {
    final String? username = await widget.loginService.getSavedUsername();
    if (username == null || username.trim().isEmpty) {
      throw StateError('User is not logged in');
    }

    if (mounted) {
      setState(() {
        _isLoadingChallengesFromApi = true;
      });
    }

    try {
      return await widget.service.loadChallenges(username: username);
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingChallengesFromApi = false;
        });
      }
    }
  }

  String _formatDuration(Duration duration) {
    final int hours = duration.inHours;
    final int minutes = duration.inMinutes.remainder(60);
    final int seconds = duration.inSeconds.remainder(60);

    String twoDigits(int value) => value.toString().padLeft(2, '0');

    return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  Future<void> _showHelpDialog() {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('How do daily challenges work?'),
          content: const Text(
            'Your task is to find the plants listed in daily challenges. '
            'Each day at midnight, you will get 3 new plants to find. '
            'Every day you successfully recognize at least one plant, your daily streak will increase. '
            'The leaderboard tracks the number of separate recognitions that players have.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _showHelpDialog,
                  icon: const Icon(Icons.help_outline, size: 28),
                  tooltip: 'Help',
                ),
                const Spacer(),
                FutureBuilder<UserStats>(
                  future: _userStatsFuture ??= _loadUserStats(),
                  builder: (context, snapshot) {
                    final UserStats? stats = snapshot.data;

                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _StatBadge(
                          asset: 'assets/fire.png',
                          label: '${stats?.dailyStreak ?? 0}',
                          color: const Color(0xFFFF521A),
                        ),
                        const SizedBox(width: 16),
                        _StatBadge(
                          asset: 'assets/rank.png',
                          label: '# ${stats?.leaderboardRank ?? '-'}',
                          color: const Color(0xFF85C6FF),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Expanded(
                  child: Text(
                    'Daily\nChallenges',
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Daily challenges\nreset in',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatDuration(_timeUntilReset),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: FutureBuilder<DailyChallenges>(
                  future: _dailyChallengesFuture ??= _loadDailyChallenges(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      if (_isLoadingChallengesFromApi) {
                        return const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 12),
                              Text('Loading challenges'),
                            ],
                          ),
                        );
                      }

                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return const Center(
                        child: Text('Failed to load daily challenges.'),
                      );
                    }

                    final List<Challenge> challenges =
                        snapshot.data?.challenges ?? <Challenge>[];

                    if (challenges.isEmpty) {
                      return const Center(
                        child: Text('No daily challenges available.'),
                      );
                    }

                    return ListView(
                      padding: const EdgeInsets.fromLTRB(48, 0, 48, 24),
                      children: [
                        for (int i = 0; i < challenges.length; i++) ...[
                          ChallengeCard(
                            title: challenges[i].targetCommonName,
                            imageUrl: challenges[i].targetImageUrl,
                            isCompleted: challenges[i].targetIsCompleted,
                            onOpenCamera: () {
                              homeTabIndexNotifier.value = 1;
                            },
                          ),
                          if (i < challenges.length - 1)
                            const SizedBox(height: 16),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  const _StatBadge({
    required this.asset,
    required this.label,
    required this.color,
  });

  final String asset;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(asset, width: 28, height: 28),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
