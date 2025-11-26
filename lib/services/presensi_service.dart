import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:mobile_prakerin/connection/connection.dart';
import 'package:mobile_prakerin/models/presensi_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PresensiService {
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

  // Fungsi get 5 kehadiran
  Future<List<PresensiModel?>> get5DataPresensi() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final idSiswa = prefs.getInt('id_siswa');
    try {
      final response = await _dio.get(
        'kehadiran/show/$idSiswa?token=$token',
      );
      if (response.statusCode == 200) {
        final List data = response.data['kehadiran'];
        return data.map((e) => PresensiModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error getData: $e');
      return [];
    }
  }

  Future<List<PresensiModel?>> getDataPresensi() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final idSiswa = prefs.getInt('id_siswa');
    try {
      final response = await _dio.get(
        'kehadiran/show_siswa/$idSiswa?token=$token',
      );
      if (response.statusCode == 200) {
        final List data = response.data['kehadiran'];
        return data.map((e) => PresensiModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error getData: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> presensiMasuk({
    required String mode,
    required String? tokenMasuk,
  }) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return {
          'success': false,
          'message':
              'Izin lokasi ditolak, aktifkan perizinan lokasi pada setting!',
        };
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return {
        'success': false,
        'message':
            'Izin lokasi ditolak secara permanen, aktifkan perizinan lokasi pada setting!',
      };
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    String lat = position.latitude.toString();
    String long = position.longitude.toString();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final idSiswa = prefs.getInt('id_siswa');
    final idUser = prefs.getInt('id_user');
    final idTahunAjaran = prefs.getInt('id_tahun_ajaran');

    try {
      final response = await _dio.post(
        'kehadiran/masuk?token=$token',
        data: {
          'lat': lat,
          'long': long,
          'tanggal': DateFormat('yyyy-MM-dd').format(DateTime.now()),
          'jam_masuk': DateFormat('HH:mm:ss').format(DateTime.now()),
          'status': 'hadir',
          'id_siswa': idSiswa,
          'id_user': idUser,
          'id_tahun_ajaran': idTahunAjaran,
          'mode': mode,
          'token_masuk': tokenMasuk,
        },
      );

      if (response.statusCode == 201) {
        log('Response Data: ${response.data}');
        return {
          'success': true,
          'message': response.data['message'],
        };
      } else {
        // log('Response Data: ${response.data}');
        return {
          'success': false,
          'message': 'Presensi masuk gagal',
        };
      }
    } on DioException catch (e) {
      log('DioException: ${e.response}');
      return {
        'success': false,
        'message': e.response?.data is Map
            ? e.response?.data['message']
            : 'Presensi masuk gagal',
      };
    } catch (e) {
      log('Exception: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan. Silakan coba lagi.',
      };
    }
  }

  Future<Map<String, dynamic>> presensiPulang({
    required String mode,
    required String? tokenPulang,
    required String status,
  }) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return {
          'success': false,
          'message':
              'Izin lokasi ditolak, aktifkan perizinan lokasi pada setting!',
        };
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return {
        'success': false,
        'message':
            'Izin lokasi ditolak secara permanen, aktifkan perizinan lokasi pada setting!',
      };
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    String lat = position.latitude.toString();
    String long = position.longitude.toString();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final idUser = prefs.getInt('id_user');

    try {
      final response = await _dio.post(
        'kehadiran/pulang?token=$token',
        data: {
          'lat': lat,
          'long': long,
          'tanggal': DateFormat('yyyy-MM-dd').format(DateTime.now()),
          'jam_pulang': DateFormat('HH:mm:ss').format(DateTime.now()),
          'status': status,
          'id_user': idUser,
          'mode': mode,
          'token_keluar': tokenPulang,
        },
      );

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': response.data['message'],
        };
      } else {
        return {
          'success': false,
          'message': 'Presensi pulang gagal',
        };
      }
    } on DioException catch (e) {
      log('DioException: ${e.response}');
      return {
        'success': false,
        'message': e.response?.data is Map
            ? e.response?.data['message']
            : 'Presensi pulang gagal',
      };
    } catch (e) {
      log('Exception: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan. Silakan coba lagi.',
      };
    }
  }

  Future<Map<String, dynamic>> addFormulir({
    required String tanggal,
    required String? catatan,
    required String status,
    required String imagePath,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final idSiswa = prefs.getInt('id_siswa');
    final idUser = prefs.getInt('id_user');
    final idTahunAjaran = prefs.getInt('id_tahun_ajaran');

    try {
      final compressedImage = await FlutterImageCompress.compressAndGetFile(
        imagePath,
        '${imagePath}_compressed.jpg',
        quality: 60,
      );
      FormData formData = FormData.fromMap({
        'tanggal': tanggal,
        'status': status,
        'catatan': catatan,
        'id_siswa': idSiswa,
        'id_user': idUser,
        'id_tahun_ajaran': idTahunAjaran,
        'bukti': await MultipartFile.fromFile(compressedImage!.path),
      });

      final response = await _dio.post(
        'formulir/add?token=$token',
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
          'message': 'Pengiriman formulir gagal',
        };
      }
    } on DioException catch (e) {
      log('DioException: ${e.response}');
      return {
        'success': false,
        'message': e.response?.data is Map
            ? e.response?.data['message']
            : 'Pengiriman formulir gagal',
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
