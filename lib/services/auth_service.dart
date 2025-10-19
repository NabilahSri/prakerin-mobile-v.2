import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:mobile_prakerin/connection/connection.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
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

  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        'login',
        data: {
          'username': username,
          'password': password,
        },
      );

      // Check if login is successful and user level is student
      if (response.statusCode == 200) {
        final userLevel = response.data['user']['level'];
        if (userLevel.toString().toLowerCase() == 'siswa') {
          return {
            'success': true,
            'data': response.data,
          };
        } else {
          return {
            'success': false,
            'message': 'Akses ditolak. Hanya siswa yang dapat login.',
          };
        }
      }

      return {
        'success': false,
        'message': 'Login gagal',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data is Map
            ? e.response?.data['message']
            : 'Login gagal',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan. Silakan coba lagi.',
      };
    }
  }

  Future<Map<String, dynamic>> editPassword({
    required String newPassword,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    int? idUser = prefs.getInt('id_user');

    try {
      final response = await _dio.post(
        'user/editAkun/$idUser?token=$token',
        data: {
          'password': newPassword,
        },
      );
      if (response.statusCode == 200) {
        logout();
        return {
          'success': true,
          'data': response.data,
        };
      }
      return {
        'success': false,
        'message': 'Ubah kata sandi gagal',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data is Map
            ? e.response?.data['message']
            : 'Ubah kata sandi gagal',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan. Silakan coba lagi.',
      };
    }
  }

  Future<Map<String, dynamic>> editProfil({
    required String name,
    required String email,
    required String telepon,
    required String alamat,
    String? imagePath,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final idSiswa = prefs.getInt('id_siswa');

    try {
      FormData formData = FormData.fromMap({
        'name': name,
        'email': email,
        'telp': telepon,
        'alamat': alamat,
        'foto':
            imagePath != null ? await MultipartFile.fromFile(imagePath) : null,
      });

      final response = await _dio.post(
        'user/editProfil/$idSiswa?token=$token',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': response.data['message'],
        };
      } else {
        return {
          'success': false,
          'message': 'Gagal mengedit profil',
        };
      }
    } on DioException catch (e) {
      log('DioException: ${e.response}');
      return {
        'success': false,
        'message': e.response?.data is Map
            ? e.response?.data['message']
            : 'Gagal mengedit profil',
      };
    } catch (e) {
      log('Exception: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan. Silakan coba lagi.',
      };
    }
  }

  Future<Map<String, dynamic>> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    int? idUser = prefs.getInt('id_user');

    try {
      final response = await _dio.get(
        'logout/$idUser?token=$token',
      );

      if (response.statusCode == 200) {
        await prefs.remove('token');
        return {
          'success': true,
          'message': 'Logout berhasil',
        };
      } else {
        return {
          'success': false,
          'message': 'Logout gagal',
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data is Map
            ? e.response?.data['message']
            : 'Logout gagal',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan. Silakan coba lagi.',
      };
    }
  }
}
