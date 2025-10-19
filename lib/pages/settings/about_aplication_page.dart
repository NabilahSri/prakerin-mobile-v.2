import 'package:flutter/material.dart';
import 'package:mobile_prakerin/core/constants/colors.dart';

class AboutAplicationPage extends StatelessWidget {
  const AboutAplicationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.gradient,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppColors.white,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(screenWidth * 0.05),
                    child: Text(
                      'Tentang Aplikasi',
                      style: TextStyle(
                        fontSize: screenWidth * 0.055,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(screenWidth * 0.05),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/logo.png',
                            height: screenHeight * 0.14,
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          const Text(
                            'Prakerin App',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Versi 2.0.0',
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.04),
                          _buildInfoSection(
                            'Deskripsi',
                            'Aplikasi untuk memudahkan siswa dalam melakukan kegiatan Praktek Kerja Lapangan (PKL)',
                            Icons.info_outline,
                          ),
                          SizedBox(height: screenHeight * 0.03),
                          _buildInfoSection(
                            'Dikembangkan oleh',
                            'Pusdatin SMK YPC Tasikmalaya',
                            Icons.code,
                          ),
                          SizedBox(height: screenHeight * 0.03),
                          _buildInfoSection(
                            'Tahun',
                            '2025',
                            Icons.calendar_today,
                          ),
                          SizedBox(height: screenHeight * 0.03),
                          _buildInfoSection(
                            'Kontak',
                            'smkypctasikmalaya@gmail.com',
                            Icons.email,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, String content, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accent2, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
