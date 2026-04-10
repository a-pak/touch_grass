// TODO: API-koodi
import 'package:dio/dio.dart';

class PlantNetService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://127.0.0.1:8000/',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  Future<Map<String, dynamic>> identifyPlant(String imagePath) async {
    try {
      FormData formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(imagePath, filename: 'plant.jpg'),
      });

      Response response = await _dio.post('/detect', data: formData);
      return response.data;
    } catch (e) {
      print('Error identifying plant: $e');
      return {};
    }
  }
}