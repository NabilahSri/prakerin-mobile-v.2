import 'package:flutter/material.dart';
import 'package:mobile_prakerin/pages/activities/activity_add_page.dart';
import 'package:mobile_prakerin/pages/authentication/login_page.dart';
import 'package:mobile_prakerin/pages/authentication/password_page.dart';
import 'package:mobile_prakerin/pages/home/home_page.dart';
import 'package:mobile_prakerin/pages/presensi/presensi_activity_page.dart';
import 'package:mobile_prakerin/pages/presensi/presensi_formulir_page.dart';
import 'package:mobile_prakerin/pages/presensi/presensi_history_page.dart';
import 'package:mobile_prakerin/pages/settings/about_aplication_page.dart';
import 'package:mobile_prakerin/pages/settings/edit_password_page.dart';
import 'package:mobile_prakerin/pages/settings/information_page.dart';
import 'package:mobile_prakerin/pages/settings/profile_page.dart';
import 'package:mobile_prakerin/pages/settings/set_location_page.dart';
import 'package:mobile_prakerin/splash_screen.dart';

import '../pages/settings/panduan.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/': (context) => const SplashScreen(),
    '/login': (context) => const LoginPage(),
    '/password': (context) => const PasswordPage(),
    '/home': (context) => const HomePage(initialIndex: 0),
    '/presensi': (context) => const HomePage(initialIndex: 1),
    '/settings': (context) => const HomePage(initialIndex: 3),
    '/presensi_history': (context) => const PresensiHistoryPage(),
    '/presensi_activity': (context) {
      final id = ModalRoute.of(context)!.settings.arguments as String;
      return PresensiActivityPage(id_presensi: id);
    },
    '/activity_add': (context) {
      final id = ModalRoute.of(context)!.settings.arguments as String;
      return ActivityAddPage(id_presensi: id);
    },
    '/presensi_formulir': (context) => const PresensiFormulirPage(),
    '/profile': (context) => const ProfilePage(),
    '/edit_password': (context) => const EditPasswordPage(),
    '/information': (context) => const InformationPage(),
    '/about_aplication': (context) => const AboutAplicationPage(),
    '/set_location': (context) => const SetLocationPage(),
    '/panduan': (context) => const Panduan(),
  };
}
