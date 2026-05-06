import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class ApiService {
  late Dio dio;
  
  // Note: Gunakan 10.0.2.2 jika menggunakan Android Emulator.
  // Gunakan 127.0.0.1 atau localhost jika build ke Web / Windows.
  final String baseUrl = 'http://127.0.0.1:8000/api';

  ApiService() {
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      headers: {
        'Accept': 'application/json',
      },
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        
        // Handling Auth Token
        final token = prefs.getString('auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        // Handling Device ID / Guest Session
        String? deviceId = prefs.getString('device_id');
        if (deviceId == null) {
          deviceId = const Uuid().v4(); // Generate unique device id
          await prefs.setString('device_id', deviceId);
        }
        options.headers['X-Device-ID'] = deviceId;

        return handler.next(options);
      },
    ));
  }
}
