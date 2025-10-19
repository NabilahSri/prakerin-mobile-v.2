import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_prakerin/core/constants/colors.dart';
import 'package:mobile_prakerin/models/presensi_model.dart';
import 'package:mobile_prakerin/services/presensi_service.dart';
import 'package:mobile_prakerin/widgets/custom_date_range_picker.dart';
import 'package:mobile_prakerin/widgets/custom_detail_modal_presensi.dart';

class PresensiHistoryPage extends StatefulWidget {
  const PresensiHistoryPage({super.key});

  @override
  State<PresensiHistoryPage> createState() => _PresensiHistoryPageState();
}

class _PresensiHistoryPageState extends State<PresensiHistoryPage> {
  DateTimeRange? _selectedDateRange;
  String? _selectedStatus;
  List<PresensiModel?> _presensiModelList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPresensiData();
  }

  Future<void> _loadPresensiData() async {
    final service = PresensiService();
    final list = await service.getDataPresensi();

    if (mounted) {
      setState(() {
        _presensiModelList = list;
        _isLoading = false;
      });
    }
  }

  final List<Map<String, dynamic>> _filterOptions = [
    {
      'label': 'Semua',
      'value': null,
      'icon': Icons.list_alt,
      'color': AppColors.primaryDark,
    },
    {
      'label': 'Hadir',
      'value': 'Hadir',
      'icon': Icons.check_circle,
      'color': AppColors.green700,
    },
    {
      'label': 'Sakit',
      'value': 'Sakit',
      'icon': Icons.medical_services,
      'color': AppColors.amber700,
    },
    {
      'label': 'Izin',
      'value': 'Izin',
      'icon': Icons.event_note,
      'color': AppColors.accent2,
    },
  ];

  void _showDateRangePicker() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (BuildContext context) {
        return CustomDateRangePicker(
          selectedDateRange: _selectedDateRange,
          onDateRangeSelected: (range) {
            setState(() {
              _selectedDateRange = range;
            });
          },
        );
      },
    );
  }

  void _resetDateRange() {
    setState(() {
      _selectedDateRange = null;
    });
  }

  List<PresensiModel?> _getFilteredData() {
    return _presensiModelList.where((data) {
      bool matchesDateRange = true;
      bool matchesStatus = true;
      if (data == null) return false;

      // Jika belum memilih tanggal, jangan tampilkan data apapun
      if (_selectedDateRange == null) {
        return false;
      }

      DateTime? tanggal;
      if (data.tanggal is DateTime) {
        tanggal = data.tanggal as DateTime;
      } else {
        tanggal = DateTime.tryParse(data.tanggal.toString());
      }

      // Validasi tanggal range
      if (tanggal == null) {
        matchesDateRange = false;
      } else {
        matchesDateRange = tanggal.isAfter(
                _selectedDateRange!.start.subtract(const Duration(days: 1))) &&
            tanggal
                .isBefore(_selectedDateRange!.end.add(const Duration(days: 1)));
      }

      if (_selectedStatus != null && _selectedStatus!.isNotEmpty) {
        matchesStatus =
            data.status.toLowerCase() == _selectedStatus!.toLowerCase();
      }

      return matchesDateRange && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final spacing = screenHeight * 0.02;
    // if (_isLoading) return const Center(child: CircularProgressIndicator());

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
                      'Riwayat Kehadiran',
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
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(screenWidth * 0.05),
                        child: Column(
                          children: [
                            Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: InkWell(
                                onTap: _showDateRangePicker,
                                borderRadius: BorderRadius.circular(15),
                                child: Padding(
                                  padding: EdgeInsets.all(screenWidth * 0.04),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding:
                                            EdgeInsets.all(screenWidth * 0.025),
                                        decoration: BoxDecoration(
                                          color: AppColors.accent2
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: const Icon(Icons.calendar_today,
                                            color: AppColors.accent2),
                                      ),
                                      SizedBox(width: screenWidth * 0.04),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Rentang Waktu',
                                              style: TextStyle(
                                                fontSize: screenWidth * 0.035,
                                                color: AppColors.grey500,
                                              ),
                                            ),
                                            SizedBox(
                                                height: screenHeight * 0.005),
                                            Text(
                                              _selectedDateRange != null
                                                  ? '${DateFormat('dd MMM yyyy', 'id_ID').format(_selectedDateRange!.start)} - '
                                                      '${DateFormat('dd MMM yyyy', 'id_ID').format(_selectedDateRange!.end)}'
                                                  : 'Pilih Tanggal',
                                              style: TextStyle(
                                                fontSize: screenWidth * 0.04,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (_selectedDateRange != null)
                                        IconButton(
                                          onPressed: _resetDateRange,
                                          icon: Icon(
                                            Icons.close,
                                            size: screenWidth * 0.05,
                                            color: AppColors.grey500,
                                          ),
                                        ),
                                      Icon(Icons.arrow_forward_ios,
                                          size: screenWidth * 0.04,
                                          color: AppColors.grey500),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: spacing),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: _filterOptions.map((option) {
                                  final bool isSelected =
                                      _selectedStatus == option['value'];
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: FilterChip(
                                      label: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            option['icon'] as IconData,
                                            size: 16,
                                            color: isSelected
                                                ? Colors.white
                                                : option['color'] as Color,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            option['label'] as String,
                                            style: TextStyle(
                                              color: isSelected
                                                  ? Colors.white
                                                  : option['color'] as Color,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      selected: isSelected,
                                      onSelected: (bool selected) {
                                        setState(() {
                                          _selectedStatus = selected
                                              ? option['value'] as String?
                                              : null;
                                        });
                                      },
                                      backgroundColor:
                                          (option['color'] as Color)
                                              .withOpacity(0.1),
                                      selectedColor: option['color'] as Color,
                                      checkmarkColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        side: BorderSide(
                                          color: isSelected
                                              ? Colors.transparent
                                              : (option['color'] as Color)
                                                  .withOpacity(0.5),
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: _getFilteredData().isEmpty
                            ? Column(
                                children: [
                                  SizedBox(height: screenHeight * 0.2),
                                  Center(
                                    child: Image.asset(
                                      'assets/images/not_found.jpg',
                                      width: screenWidth * 0.5,
                                    ),
                                  ),
                                  Text(
                                    'Data tidak ditemukan',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.05,
                                      color: AppColors.grey600,
                                    ),
                                  ),
                                ],
                              )
                            : ListView.separated(
                                shrinkWrap: true,
                                padding: EdgeInsets.all(screenWidth * 0.05),
                                itemCount: _getFilteredData().length,
                                itemBuilder: (context, index) {
                                  final data = _getFilteredData()[index];
                                  return GestureDetector(
                                    onTap: () {
                                      if (data.status.toLowerCase() ==
                                          'hadir') {
                                        Navigator.pushNamed(
                                          context,
                                          '/presensi_activity',
                                          arguments: data.id.toString(),
                                        );
                                      } else {
                                        showDetailModal(context, data);
                                      }
                                    },
                                    child: Card(
                                      margin: EdgeInsets.only(
                                          bottom: screenHeight * 0.02),
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Padding(
                                        padding:
                                            EdgeInsets.all(screenWidth * 0.04),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                _buildStatusIcon(data!.status),
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
                                                                .parse(data
                                                                    .tanggal)),
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
                                                          vertical: 4,
                                                        ),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: data.status
                                                                      .toLowerCase() ==
                                                                  'hadir'
                                                              ? AppColors
                                                                  .green700
                                                                  .withOpacity(
                                                                      0.1)
                                                              : data.status
                                                                          .toLowerCase() ==
                                                                      'sakit'
                                                                  ? AppColors
                                                                      .amber700
                                                                      .withOpacity(
                                                                          0.1)
                                                                  : AppColors
                                                                      .accent2
                                                                      .withOpacity(
                                                                          0.1),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                        child: Text(
                                                          data.status,
                                                          style: TextStyle(
                                                            color: data.status
                                                                        .toLowerCase() ==
                                                                    'hadir'
                                                                ? AppColors
                                                                    .green700
                                                                : data.status
                                                                            .toLowerCase() ==
                                                                        'sakit'
                                                                    ? AppColors
                                                                        .amber700
                                                                    : AppColors
                                                                        .accent2,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (data.status.toLowerCase() ==
                                                'hadir') ...[
                                              SizedBox(height: 12),
                                              Wrap(
                                                spacing: 8,
                                                runSpacing: 8,
                                                children: [
                                                  _buildTimeChip(
                                                    icon: Icons.login,
                                                    time: data.jamMasuk ?? '',
                                                    color: AppColors.green700,
                                                  ),
                                                  _buildTimeChip(
                                                    icon: Icons.logout,
                                                    time: data.jamPulang ?? '',
                                                    color: AppColors.red700,
                                                  ),
                                                  Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: AppColors
                                                          .primaryDark
                                                          .withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          Icons.task_alt,
                                                          size: 16,
                                                          color: AppColors
                                                              .primaryDark,
                                                        ),
                                                        SizedBox(width: 6),
                                                        Text(
                                                          '${data.jumlahKegiatan} Kegiatan',
                                                          style: TextStyle(
                                                            color: AppColors
                                                                .primaryDark,
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.bold,
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
                                separatorBuilder: (context, index) =>
                                    SizedBox(height: spacing * 0.8),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
        color = AppColors.green700;
        break;
      case 'sakit':
        icon = Icons.medical_services;
        color = AppColors.amber700;
        break;
      case 'izin':
        icon = Icons.event_note;
        color = AppColors.accent2;
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
}
