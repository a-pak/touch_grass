import 'package:flutter/material.dart';

class ChallengeScreen extends StatelessWidget {
  const ChallengeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(48),
            child: Text(
              'Daily Challenge',
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(48, 0, 48, 24),
                  children: const [
                    _ChallengeCard(
                      title: 'Random challenge 1',
                      imageUrl: 'https://picsum.photos/id/18/250',
                    ),
                    SizedBox(height: 16),
                    _ChallengeCard(
                      title: 'Random challenge 2',
                      imageUrl: 'https://picsum.photos/id/28/250',
                    ),
                    SizedBox(height: 16),
                    _ChallengeCard(
                      title: 'Random challenge 3',
                      imageUrl: 'https://picsum.photos/id/306/250',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  const _ChallengeCard({required this.title, required this.imageUrl});

  final String title;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 5 / 4,
            child: Image.network(
              imageUrl,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
