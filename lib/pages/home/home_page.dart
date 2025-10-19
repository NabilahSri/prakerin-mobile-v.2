import 'package:flutter/material.dart';
import 'package:mobile_prakerin/core/constants/colors.dart';
import 'package:mobile_prakerin/pages/activities/activity_tab.dart';
import 'package:mobile_prakerin/pages/home/home_tab.dart';
import 'package:mobile_prakerin/pages/presensi/presensi_tab.dart';
import 'package:mobile_prakerin/pages/settings/setting_tab.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  final int initialIndex;

  const HomePage({super.key, this.initialIndex = 0});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String selectedAttendanceMethod = 'lokasi';

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex; // Gunakan initialIndex dari parameter
    _loadAttendanceMethod();
  }

  _loadAttendanceMethod() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedAttendanceMethod =
          (prefs.getString('attendanceMethod') ?? 'lokasi');
    });
  }

  Future<void> _saveAttendanceMethod(String method) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('attendanceMethod', method);
  }

  List<Widget> get _pages => [
        const HomeTab(),
        PresensiTab(selectedAttendanceMethod: selectedAttendanceMethod),
        const ActivityTab(),
        SettingTab(
          selectedMethod: selectedAttendanceMethod,
          onMethodChanged: (method) {
            setState(() {
              selectedAttendanceMethod = method;
            });
            _saveAttendanceMethod(method);
          },
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          elevation: 0,
          backgroundColor: AppColors.white,
          selectedItemColor: AppColors.primaryDark,
          unselectedItemColor: AppColors.grey500,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _selectedIndex == 0
                      ? AppColors.primaryDark.withOpacity(0.1)
                      : AppColors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.home_rounded),
              ),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _selectedIndex == 1
                      ? AppColors.primaryDark.withOpacity(0.1)
                      : AppColors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.fingerprint_rounded),
              ),
              label: 'Kehadiran',
            ),
            BottomNavigationBarItem(
              icon: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _selectedIndex == 2
                      ? AppColors.primaryDark.withOpacity(0.1)
                      : AppColors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.assignment_rounded),
              ),
              label: 'Kegiatan',
            ),
            BottomNavigationBarItem(
              icon: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _selectedIndex == 3
                      ? AppColors.primaryDark.withOpacity(0.1)
                      : AppColors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.settings_rounded),
              ),
              label: 'Pengaturan',
            ),
          ],
        ),
      ),
    );
  }
}
