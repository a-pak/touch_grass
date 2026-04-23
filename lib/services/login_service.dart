import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LeaderboardItem {
  LeaderboardItem({
    required this.username,
    required this.dailyStreak,
    required this.totalRecognitions,
    required this.lastRecognitionDate,
  });

  final String username;
  final int dailyStreak;
  final int totalRecognitions;
  final String? lastRecognitionDate;

  factory LeaderboardItem.fromJson(Map<String, dynamic> json) {
    return LeaderboardItem(
      username: json['username'] as String? ?? '',
      dailyStreak: (json['daily_streak'] as num?)?.toInt() ?? 0,
      totalRecognitions: (json['total_recognitions'] as num?)?.toInt() ?? 0,
      lastRecognitionDate: json['last_recognition_date'] as String?,
    );
  }
}

class LeaderboardRank {
  LeaderboardRank({required this.rank, required this.item});

  final int rank;
  final LeaderboardItem item;
}

class UserStats {
  UserStats({
    required this.username,
    required this.dailyStreak,
    required this.totalRecognitions,
    required this.leaderboardRank,
  });

  final String username;
  final int dailyStreak;
  final int totalRecognitions;
  final int leaderboardRank;

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      username: json['username'] as String? ?? '',
      dailyStreak: (json['daily_streak'] as num?)?.toInt() ?? 0,
      totalRecognitions: (json['total_recognitions'] as num?)?.toInt() ?? 0,
      leaderboardRank: (json['leaderboard_rank'] as num?)?.toInt() ?? 0,
    );
  }
}

class AuthResponse {
  AuthResponse({
    required this.accessToken,
    required this.username,
    required this.dailyStreak,
    required this.totalRecognitions,
  });

  final String accessToken;
  final String username;
  final int dailyStreak;
  final int totalRecognitions;

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['access_token'] as String,
      username: json['username'] as String,
      dailyStreak: (json['daily_streak'] as num?)?.toInt() ?? 0,
      totalRecognitions: (json['total_recognitions'] as num?)?.toInt() ?? 0,
    );
  }
}

class LoginService {
  LoginService()
    : _dio = Dio(
        BaseOptions(
          baseUrl: 'http://10.0.2.2:8000/',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

  static const String _accessTokenKey = 'auth.access_token';
  static const String _usernameKey = 'auth.username';

  final Dio _dio;

  Future<AuthResponse> register({
    required String username,
    required String password,
  }) async {
    final Response<dynamic> response = await _dio.post(
      'register',
      data: {'username': username, 'password': password},
    );

    final AuthResponse auth = AuthResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
    return auth;
  }

  Future<AuthResponse> login({
    required String username,
    required String password,
  }) async {
    final Response<dynamic> response = await _dio.post(
      'login',
      data: {'username': username, 'password': password},
    );

    final AuthResponse auth = AuthResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
    await _saveSession(token: auth.accessToken, username: auth.username);
    return auth;
  }

  Future<bool> incrementRecognitions({int amount = 1}) async {
    final String? token = await _getAccessToken();
    if (token == null || token.isEmpty) {
      return false;
    }

    await _dio.post(
      'recognitions/increment',
      data: {'amount': amount},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return true;
  }

  Future<List<LeaderboardRank>> getLeaderboard({
    int limit = 50,
    String sortBy = 'total_recognitions',
  }) async {
    final Response<dynamic> response = await _dio.get(
      'leaderboard',
      queryParameters: {'limit': limit, 'sort_by': sortBy},
    );

    final Map<String, dynamic> data = response.data as Map<String, dynamic>;
    final List<dynamic> rawItems = data['items'] as List<dynamic>? ??
        <dynamic>[];

    return rawItems
        .asMap()
        .entries
        .map((entry) => LeaderboardRank(
              rank: entry.key + 1,
              item: LeaderboardItem.fromJson(
                entry.value as Map<String, dynamic>,
              ),
            ))
        .toList();
  }

  Future<UserStats> getMyStats() async {
    final String? token = await _getAccessToken();
    if (token == null || token.isEmpty) {
      throw StateError('User is not logged in');
    }

    final Response<dynamic> response = await _dio.get(
      'me/stats',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return UserStats.fromJson(response.data as Map<String, dynamic>);
  }

  Future<bool> isLoggedIn() async {
    final String? token = await _getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> logout() async {
    final SharedPreferencesWithCache prefs = await _prefs();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_usernameKey);
  }

  Future<String?> getSavedUsername() async {
    final SharedPreferencesWithCache prefs = await _prefs();
    return prefs.getString(_usernameKey);
  }

  Future<void> _saveSession({
    required String token,
    required String username,
  }) async {
    final SharedPreferencesWithCache prefs = await _prefs();
    await prefs.setString(_accessTokenKey, token);
    await prefs.setString(_usernameKey, username);
  }

  Future<String?> _getAccessToken() async {
    final SharedPreferencesWithCache prefs = await _prefs();
    return prefs.getString(_accessTokenKey);
  }

  Future<SharedPreferencesWithCache> _prefs() {
    return SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(),
    );
  }
}
