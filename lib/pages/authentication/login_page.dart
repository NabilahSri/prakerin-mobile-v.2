import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobile_prakerin/core/constants/colors.dart';
import 'package:mobile_prakerin/services/auth_service.dart';
import 'package:mobile_prakerin/widgets/custom_text_field.dart';
import 'package:mobile_prakerin/widgets/custom_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isObscure = true;
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      final result = await _authService.login(
        username: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
      );

      setState(() {
        _isLoading = false;
      });

      if (result['success']) {
        // Lakukan penyimpanan token jika perlu
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('token', result['data']['token']);
        prefs.setInt('id_user', result['data']['user']['id']);
        prefs.setInt('id_siswa', result['data']['siswa']['id']);
        prefs.setInt(
            'id_tahun_ajaran', result['data']['siswa']['id_tahun_ajaran']);

        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Fluttertoast.showToast(
          msg: result['message'] ?? 'Login gagal',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    final logoHeight = size.height * 0.12;
    final spacing = size.height * 0.03;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: AppColors.gradient,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: constraints.maxWidth * 0.06,
                  vertical: constraints.maxHeight * 0.04,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight:
                        constraints.maxHeight - padding.top - padding.bottom,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TweenAnimationBuilder(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration: const Duration(seconds: 1),
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: value,
                              child: SizedBox(
                                height: logoHeight,
                                child: Image.asset(
                                  "assets/images/logo.png",
                                  fit: BoxFit.contain,
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: spacing),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Selamat Datang',
                            style: TextStyle(
                              fontSize: size.width * 0.07,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: const [
                                Shadow(
                                  color: Colors.black26,
                                  offset: Offset(2, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: spacing),
                        CustomTextField(
                          controller: _usernameController,
                          hintText: 'Username',
                          prefixIcon: Icons.person,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Username tidak boleh kosong!';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: spacing * 0.5),
                        CustomTextField(
                          controller: _passwordController,
                          hintText: 'Kata Sandi',
                          prefixIcon: Icons.lock,
                          obscureText: _isObscure,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isObscure
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.white70,
                            ),
                            onPressed: () {
                              setState(() {
                                _isObscure = !_isObscure;
                              });
                            },
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Kata sandi tidak boleh kosong!';
                            }
                            if (value.length < 8) {
                              return 'Kata sandi minimal 8 karakter!';
                            }
                            return null;
                          },
                        ),
                        // SizedBox(height: spacing * 0.3),
                        // Align(
                        //   alignment: Alignment.centerRight,
                        //   child: TextButton(
                        //     onPressed: () {
                        //       Navigator.pushNamed(context, '/password');
                        //     },
                        //     child: const Text(
                        //       'Lupa Kata Sandi?',
                        //       style: TextStyle(
                        //         color: Colors.white,
                        //         fontWeight: FontWeight.w600,
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        SizedBox(height: spacing),
                        _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : CustomButton(
                                text: 'Masuk', onPressed: _handleLogin),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
