import 'package:flutter/material.dart';

class ChallengeCard extends StatelessWidget {
  const ChallengeCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.isCompleted,
    required this.onOpenCamera,
  });

  final String title;
  final String imageUrl;
  final bool isCompleted;
  final VoidCallback onOpenCamera;

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
        final verticalPadding = (12 * scale).clamp(10, 14).toDouble();
        final titleSize = (22 * scale).clamp(17, 22).toDouble();
        final statusSize = (14 * scale).clamp(12, 14).toDouble();
        final cameraButtonSize = (52 * scale).clamp(46, 52).toDouble();
        final imageAspectRatio = 9 / 8;

        return Card(
          elevation: 10,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
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
              Container(
                color: const Color(0xFF1E2A2D),
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: titleSize,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                isCompleted
                                    ? 'Status: Completed'
                                    : 'Status: Not completed',
                                style: TextStyle(
                                  fontSize: statusSize,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                isCompleted ? Icons.check : Icons.close,
                                color: isCompleted ? Colors.green : Colors.red,
                                size: statusSize + 2,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Material(
                      color: const Color(0xFF32BEA6),
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: onOpenCamera,
                        child: SizedBox(
                          width: cameraButtonSize,
                          height: cameraButtonSize,
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
