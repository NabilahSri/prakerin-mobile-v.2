import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../connection/connection.dart';
import '../models/kegiatan_model.dart';

class KegiatanService {
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

  Future<Map<String, dynamic>?> get5Data() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final idSiswa = prefs.getInt('id_siswa');
    try {
      final response = await _dio.get(
        'kegiatan/show_siswa/$idSiswa?token=$token',
      );
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error get5Data: $e');
      return null;
    }
  }

  //ambil data kegiatan berdasarkan id kehadiran
  Future<Map<String, dynamic>?> getKegiatanByIdPresensi(
      String idKehadiran) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    try {
      final response = await _dio.get(
        'kegiatan/show/$idKehadiran?token=$token',
      );
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error getKegiatanByIdPrensi: $e');
      return null;
    }
  }

  Future<List<KegiatanModel?>> getKegiatanByIdSiswa() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final idSiswa = prefs.getInt('id_siswa');
    try {
      final response = await _dio.get(
        'kegiatan/show_data/$idSiswa?token=$token',
      );
      if (response.statusCode == 200) {
        final List data = response.data['kegiatan'];
        return data.map((e) => KegiatanModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error getData: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> addActivity({
    required String judul,
    required String deskripsi,
    required String durasi,
    required String idKehadiran,
    required String imagePath,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final idSiswa = prefs.getInt('id_siswa');
    final idTahunAjaran = prefs.getInt('id_tahun_ajaran');

    try {
      final compressedImage = await FlutterImageCompress.compressAndGetFile(
        imagePath,
        '${imagePath}_compressed.jpg',
        quality: 60,
      );
      FormData formData = FormData.fromMap({
        'judul': judul,
        'deskripsi': deskripsi,
        'durasi': durasi,
        'id_kehadiran': idKehadiran,
        'id_siswa': idSiswa,
        'id_tahun_ajaran': idTahunAjaran,
        'foto': await MultipartFile.fromFile(compressedImage!.path),
      });

      final response = await _dio.post(
        'kegiatan/add?token=$token',
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
          'message': 'Gagal menambahkan kegiatan',
        };
      }
    } on DioException catch (e) {
      log('DioException: ${e.response}');
      return {
        'success': false,
        'message': e.response?.data is Map
            ? e.response?.data['message']
            : 'Gagal menambahkan kegiatan',
      };
    } catch (e) {
      log('Exception: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan. Silakan coba lagi.',
      };
    }
  }
}
