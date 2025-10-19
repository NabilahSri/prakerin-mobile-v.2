import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_prakerin/core/constants/colors.dart';
import 'package:mobile_prakerin/models/kegiatan_model.dart';
import 'package:mobile_prakerin/widgets/custom_date_range_picker.dart';

import '../../services/kegiatan_service.dart';

class ActivityTab extends StatefulWidget {
  const ActivityTab({super.key});

  @override
  State<ActivityTab> createState() => _ActivityTabState();
}

class _ActivityTabState extends State<ActivityTab> {
  DateTimeRange? _selectedDateRange;
  List<KegiatanModel?> _kegiatanModelList = [];
  bool _isLoading = true;

  Future<void> _loadPresensiData() async {
    final service = KegiatanService();
    final list = await service.getKegiatanByIdSiswa();

    if (mounted) {
      setState(() {
        _kegiatanModelList = list;
        _isLoading = false;
      });
    }
  }

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

  List<KegiatanModel?> _getFilteredData() {
    return _kegiatanModelList.where((data) {
      bool matchesDateRange = true;
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

      return matchesDateRange;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadPresensiData();
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).padding;
    final size = MediaQuery.of(context).size;
    final spacing = size.height * 0.02;

    return Stack(
      children: [
        // Background gradient container
        Container(
          height: size.height * 0.5,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: AppColors.gradient,
            ),
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(30),
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
                      // Date range picker card
                      Card(
                        elevation: 4,
                        shadowColor: Colors.black26,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: InkWell(
                          onTap: _showDateRangePicker,
                          borderRadius: BorderRadius.circular(15),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.accent2.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.calendar_today,
                                      color: AppColors.accent2),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Rentang Waktu',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppColors.grey500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _selectedDateRange != null
                                            ? '${DateFormat('dd MMM yyyy').format(_selectedDateRange!.start)} - '
                                                '${DateFormat('dd MMM yyyy').format(_selectedDateRange!.end)}'
                                            : 'Pilih Tanggal',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (_selectedDateRange != null)
                                  IconButton(
                                    onPressed: _resetDateRange,
                                    icon: const Icon(
                                      Icons.close,
                                      size: 20,
                                      color: AppColors.grey500,
                                    ),
                                  ),
                                const Icon(Icons.arrow_forward_ios,
                                    size: 16, color: AppColors.grey500),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: spacing),

                      Column(
                        children: [
                          if (_isLoading)
                            const Center(
                              child: CircularProgressIndicator(),
                            ),
                          if (!_isLoading)
                            (_getFilteredData().isEmpty)
                                ? Container(
                                    decoration: const BoxDecoration(
                                      color: AppColors.white,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(30)),
                                    ),
                                    child: Padding(
                                      padding:
                                          EdgeInsets.all(size.width * 0.05),
                                      child: Column(
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
                                      ),
                                    ),
                                  )
                                : ListView.separated(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: _getFilteredData().length,
                                    separatorBuilder: (context, index) =>
                                        SizedBox(height: spacing),
                                    itemBuilder: (context, index) {
                                      final activity =
                                          _getFilteredData()[index];
                                      final tanggalParsed =
                                          DateTime.tryParse(activity!.tanggal);
                                      final tanggal =
                                          tanggalParsed ?? DateTime.now();
                                      return Card(
                                        elevation: 2,
                                        shadowColor: Colors.black12,
                                        color: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.accent2
                                                          .withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    child: const Icon(
                                                      Icons.work_outline,
                                                      color: AppColors.accent2,
                                                      size: 20,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Text(
                                                      activity.judul,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 12),
                                              Text(
                                                activity.deskripsi,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                              // Activity image
                                              if (activity.foto != null &&
                                                  activity.foto!.isNotEmpty)
                                                Image.network(
                                                  activity.foto ?? '',
                                                  height: 120,
                                                  width: double.infinity,
                                                  fit: BoxFit.cover,
                                                )
                                              else
                                                const Text(
                                                  'Tidak ada foto',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontStyle:
                                                          FontStyle.italic),
                                                ),
                                              const SizedBox(height: 12),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade100,
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      DateFormat('dd MMMM yyyy',
                                                              'id_ID')
                                                          .format(tanggal),
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color:
                                                            AppColors.grey700,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              // Durasi pengerjaan
                                              Builder(
                                                builder: (_) {
                                                  return Row(
                                                    children: [
                                                      const Icon(Icons.timer,
                                                          size: 16),
                                                      const SizedBox(width: 6),
                                                      Text(
                                                        'Durasi: ${activity.durasi}',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              AppColors.grey700,
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                        ],
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
}
