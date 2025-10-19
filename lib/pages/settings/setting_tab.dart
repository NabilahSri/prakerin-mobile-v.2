import 'package:flutter/material.dart';
import 'package:mobile_prakerin/core/constants/colors.dart';
import 'package:mobile_prakerin/services/auth_service.dart';
import 'package:mobile_prakerin/widgets/custom_button.dart';

import '../../models/home_model.dart';
import '../../services/home_service.dart';
import '../../services/support_service.dart';

class SettingTab extends StatefulWidget {
  final String selectedMethod;
  final ValueChanged<String> onMethodChanged;
  const SettingTab({
    super.key,
    required this.selectedMethod,
    required this.onMethodChanged,
  });

  @override
  State<SettingTab> createState() => _SettingTabState();
}

class _SettingTabState extends State<SettingTab> {
  final SupportService _supportService = SupportService();
  String selectedAttendanceMethod = 'lokasi';
  final _authService = AuthService();
  HomeModel? _homeModel;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    selectedAttendanceMethod = widget.selectedMethod;
    _loadData();
  }

  Future<void> _loadData() async {
    final service = HomeService();
    final data = await service.getData();

    if (mounted) {
      setState(() {
        _homeModel = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text(
          "Konfirmasi",
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          "Yakin ingin keluar dari aplikasi?",
          style: TextStyle(fontSize: 16),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              "Batal",
              style: TextStyle(
                color: AppColors.grey700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Keluar",
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _authService.logout();
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).padding;
    final size = MediaQuery.of(context).size;
    final spacing = size.height * 0.02;
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    return Stack(
      children: [
        Container(
          height: size.height * 0.5,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: AppColors.gradient,
            ),
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(40),
            ),
          ),
        ),
        SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: constraints.maxWidth * 0.05,
                  vertical: constraints.maxHeight * 0.02,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight:
                        constraints.maxHeight - padding.top - padding.bottom,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: spacing),
                      // Profile Section with glassmorphism effect
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.white.withOpacity(0.2),
                                        Colors.white.withOpacity(0.1),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: AppColors.white, width: 2),
                                  ),
                                  child: CircleAvatar(
                                    radius: 40,
                                    backgroundColor:
                                        AppColors.white.withOpacity(0.2),
                                    child: _homeModel?.foto != null
                                        ? ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(50),
                                            child: Image.network(
                                              _homeModel!.foto!,
                                              width: 75,
                                              height: 75,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : Icon(
                                            Icons.person,
                                            size: 40,
                                            color: AppColors.white
                                                .withOpacity(0.7),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              _homeModel?.name ?? '',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: size.width * 0.055,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _homeModel?.kelas ?? '',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: size.width * 0.038,
                                color: Colors.white.withOpacity(0.95),
                                letterSpacing: 0.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.green.shade400,
                                    Colors.green.shade600,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.green700.withOpacity(0.35),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Text(
                                'Aktif',
                                style: TextStyle(
                                  fontSize: size.width * 0.028,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: spacing * 1.2),
                      _buildSettingsSection(
                        [
                          _buildSettingTile(
                            'Ubah Profil',
                            Icons.edit_rounded,
                            onTap: () {
                              Navigator.pushNamed(context, '/profile');
                            },
                          ),
                          _buildSettingTile(
                            'Ubah Kata Sandi',
                            Icons.lock_outline_rounded,
                            onTap: () {
                              Navigator.pushNamed(context, '/edit_password');
                            },
                          ),
                          _buildSettingTile(
                            'Informasi Tambahan',
                            Icons.info_outline_rounded,
                            onTap: () {
                              Navigator.pushNamed(context, '/information');
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: spacing),
                      _buildSettingsSection([
                        _buildSettingTile(
                          'Metode Kehadiran',
                          Icons.how_to_reg_rounded,
                          trailing: DropdownButton<String>(
                            value: selectedAttendanceMethod,
                            underline: const SizedBox(),
                            items: [
                              DropdownMenuItem(
                                value: 'lokasi',
                                child: Text('Lokasi',
                                    style: TextStyle(
                                        color: AppColors.primaryDark)),
                              ),
                              DropdownMenuItem(
                                value: 'token',
                                child: Text('Token',
                                    style: TextStyle(
                                        color: AppColors.primaryDark)),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                selectedAttendanceMethod = value!;
                              });
                              widget.onMethodChanged(value!);
                            },
                          ),
                        ),
                        if (selectedAttendanceMethod == 'lokasi')
                          _buildSettingTile(
                            'Atur Lokasi',
                            Icons.location_on_rounded,
                            onTap: () {
                              // Handle location settings
                              Navigator.pushNamed(context, '/set_location');
                            },
                          ),
                      ]),
                      SizedBox(height: spacing),
                      _buildSettingsSection(
                        [
                          _buildSettingTile(
                            'Tentang Aplikasi',
                            Icons.help_outline_rounded,
                            onTap: () {
                              Navigator.pushNamed(context, '/about_aplication');
                            },
                          ),
                          _buildSettingTile(
                            'Panduan Penggunaan Aplikasi',
                            Icons.menu_book_rounded,
                            onTap: () {
                              Navigator.pushNamed(context, '/panduan');
                            },
                          ),
                          _buildSettingTile(
                            'Laporkan Masalah',
                            Icons.bug_report_rounded,
                            onTap: () {
                              _showReportOptions(context);
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: spacing),
                      CustomButton(
                        text: 'Keluar',
                        onPressed: () => _confirmLogout(context),
                        backgroundColor: AppColors.red700,
                        color: AppColors.white,
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showReportOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              _buildOptionsHeader(),
              // WhatsApp Option
              _buildWhatsAppOption(),
              // Email Option
              _buildEmailOption(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailOption() {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.email_rounded,
          color: Colors.blue,
          size: 28,
        ),
      ),
      title: const Text(
        'Email Admin',
        style: TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: const Text(
        'Untuk dokumentasi masalah yang kompleks',
        style: TextStyle(fontSize: 12),
      ),
      onTap: () {
        Navigator.pop(context);
        _supportService.openEmailSupport(context);
      },
    );
  }

  Widget _buildOptionsHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryDark.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.support_agent_rounded,
              color: AppColors.primaryDark,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Hubungi Support',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildWhatsAppOption() {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF25D366).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.phone_rounded,
          color: Color(0xFF25D366),
          size: 28,
        ),
      ),
      title: const Text(
        'WhatsApp Admin',
        style: TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: const Text(
        'Respon cepat, bisa kirim screenshot langsung',
        style: TextStyle(fontSize: 12),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF25D366).withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Text(
          'REKOMENDASI',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Color(0xFF25D366),
          ),
        ),
      ),
      onTap: () {
        _supportService.openWhatsAppSupport(context);
      },
    );
  }
}

Widget _buildSettingsSection(List<Widget> children) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: Colors.grey.shade200,
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Column(
      children: children,
    ),
  );
}

Widget _buildSettingTile(String title, IconData icon,
    {Widget? trailing, VoidCallback? onTap}) {
  return Column(
    children: [
      ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 4,
        ),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryDark.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppColors.primaryDark,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: trailing ??
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryDark.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.primaryDark,
                size: 14,
              ),
            ),
        onTap: onTap,
      ),
      if (trailing == null)
        Divider(
          height: 1,
          color: AppColors.grey500.withOpacity(0.3),
          indent: 20,
          endIndent: 20,
        ),
    ],
  );
}
