import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:mobile_prakerin/connection/connection.dart';
import 'package:mobile_prakerin/models/home_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeService {
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

  Future<HomeModel?> getData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final idUser = prefs.getInt('id_user');

    try {
      final response = await _dio.get(
        'dashboard/$idUser?token=$token',
      );
      if (response.statusCode == 200) {
        return HomeModel.fromJson(response.data);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error getData: $e');
      return null;
    }
  }

//buatkan funsi cek kehadiran berdasarkan id siswa
  Future<Map<String, dynamic>?> checkKehadiran() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final idSiswa = prefs.getInt('id_siswa');

    try {
      final response = await _dio.get(
        'cek-kehadiran/$idSiswa?token=$token',
      );
      if (response.statusCode == 200) {
        return response.data ?? false;
      } else {
        throw Exception('Failed to check kehadiran');
      }
    } catch (e) {
      print('Error checkKehadiran: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> getDeviceInfo() async {
    final deviceInfo = await DeviceInfoPlugin().androidInfo;

    return {
      'device_model': deviceInfo.model,
      'android_version': 'Android ${deviceInfo.version.release}',
      'app_version': '2.0.0',
    };
  }
}
