class ReadingMaterial {
  final int id;
  final String judul;
  final String penulis;
  final String penerbit;
  final String tahun;
  final String deskripsi;
  final String file;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReadingMaterial({
    required this.id,
    required this.judul,
    required this.penulis,
    required this.penerbit,
    required this.tahun,
    required this.deskripsi,
    required this.file,
    required this.createdAt,
    required this.updatedAt,
  });

  // Getters untuk kompatibilitas dengan kode yang sudah ada
  String get title => judul;
  String get description => deskripsi;
  String get fileUrl => file;
  String get thumbnailUrl => ''; // Tidak ada thumbnail dari API

  factory ReadingMaterial.fromJson(Map<String, dynamic> json) {
    return ReadingMaterial(
      id: json['id'],
      judul: json['judul'] ?? '',
      penulis: json['penulis'] ?? '',
      penerbit: json['penerbit'] ?? '',
      tahun: json['tahun'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      file: json['file'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'judul': judul,
      'penulis': penulis,
      'penerbit': penerbit,
      'tahun': tahun,
      'deskripsi': deskripsi,
      'file': file,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
