import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:touch_grass/models/challenge.dart';
import 'package:touch_grass/services/trefle_service.dart' as api;

class DailyChallengeService extends ChangeNotifier {
  DailyChallengeService({api.TrefleService? challengeFetchService})
    : _challengeFetchService = challengeFetchService ?? api.TrefleService();

  static const String _storageKeyPrefix = 'daily_challenges';
  static const int _dailyChallengeCount = 3;
  // Nämä sivut on toistaiseksi kovakoodattuna, mutta pitää muuttaa myöhemmin jos lisätään
  // käyttäjälle mahdollisuus valita oma maansa tai alueensa
  static const int _finlandFirstPage = 1;
  static const int _finlandLastPage = 135;

  final api.TrefleService _challengeFetchService;
  final Random _random = Random();

  Future<DailyChallenges> loadChallenges({
    required String username,
  }) async {
    final DailyChallenges? stored = await getStoredDailyChallenges(
      username: username,
    );
    if (stored != null && stored.isStillValid) {
      print(
        'Using stored daily challenges:\n$stored',
      ); // TODO: remove once app is done
      return stored;
    }

    final DailyChallenges generated = await _createDailyChallenges(
      requiredChallengeCount: _dailyChallengeCount,
    );
    await _storeDailyChallenges(generated, username: username);
    print(
      'Generated daily challenges:\n$generated',
    ); // TODO: remove once app is done
    return generated;
  }

  Future<DailyChallenges?> getStoredDailyChallenges({
    required String username,
  }) async {
    final SharedPreferencesWithCache prefs =
        await SharedPreferencesWithCache.create(
          cacheOptions: const SharedPreferencesWithCacheOptions(),
        );
    final String storageKey = _storageKeyForUsername(username);
    final String? rawJson = prefs.getString(storageKey);
    if (rawJson == null || rawJson.isEmpty) {
      return null;
    }

    final Map<String, dynamic> jsonMap =
        jsonDecode(rawJson) as Map<String, dynamic>;
    return _dailyChallengesFromMap(jsonMap);
  }

  Future<({Challenge? challenge, bool wasAlreadyCompleted})>
  completeChallengeForScientificName({
    required String username,
    required String identifiedScientificNameWithoutAuthor,
  }) async {
    final DailyChallenges? dailyChallenges = await getStoredDailyChallenges(
      username: username,
    );
    if (dailyChallenges == null || !dailyChallenges.isStillValid) {
      return (challenge: null, wasAlreadyCompleted: false);
    }

    final String normalizedIdentified = identifiedScientificNameWithoutAuthor
        .trim()
        .toLowerCase();

    for (final Challenge challenge in dailyChallenges.challenges) {
      print(
        "Checking if '${challenge.targetScientificName}' matches '$normalizedIdentified'",
      ); // TODO: remove once app is done
      if (challenge.targetScientificName.trim().toLowerCase() ==
          normalizedIdentified) {
        final bool wasCompleted = challenge.targetIsCompleted;
        if (!wasCompleted) {
          challenge.setCompleted();
          await _storeDailyChallenges(dailyChallenges, username: username);
          notifyListeners();
        }
        return (challenge: challenge, wasAlreadyCompleted: wasCompleted);
      }
    }

    return (challenge: null, wasAlreadyCompleted: false);
  }

  Future<DailyChallenges> _createDailyChallenges({
    required int requiredChallengeCount,
  }) async {
    final List<Challenge> generatedChallenges = [];

    for (int i = 0; i < requiredChallengeCount; i++) {
      final Challenge challenge = await _generateRandomChallengeFromFinland();
      generatedChallenges.add(challenge);
    }

    return DailyChallenges(
      challenges: generatedChallenges,
      fetchedDate: DateTime.now(),
    );
  }

  Future<Challenge> _generateRandomChallengeFromFinland() async {
    const int maxAttempts = 200;

    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      final int randomPage =
          _finlandFirstPage + _random.nextInt(_finlandLastPage);

      final Map<String, dynamic>? response = await _challengeFetchService
          .fetchFinlandPlantsPage(page: randomPage);
      if (response == null) {
        continue;
      }

      final List<dynamic> data = (response['data'] as List<dynamic>?) ?? [];
      final List<Map<String, dynamic>> plantsWithImage = data
          .whereType<Map<String, dynamic>>()
          .where(
            (plant) => ['image_url', 'common_name', 'scientific_name'].every(
              (key) => (plant[key] as String?)?.trim().isNotEmpty == true,
            ),
          )
          .toList();

      if (plantsWithImage.isEmpty) {
        continue;
      }

      final int randomPlantIndex = _random.nextInt(plantsWithImage.length);
      final Map<String, dynamic> selectedPlant =
          plantsWithImage[randomPlantIndex];

      final String commonName =
          (selectedPlant['common_name'] as String?)?.trim().isNotEmpty == true
          ? selectedPlant['common_name'] as String
          : 'Unknown plant';
      final String scientificName =
          (selectedPlant['scientific_name'] as String?)?.trim().isNotEmpty ==
              true
          ? selectedPlant['scientific_name'] as String
          : 'Unknown scientific name';
      final String imageUrl = selectedPlant['image_url'] as String;

      return Challenge(
        targetCommonName: commonName,
        targetScientificName: scientificName,
        targetImageUrl: imageUrl,
        targetIsCompleted: false,
      );
    }

    throw StateError(
      'Could not generate a challenge with an image URL from Finland pages after $maxAttempts attempts.',
    );
  }

  Future<void> _storeDailyChallenges(
    DailyChallenges dailyChallenges, {
    required String username,
  }) async {
    final SharedPreferencesWithCache prefs =
        await SharedPreferencesWithCache.create(
          cacheOptions: const SharedPreferencesWithCacheOptions(),
        );
    final String storageKey = _storageKeyForUsername(username);
    await prefs.setString(
      storageKey,
      jsonEncode(_dailyChallengesToMap(dailyChallenges)),
    );
  }

  String _storageKeyForUsername(String username) {
    final String normalized = username.trim().toLowerCase();
    return '$_storageKeyPrefix.$normalized';
  }

  Map<String, dynamic> _dailyChallengesToMap(DailyChallenges dailyChallenges) {
    return <String, dynamic>{
      'fetchedDate': dailyChallenges.fetchedDate.toIso8601String(),
      'challenges': dailyChallenges.challenges
          .map(
            (Challenge challenge) => <String, dynamic>{
              'targetCommonName': challenge.targetCommonName,
              'targetScientificName': challenge.targetScientificName,
              'targetImageUrl': challenge.targetImageUrl,
              'targetIsCompleted': challenge.targetIsCompleted,
            },
          )
          .toList(),
    };
  }

  DailyChallenges _dailyChallengesFromMap(Map<String, dynamic> map) {
    final String fetchedDate = map['fetchedDate'] as String;
    final List<dynamic> rawChallenges =
        (map['challenges'] as List<dynamic>?) ?? <dynamic>[];

    return DailyChallenges(
      fetchedDate: DateTime.parse(fetchedDate),
      challenges: rawChallenges
          .whereType<Map<String, dynamic>>()
          .map(
            (Map<String, dynamic> item) => Challenge(
              targetCommonName: item['targetCommonName'] as String,
              targetScientificName: item['targetScientificName'] as String,
              targetImageUrl: item['targetImageUrl'] as String,
              targetIsCompleted: item['targetIsCompleted'] as bool? ?? false,
            ),
          )
          .toList(),
    );
  }
}
