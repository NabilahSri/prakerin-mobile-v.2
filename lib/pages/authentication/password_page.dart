import 'package:flutter/material.dart';
import 'package:mobile_prakerin/core/constants/colors.dart';
import 'package:mobile_prakerin/widgets/custom_text_field.dart';
import 'package:mobile_prakerin/widgets/custom_button.dart';

class PasswordPage extends StatefulWidget {
  const PasswordPage({super.key});

  @override
  State<PasswordPage> createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
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
                            'Lupa Kata Sandi',
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
                        SizedBox(height: spacing * 0.5),
                        Text(
                          'Masukkan email yang terdaftar untuk menerima instruksi pengaturan ulang kata sandi',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: size.width * 0.04,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: spacing),
                        CustomTextField(
                          controller: _emailController,
                          hintText: 'Email',
                          prefixIcon: Icons.email,
                          // keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email tidak boleh kosong!';
                            }
                            if (!RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            ).hasMatch(value)) {
                              return 'Masukkan email yang valid!';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: spacing),
                        CustomButton(
                          text: 'Kirim Link Reset',
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              // TODO: Send password reset link
                            }
                          },
                        ),
                        SizedBox(height: spacing),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          child: const Text(
                            'Kembali ke Halaman Masuk',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
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
