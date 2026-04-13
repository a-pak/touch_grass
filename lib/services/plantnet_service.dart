// TODO: API-koodi
import 'package:dio/dio.dart';
import 'package:camera/camera.dart';


// HUOM: Jos testaat fyysisellä puhelimella, vaihda 127.0.0.1 tilalle 
// tietokoneesi lähiverkon IP-osoite (esim. 192.168.1.X) ja käynnistä 
// backend komennolla: uvicorn main:app --host 0.0.0.0 --reload
class PlantNetService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://127.0.0.1:8000/',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

Future<Map<String, dynamic>?> identifyPlant(XFile imageFile) async {
    try {
      FormData formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path, 
          filename: imageFile.name,
        ),
      });

      Response response = await _dio.post('detect', data: formData);
      return response.data;
    } catch (e) {
      print('Virhe PlantNetService-palvelussa: $e');
      return null;
    }
  }
}