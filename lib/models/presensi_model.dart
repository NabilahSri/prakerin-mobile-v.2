class PresensiModel {
  final int id;
  final String tanggal;
  final String status;
  final String? jamMasuk;
  final String? jamPulang;
  final String? catatan;
  final String? bukti;
  final int jumlahKegiatan;

  PresensiModel({
    required this.id,
    required this.tanggal,
    required this.status,
    this.jamMasuk,
    this.jamPulang,
    this.catatan,
    this.bukti,
    required this.jumlahKegiatan,
  });

  factory PresensiModel.fromJson(Map<String, dynamic> json) {
    return PresensiModel(
      id: json['id'] ?? 0,
      tanggal: json['tanggal'] ?? '',
      status: json['status'] ?? '',
      jamMasuk: json['jam_masuk'],
      jamPulang: json['jam_pulang'],
      catatan: json['catatan'],
      bukti: json['bukti'],
      jumlahKegiatan: json['jumlah_kegiatan'] ?? 0,
    );
  }

  void operator [](String other) {}
}
