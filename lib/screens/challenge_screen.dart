// TODO: ListView:n tilalle saattaa löytyä jokin muu kontti jolla skrollaus on sujuvampaa ks. https://stackoverflow.com/questions/53405399/simple-flutter-list-view-choppy-scrolling
// TODO: korttia painamalla voisi aueta jokin vihje sijainnista, esim. pop-up ikkunaan tai verkkoselaimeen
// TODO: hae haasteet sharedpreferencestä
// TODO: näytä onko haaste suoritettu
// TODO: näytä aika, millon haasteet uusiutuu

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
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _StatBadge(asset: 'assets/fire.png', label: '1', color: const Color(0xFFFF521A)),
                const SizedBox(width: 16),
                _StatBadge(asset: 'assets/rank.png', label: '# 1', color: const Color(0xFF85C6FF)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
            child: Text(
              'Daily\nChallenge',
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(48, 0, 48, 24),
                  children: const [
                    _ChallengeCard(
                      title: 'Random challenge 1',
                      imageUrl: 'https://picsum.photos/id/152/800',
                    ),
                    SizedBox(height: 16),
                    _ChallengeCard(
                      title: 'Random challenge 2',
                      imageUrl: 'https://picsum.photos/id/28/800',
                    ),
                    SizedBox(height: 16),
                    _ChallengeCard(
                      title: 'Random challenge 3',
                      imageUrl: 'https://picsum.photos/id/306/800',
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

class _StatBadge extends StatelessWidget {
  const _StatBadge({required this.asset, required this.label, required this.color});

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
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  const _ChallengeCard({required this.title, required this.imageUrl});

  final String title;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Nämä määrää kortin koon ja mittasuhteet
        // clamp-funktio asettaa ala- ja ylärajat, jotta eri näyttökoot tulee huomioitua
        // Arvot käytännössä trial-and-error tyylillä
        final width = constraints.maxWidth;
        final scale = (width / 450).clamp(0.72, 1).toDouble();
        final horizontalPadding = (16 * scale).clamp(12, 16).toDouble();
        final verticalPadding = (32 * scale).clamp(10, 32).toDouble();
        final titleSize = (26 * scale).clamp(18, 26).toDouble();
        final imageAspectRatio = 9 / 8;

        return Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: imageAspectRatio,
                child: Image.network(
                  imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: titleSize, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
