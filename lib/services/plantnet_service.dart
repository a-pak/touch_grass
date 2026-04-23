import 'package:dio/dio.dart';
import 'package:camera/camera.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:touch_grass/config/app_config.dart';

class PlantNetService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl, // See lib/config/app_config.dart if needed
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  Future<Map<String, dynamic>?> identifyPlant(XFile imageFile) async {
    try {
      FormData formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.name,
        ),
      });

      Response response = await _dio.post('detect', data: formData);
      // API-vastauksen printtaus
      // TODO: remove once app is done
      (() {
        final pretty = const JsonEncoder.withIndent(
          '  ',
        ).convert(response.data);
        debugPrint(pretty, wrapWidth: 1024);
      })();

      return response.data;
    } catch (e) {
      print('Virhe PlantNetService-palvelussa: $e');
      return null;
    }
  }
}
