class DailyChallenges {
  final List<Challenge> challenges;
  final DateTime fetchedDate;

  const DailyChallenges({required this.challenges, required this.fetchedDate});

  bool get isStillValid {
    final now = DateTime.now();
    return fetchedDate.year == now.year &&
        fetchedDate.month == now.month &&
        fetchedDate.day == now.day;
  }

  @override
  String toString() {
    return 'DailyChallenges(fetchedDate: $fetchedDate, challenges: $challenges)';
  }
}

class Challenge {
  final String targetCommonName;
  final String targetScientificName;
  final String targetImageUrl;
  bool targetIsCompleted;

  Challenge({
    required this.targetCommonName,
    required this.targetScientificName,
    required this.targetImageUrl,
    required this.targetIsCompleted,
  });

  void setCompleted() {
    targetIsCompleted = true;
  }

  @override
  String toString() {
    return '\nChallenge(targetCommonName: $targetCommonName, targetScientificName: $targetScientificName, targetImageUrl: $targetImageUrl, targetIsCompleted: $targetIsCompleted)';
  }
}
