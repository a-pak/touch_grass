import 'package:dio/dio.dart';

// HUOM: Jos testaat fyysisellä puhelimella, vaihda 127.0.0.1 tilalle
// tietokoneesi lähiverkon IP-osoite (esim. 192.168.1.X) ja käynnistä
// backend komennolla: uvicorn main:app --host 0.0.0.0 --reload
class TrefleService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://10.0.2.2:8000/',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  Future<Map<String, dynamic>?> fetchFinlandPlantsPage({int page = 1}) async {
    try {
      final Response response = await _dio.get(
        'plants',
        queryParameters: {'page': page},
      );

      return response.data;
    } catch (e) {
      print('Virhe ChallengeService-palvelussa: $e');
      return null;
    }
  }
}