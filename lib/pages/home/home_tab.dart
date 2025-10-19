import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_prakerin/core/constants/colors.dart';
import 'package:mobile_prakerin/models/home_model.dart';
import 'package:mobile_prakerin/models/kegiatan_model.dart';
import 'package:mobile_prakerin/services/home_service.dart';
import 'package:mobile_prakerin/services/kegiatan_service.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});
  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  bool _hasCheckedInToday = false;
  HomeModel? _homeModel;
  bool _isLoading = true;
  List<KegiatanModel>? kegiatanModel;

  @override
  void initState() {
    super.initState();
    _loadHomeData();
    _checkKehadiran();
    _getKegiatan();
  }

  Future<void> _loadHomeData() async {
    final service = HomeService();
    final data = await service.getData();

    if (mounted) {
      setState(() {
        _homeModel = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _checkKehadiran() async {
    final service = HomeService();
    final hasCheckedIn = await service.checkKehadiran();

    if (mounted) {
      setState(() {
        _hasCheckedInToday = hasCheckedIn?['success'] ?? false;
        _isLoading = false;
      });
    }
  }

  void _getKegiatan() async {
    final service = KegiatanService();
    final data = await service.get5Data();
    if (mounted) {
      setState(() {
        kegiatanModel = data?['kegiatan']
            .map<KegiatanModel>((item) => KegiatanModel.fromJson(item))
            .toList();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).padding;
    final size = MediaQuery.of(context).size;
    final spacing = size.height * 0.025;
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    return Stack(
      children: [
        Container(
          height: size.height * 0.5, // Half of screen height
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
        // Main content
        SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: constraints.maxWidth * 0.05,
                  vertical: constraints.maxHeight * 0.03,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight:
                        constraints.maxHeight - padding.top - padding.bottom,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileSection(size),
                      SizedBox(height: spacing),
                      _buildSummaryCards(),
                      SizedBox(height: spacing),
                      _buildRecentActivities(size, spacing),
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

  // Rest of the code remains the same...
  Widget _buildProfileSection(Size size) {
    // Previous implementation
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 2),
                ),
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.white.withOpacity(0.2),
                  child: _homeModel?.foto != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Image.network(
                            _homeModel!.foto!,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Icon(
                          Icons.person,
                          size: 40,
                          color: AppColors.white.withOpacity(0.7),
                        ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hi, ${_homeModel?.name ?? ' '}!',
                      style: TextStyle(
                        fontSize: size.width * 0.054,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                    Text(
                      '${_homeModel?.perusahaan ?? ' '}',
                      style: TextStyle(
                        fontSize: size.width * 0.036,
                        color: AppColors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${_homeModel?.pembimbing ?? ' '}',
                      style: TextStyle(
                        fontSize: size.width * 0.036,
                        color: AppColors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${_homeModel?.kelas ?? ''}',
                            style: TextStyle(
                              fontSize: size.width * 0.028,
                              color: AppColors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
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
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!_hasCheckedInToday) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.red700.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.red700,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Belum Melakukan Presensi Hari Ini',
                    style: TextStyle(
                      color: AppColors.red700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }

  // Rest of the widget methods remain unchanged...
  Widget _buildSummaryCards() {
    // Previous implementation
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.blue50,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
                bottom: Radius.circular(24),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSummaryItem(
                  Icons.access_time_rounded,
                  'Total Jam Kerja',
                  '${_homeModel?.totalJam ?? 0} : ${_homeModel?.totalMenit ?? 0} ',
                ),
                _buildSummaryItem(
                  Icons.event_rounded,
                  'Total Kegiatan',
                  '${_homeModel?.kegiatan ?? 0}',
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttendanceItem(
                  Icons.check_circle_outline,
                  'Hadir',
                  '${_homeModel?.hadir ?? 0}',
                  AppColors.green700,
                ),
                Container(
                  height: 50,
                  width: 1,
                  color: AppColors.grey200,
                ),
                _buildAttendanceItem(
                  Icons.sick_outlined,
                  'Sakit',
                  '${_homeModel?.sakit ?? 0}',
                  AppColors.amber700,
                ),
                Container(
                  height: 50,
                  width: 1,
                  color: Colors.grey.shade200,
                ),
                _buildAttendanceItem(
                  Icons.event_busy_outlined,
                  'Izin',
                  '${_homeModel?.izin ?? 0}',
                  AppColors.red700,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivities(Size size, double spacing) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kegiatan Terbaru',
            style: TextStyle(
              fontSize: size.width * 0.045,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 16),
          (kegiatanModel == null || kegiatanModel!.isEmpty)
              ? Column(
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/images/not_found.jpg',
                        width: size.width * 0.5,
                      ),
                    ),
                    Text(
                      'Kegiatan tidak ditemukan',
                      style: TextStyle(
                        fontSize: size.width * 0.05,
                        color: AppColors.grey600,
                      ),
                    ),
                  ],
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: kegiatanModel?.length ?? 0,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final activity = kegiatanModel?[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.green700.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.task_alt_rounded,
                            color: AppColors.green700,
                            size: 24,
                          )),
                      title: Text(
                        activity!.judul,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        DateFormat('dd MMMM yyyy', 'id_ID')
                            .format(DateTime.parse(activity.tanggal)),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.grey600,
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(IconData icon, String label, String value) {
    // Previous implementation
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.blue100,
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(
            icon,
            color: AppColors.accent1,
            size: 32,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 28,
            color: AppColors.primaryDark,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            color: AppColors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceItem(
      IconData icon, String label, String value, Color color) {
    // Previous implementation
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.grey700,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
