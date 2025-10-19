import 'package:dio/dio.dart';
import 'package:mobile_prakerin/connection/connection.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: Connection.BASE_URL, // Ganti dengan endpoint API
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  Future<Map<String, dynamic>> setLocation({
    required double latitude,
    required double longitude,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final idUser = prefs.getInt('id_user');

    try {
      final response = await _dio.post(
        'user/aturLokasi/$idUser?token=$token',
        data: {
          'lat': latitude,
          'long': longitude,
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': response.data['message'],
        };
      } else {
        return {
          'success': false,
          'message': 'Gagal mengatur lokasi',
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data is Map
            ? e.response?.data['message']
            : 'Gagal mengatur lokasi',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan tak terduga',
      };
    }
  }
}
