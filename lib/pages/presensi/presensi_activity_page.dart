import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_prakerin/core/constants/colors.dart';
import 'package:mobile_prakerin/models/kegiatan_model.dart';

import '../../services/kegiatan_service.dart';

class PresensiActivityPage extends StatefulWidget {
  final String id_presensi;
  PresensiActivityPage({super.key, required this.id_presensi});

  @override
  State<PresensiActivityPage> createState() => _PresensiActivityPageState();
}

class _PresensiActivityPageState extends State<PresensiActivityPage> {
  List<KegiatanModel>? kegiatanModel;
  List<KegiatanModel>? filteredKegiatanModel;
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  Future<void> _getData() async {
    final service = KegiatanService();
    final data = await service.getKegiatanByIdPresensi(widget.id_presensi);
    if (mounted) {
      setState(() {
        kegiatanModel = data?['kegiatan']
            .map<KegiatanModel>((item) => KegiatanModel.fromJson(item))
            .toList();
        filteredKegiatanModel = kegiatanModel;
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getData();
  }

  void _filterKegiatan(String query) {
    List<KegiatanModel> results = [];
    if (query.isEmpty) {
      results = kegiatanModel!;
    } else {
      results = kegiatanModel!
          .where((kegiatan) =>
              kegiatan.judul.toLowerCase().contains(query.toLowerCase()) ||
              kegiatan.deskripsi.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }

    if (mounted) {
      setState(() {
        filteredKegiatanModel = results;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final spacing = screenHeight * 0.02;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/activity_add',
              arguments: widget.id_presensi);
        },
        backgroundColor: AppColors.accent2,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
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
                      'Riwayat Kegiatan',
                      style: TextStyle(
                        fontSize: screenWidth * 0.055,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05, vertical: spacing),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari Kegiatan...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    _filterKegiatan(value);
                  },
                ),
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(screenWidth * 0.05),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          if (_isLoading)
                            const Center(
                              child: CircularProgressIndicator(),
                            ),
                          if (!_isLoading)
                            (filteredKegiatanModel == null ||
                                    filteredKegiatanModel!.isEmpty)
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
                                        'Kegiatan tidak ditemukan',
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.05,
                                          color: AppColors.grey600,
                                        ),
                                      ),
                                    ],
                                  )
                                : ListView.separated(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount:
                                        filteredKegiatanModel?.length ?? 0,
                                    separatorBuilder: (context, index) =>
                                        SizedBox(height: spacing),
                                    itemBuilder: (context, index) {
                                      final activity =
                                          filteredKegiatanModel![index];
                                      final tanggalParsed =
                                          DateTime.tryParse(activity.tanggal);
                                      final tanggal =
                                          tanggalParsed ?? DateTime.now();
                                      return Card(
                                        elevation: 2,
                                        shadowColor: Colors.black12,
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
}
