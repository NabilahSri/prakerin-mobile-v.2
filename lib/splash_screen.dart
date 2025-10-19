import 'package:flutter/material.dart';
import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile_prakerin/core/constants/colors.dart';
import 'package:mobile_prakerin/pages/authentication/login_page.dart';
import 'package:mobile_prakerin/pages/home/home_page.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  // Cek token dari SharedPreferences (opsional login otomatis)
  Future<Widget> _getNextScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null && token.isNotEmpty) {
      return const HomePage();
    }
    return const LoginPage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<Widget>(
          future: _getNextScreen(),
          builder: (context, snapshot) {
            // Tampilkan splash animasi
            return FlutterSplashScreen.scale(
              gradient: const LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: AppColors.gradient,
              ),
              childWidget: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/logo.png",
                    height: 120,
                  ),
                  const SizedBox(height: 16),
                  Lottie.network(
                    'https://raw.githubusercontent.com/xvrh/lottie-flutter/master/example/assets/Mobilo/A.json', // Ganti ke file Lottie kamu
                    width: 80,
                    height: 80,
                    repeat: true,
                  ),
                ],
              ),
              duration: const Duration(milliseconds: 2000),
              animationDuration: const Duration(milliseconds: 1600),
              onAnimationEnd: () => debugPrint("Splash Ended"),
              nextScreen: snapshot.data ?? const SizedBox.shrink(),
            );
          },
        ),
      ),
    );
  }
}
