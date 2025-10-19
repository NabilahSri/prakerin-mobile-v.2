import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_prakerin/models/home_model.dart';
import 'package:mobile_prakerin/services/home_service.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportService {
  static const String adminWhatsApp =
      '6285861783384'; // Ganti dengan nomor admin
  static const String adminEmail =
      'nabilahmulyani00@gmail.com'; // Ganti dengan email admin

  final HomeService _homeService = HomeService();

  Future<void> openWhatsAppSupport(BuildContext context) async {
    try {
      final user = await _homeService.getData();
      final deviceInfo = await _homeService.getDeviceInfo();

      final message = _generateWhatsAppMessage(user!, deviceInfo);
      final encodedMessage = Uri.encodeComponent(message);

      final url = "https://wa.me/$adminWhatsApp?text=$encodedMessage";

      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        _showErrorDialog(context, 'WhatsApp tidak terinstall di device Anda');
      }
    } catch (e) {
      _showErrorDialog(context, 'Terjadi error: $e');
    }
  }

  String _generateWhatsAppMessage(
      HomeModel user, Map<String, dynamic> deviceInfo) {
    return """
*🛠️ LAPORAN MASALAH APLIKASI PRAKERIN*

*DATA SISWA:*
• Nama: ${user.name}
• Kelas: ${user.kelas}

*INFORMASI DEVICE:*
• Device: ${deviceInfo['device_model']}
• OS: ${deviceInfo['android_version']}
• App Version: ${deviceInfo['app_version']}

*DESKRIPSI MASALAH:*
[SILAKAN DESKRIPSIKAN MASALAH YANG ANDA ALAMI DI SINI]

*DETAIL TAMBAHAN:*
• Kapan terjadi: [JELASKAN WAKTU KEJADIAN]
• Apa yang dilakukan: [JELASKAN AKTIVITAS SAAT ERROR]
• Sudah coba apa: [JELASKAN UPAYA PERBAIKAN]

*SCREENSHOT:*
[BISA DIKIRIM LANGSUNG DI CHAT INI]

*WAKTU LAPORAN:*
${DateFormat('dd/MM/yyyy HH:mm', 'id_ID').format(DateTime.now())}

_Mohon bantuan dan solusinya, terima kasih 🙏_
""";
  }

  Future<void> openEmailSupport(BuildContext context) async {
    try {
      final user = await _homeService.getData();
      final deviceInfo = await _homeService.getDeviceInfo();

      final subject = 'Laporan Masalah Aplikasi Prakerin - ${user!.name}';
      final body = _generateEmailBody(user, deviceInfo);

      final url =
          "mailto:$adminEmail?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}";

      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        _showErrorDialog(context, 'Tidak ada aplikasi email yang terinstall');
      }
    } catch (e) {
      _showErrorDialog(context, 'Terjadi error: $e');
    }
  }

  String _generateEmailBody(HomeModel user, Map<String, dynamic> deviceInfo) {
    return """
LAPORAN MASALAH APLIKASI PRAKERIN

DATA SISWA:
- Nama: ${user.name}
- Kelas: ${user.kelas}

INFORMASI DEVICE:
- Device: ${deviceInfo['device_model']}
- OS: ${deviceInfo['android_version']}
- App Version: ${deviceInfo['app_version']}
- Package: ${deviceInfo['package_name']}

DESKRIPSI MASALAH:
[SILAKAN JELASKAN MASALAH YANG ANDA ALAMI]

DETAIL KEJADIAN:
- Waktu Kejadian: 
- Aktivitas Saat Error:
- Upaya Perbaikan yang Sudah Dicoba:

SCREENSHOT:
[Bisa dilampirkan dalam email ini]

WAKTU LAPORAN: ${DateFormat('dd/MM/yyyy HH:mm', 'id_ID').format(DateTime.now())}

Mohon bantuan dan solusinya.

Salam,
${user.name}
""";
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
