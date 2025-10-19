import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobile_prakerin/core/constants/colors.dart';
import 'package:intl/intl.dart';
import 'package:mobile_prakerin/models/presensi_model.dart';
import 'package:mobile_prakerin/services/presensi_service.dart';
import 'package:mobile_prakerin/widgets/custom_detail_modal_presensi.dart';

import '../../services/home_service.dart';

class PresensiTab extends StatefulWidget {
  final String selectedAttendanceMethod;

  const PresensiTab({
    super.key,
    required this.selectedAttendanceMethod,
  });

  @override
  State<PresensiTab> createState() => _PresensiTabState();
}

class _PresensiTabState extends State<PresensiTab> {
  String? _currentDay;
  String? _currentDate;
  String? _currentTime;
  Timer? _timer;
  bool _isLocaleReady = false;
  final _tokenController = TextEditingController();
  List<PresensiModel?> _presensiModelList = [];
  bool _isLoading = true;
  bool _isLoadingPresensiMasuk = false;
  bool _isLoadingPresensiKeluar = false;
  bool _hasCheckedInToday = false;
  String? _cekMasuk;
  String? _cekKeluar;
  String? _bukti;

  @override
  void initState() {
    super.initState();
    if (mounted) {
      setState(() {
        _isLocaleReady = true;
        _updateDateTime();
      });
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _updateDateTime();
        });
      }
    });
    _load5PresensiData();
    _checkKehadiran();
  }

  Future<void> _load5PresensiData() async {
    final service = PresensiService();
    final list = await service.get5DataPresensi();

    if (mounted) {
      setState(() {
        _presensiModelList = list;
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
        _cekMasuk = hasCheckedIn?['kehadiran']['jam_masuk'];
        _cekKeluar = hasCheckedIn?['kehadiran']['jam_pulang'];
        _bukti = hasCheckedIn?['kehadiran']['bukti'];
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tokenController.dispose();
    super.dispose();
  }

  void _updateDateTime() {
    final now = DateTime.now();
    _currentDay = DateFormat('EEEE', 'id_ID').format(now);
    _currentDate = DateFormat('d MMMM y', 'id_ID').format(now);
    _currentTime = DateFormat('HH:mm:ss').format(now);
  }

  Future<void> _presensiMasuk() async {
    if (mounted) {
      setState(() {
        _isLoadingPresensiMasuk = true;
      });
    }

    final service = PresensiService();
    final result = await service.presensiMasuk(
      mode: widget.selectedAttendanceMethod,
      tokenMasuk: _tokenController.text,
    );

    if (mounted) {
      setState(() {
        _isLoadingPresensiMasuk = false;
      });
    }

    if (result['success']) {
      Fluttertoast.showToast(
        msg: result['message'] ?? 'Presensi masuk berhasil',
      );
      _checkKehadiran();
      _load5PresensiData();
    } else {
      Fluttertoast.showToast(
        msg: result['message'] ?? 'Presensi masuk gagal',
      );
    }
  }

  Future<void> _presensiPulang() async {
    if (mounted) {
      setState(() {
        _isLoadingPresensiKeluar = true;
      });
    }

    final service = PresensiService();
    final result = await service.presensiPulang(
      mode: widget.selectedAttendanceMethod,
      status: 'hadir',
      tokenPulang: _tokenController.text,
    );

    if (mounted) {
      setState(() {
        _isLoadingPresensiKeluar = false;
      });
    }

    if (result['success']) {
      Fluttertoast.showToast(
        msg: result['message'] ?? 'Presensi pulang berhasil',
      );
      _checkKehadiran();
      _load5PresensiData();
    } else {
      Fluttertoast.showToast(
        msg: result['message'] ?? 'Presensi pulang gagal',
      );
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
                    children: [
                      if (_isLocaleReady) ...[
                        // Date and Time Card
                        Container(
                          padding: EdgeInsets.all(spacing),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child: Column(
                              children: [
                                // Date Display
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Date section with icon
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: const Icon(
                                            Icons.calendar_today,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                        ),
                                        SizedBox(width: spacing * 0.8),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _currentDay ?? '',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              _currentDate ?? '',
                                              style: TextStyle(
                                                color: Colors.white
                                                    .withOpacity(0.9),
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),

                                    // Time section
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        _currentTime ?? '',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 2,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                Divider(
                                  color: Colors.white.withOpacity(0.3),
                                  height: spacing * 3,
                                ),

                                // Time Display

                                if (_cekKeluar != null ||
                                    (_hasCheckedInToday && _bukti != null)) ...[
                                  Text(
                                    'Kamu sudah melakukan presensi hari ini.',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                ] else ...[
                                  // Sick/Permission Form Icon + Info Text
                                  if (_cekMasuk == null) ...[
                                    IconButton(
                                      icon: Icon(Icons.note_add,
                                          color: Colors.white, size: 36),
                                      tooltip: 'Form Izin / Sakit',
                                      onPressed: () {
                                        // TODO: Navigate to sick/permission form
                                        Navigator.pushNamed(
                                            context, '/presensi_formulir');
                                      },
                                    ),
                                    SizedBox(height: 4),
                                    Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Jika kamu tidak bisa hadir karena sakit atau izin,\nklik ikon 📄 di atas untuk isi formulir.',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.8),
                                          fontSize: 12,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    SizedBox(height: spacing),
                                  ],

                                  // Token Input Field
                                  if (widget.selectedAttendanceMethod ==
                                      'token') ...[
                                    TextField(
                                      controller: _tokenController,
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'Masukkan Token',
                                        hintStyle: TextStyle(
                                          color: Colors.white,
                                        ),
                                        filled: true,
                                        fillColor:
                                            Colors.white.withOpacity(0.1),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          borderSide: BorderSide.none,
                                        ),
                                        prefixIcon: Icon(
                                          Icons.vpn_key,
                                          color: Colors.white,
                                        ),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: spacing),
                                  ],

                                  // Attendance Buttons
                                  Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _isLoadingPresensiMasuk
                                                ? const Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                      color: Colors.white,
                                                    ),
                                                  )
                                                : _cekMasuk != null
                                                    ? Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(15),
                                                          color: Colors.white
                                                              .withOpacity(0.2),
                                                        ),
                                                        child: ElevatedButton(
                                                          onPressed: () {},
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                            backgroundColor:
                                                                Colors
                                                                    .transparent,
                                                            elevation: 0,
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        15),
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          15),
                                                            ),
                                                          ),
                                                          child: Icon(
                                                              Icons
                                                                  .check_circle,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      )
                                                    : Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(15),
                                                          color: Colors.white
                                                              .withOpacity(0.2),
                                                        ),
                                                        child: ElevatedButton(
                                                          onPressed: () {
                                                            _presensiMasuk();
                                                          },
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                            backgroundColor:
                                                                Colors
                                                                    .transparent,
                                                            elevation: 0,
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        15),
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          15),
                                                            ),
                                                          ),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Icon(Icons.login,
                                                                  color: Colors
                                                                      .white),
                                                              SizedBox(
                                                                  width: 8),
                                                              Text(
                                                                'Masuk',
                                                                style:
                                                                    TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                          ),
                                          SizedBox(width: spacing),
                                          Expanded(
                                            child: _hasCheckedInToday == false
                                                ? Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                      color: Colors.white
                                                          .withOpacity(0.2),
                                                    ),
                                                    child: ElevatedButton(
                                                      onPressed: () {},
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            Colors.transparent,
                                                        elevation: 0,
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 15),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(15),
                                                        ),
                                                      ),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(Icons.logout,
                                                              color:
                                                                  Colors.white),
                                                          SizedBox(width: 8),
                                                          Text(
                                                            'Pulang',
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                : _isLoadingPresensiKeluar
                                                    ? const Center(
                                                        child:
                                                            CircularProgressIndicator(
                                                          color: Colors.white,
                                                        ),
                                                      )
                                                    : Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(15),
                                                          color: Colors.white
                                                              .withOpacity(0.2),
                                                        ),
                                                        child: ElevatedButton(
                                                          onPressed: () {
                                                            _presensiPulang();
                                                          },
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                            backgroundColor:
                                                                Colors
                                                                    .transparent,
                                                            elevation: 0,
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        15),
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          15),
                                                            ),
                                                          ),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Icon(Icons.logout,
                                                                  color: Colors
                                                                      .white),
                                                              SizedBox(
                                                                  width: 8),
                                                              Text(
                                                                'Pulang',
                                                                style:
                                                                    TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: spacing * 2),
                        // Riwayat Kehadiran
                        Card(
                          color: AppColors.white,
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(spacing),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header section
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 16),
                                  decoration: BoxDecoration(
                                    color:
                                        AppColors.primaryDark.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: AppColors.primaryDark
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                            child: Icon(
                                              Icons.access_time_rounded,
                                              color: AppColors.primaryDark,
                                              size: 24,
                                            ),
                                          ),
                                          SizedBox(width: spacing),
                                          Text(
                                            'Riwayat Kehadiran',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primaryDark,
                                            ),
                                          ),
                                        ],
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          Navigator.pushNamed(
                                              context, '/presensi_history');
                                        },
                                        icon: Icon(
                                          Icons.arrow_forward_rounded,
                                          color: AppColors.primaryDark,
                                          size: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: spacing),

                                if (_presensiModelList.isEmpty) ...[
                                  Column(
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
                                ],

                                // List of attendance records
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: _presensiModelList.length,
                                  separatorBuilder: (context, index) =>
                                      SizedBox(height: spacing * 0.8),
                                  itemBuilder: (context, index) {
                                    final data = _presensiModelList[index];

                                    return GestureDetector(
                                      onTap: () {
                                        if (data?.status.toLowerCase() ==
                                            'hadir') {
                                          Navigator.pushNamed(
                                              context, '/presensi_activity',
                                              arguments: data?.id.toString());
                                        } else {
                                          showDetailModal(context, data!);
                                        }
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.grey200,
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  _buildStatusIcon(
                                                      data?.status ?? ''),
                                                  SizedBox(width: 12),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          DateFormat(
                                                                  'EEEE, dd MMMM yyyy',
                                                                  'id_ID')
                                                              .format(DateTime
                                                                  .parse(
                                                                      data?.tanggal ??
                                                                          '')),
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                        SizedBox(height: 4),
                                                        Container(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal: 8,
                                                                  vertical: 4),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: _getStatusColor(
                                                                    data?.status ??
                                                                        '')
                                                                .withOpacity(
                                                                    0.1),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                          ),
                                                          child: Text(
                                                            data?.status ?? '',
                                                            style: TextStyle(
                                                              color: _getStatusColor(
                                                                  data?.status ??
                                                                      ''),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              if ((data?.status ?? '')
                                                      .toLowerCase() ==
                                                  'hadir') ...[
                                                SizedBox(height: 12),
                                                Wrap(
                                                  spacing: 8,
                                                  runSpacing: 8,
                                                  children: [
                                                    _buildTimeChip(
                                                      icon: Icons.login,
                                                      time: data?.jamMasuk ??
                                                          '00:00:00',
                                                      color: AppColors.green700,
                                                    ),
                                                    _buildTimeChip(
                                                      icon: Icons.logout,
                                                      time: data?.jamPulang ??
                                                          '00:00:00',
                                                      color: AppColors.red700,
                                                    ),
                                                    Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 12,
                                                              vertical: 6),
                                                      decoration: BoxDecoration(
                                                        color: AppColors
                                                            .primaryDark
                                                            .withOpacity(0.1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Icon(Icons.task_alt,
                                                              size: 16,
                                                              color: AppColors
                                                                  .primaryDark),
                                                          SizedBox(width: 6),
                                                          Text(
                                                            '${data?.jumlahKegiatan ?? 0} Kegiatan',
                                                            style: TextStyle(
                                                              color: AppColors
                                                                  .primaryDark,
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ]
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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
}

Color _getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'hadir':
      return Colors.green;
    case 'sakit':
      return Colors.orange;
    case 'izin':
      return Colors.blue;
    default:
      return AppColors.primaryDark;
  }
}

Future<void> showDetailModal(BuildContext context, PresensiModel data) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => CustomDetailModalPresensi(data: data),
  );
}

Widget _buildStatusIcon(String status) {
  IconData icon;
  Color color;

  switch (status.toLowerCase()) {
    case 'hadir':
      icon = Icons.check_circle;
      color = Colors.green;
      break;
    case 'sakit':
      icon = Icons.medical_services;
      color = Colors.orange;
      break;
    case 'izin':
      icon = Icons.event_note;
      color = Colors.blue;
      break;
    default:
      icon = Icons.vpn_key;
      color = AppColors.primaryDark;
  }

  return CircleAvatar(
    backgroundColor: color.withOpacity(0.1),
    child: Icon(
      icon,
      color: color,
    ),
  );
}

Widget _buildTimeChip({
  required IconData icon,
  required String time,
  required Color color,
}) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        SizedBox(width: 4),
        Text(
          time,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}
