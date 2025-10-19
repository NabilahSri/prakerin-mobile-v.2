class KegiatanModel {
  String judul;
  String deskripsi;
  String durasi;
  String? foto;
  String tanggal;

  KegiatanModel({
    required this.judul,
    required this.deskripsi,
    required this.durasi,
    this.foto,
    required this.tanggal,
  });

  factory KegiatanModel.fromJson(Map<String, dynamic> json) => KegiatanModel(
        judul: json['judul'],
        deskripsi: json['deskripsi'],
        durasi: json['durasi'],
        foto: json['foto'],
        tanggal: json['tanggal'],
      );
}
