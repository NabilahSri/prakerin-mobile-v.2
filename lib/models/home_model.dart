class HomeModel {
  final String name;
  final String? email;
  final String? noHp;
  final String? alamat;
  final String kelas;
  final String perusahaan;
  final String alamatPerusahaan;
  final String pembimbing;
  final String? pemonitoring;
  final String? foto;
  final int kegiatan;
  final int hadir;
  final int izin;
  final int sakit;
  final int totalJam;
  final int totalMenit;

  HomeModel({
    required this.name,
    this.email,
    this.noHp,
    this.alamat,
    required this.kelas,
    required this.perusahaan,
    required this.alamatPerusahaan,
    required this.pembimbing,
    this.pemonitoring,
    required this.foto,
    required this.kegiatan,
    required this.hadir,
    required this.izin,
    required this.sakit,
    required this.totalJam,
    required this.totalMenit,
  });

  factory HomeModel.fromJson(Map<String, dynamic> json) {
    return HomeModel(
      name: json['siswa']['name'],
      email: json['siswa']['email'],
      noHp: json['siswa']['no_hp'],
      alamat: json['siswa']['alamat'],
      kelas: json['siswa']['kelas']['kelas'],
      perusahaan: json['siswa']['perusahaan'],
      pembimbing: json['siswa']['pembimbing'],
      foto: json['siswa']['foto'],
      kegiatan: json['kegiatan'],
      hadir: json['hadir'],
      izin: json['izin'],
      sakit: json['sakit'],
      totalJam: json['total_jam_kerja']['jam'],
      totalMenit: json['total_jam_kerja']['menit'],
      alamatPerusahaan: json['siswa']['alamat_perusahaan'],
      pemonitoring: json['siswa']['pemonitoring'],
    );
  }
}
