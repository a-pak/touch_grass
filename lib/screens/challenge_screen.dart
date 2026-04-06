import 'package:flutter/material.dart';

class ChallengeScreen extends StatelessWidget {
  const ChallengeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    const challengeBlock = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Todays daily challenge is:',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        Text(
          'Daily challenge placeholder',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ],
    );

    const playerBlock = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Player: User',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8),
        Text(
          'Current streak: 0 days',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      ],
    );

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: isLandscape
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Flexible(child: challengeBlock),
                  SizedBox(width: 144),
                  Flexible(child: playerBlock),
                ],
              )
            : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  challengeBlock,
                  SizedBox(height: 168),
                  playerBlock,
                ],
              ),
      ),
    );
  }
}
