enum MaterialType { PDF, VIDEO }

class Material {
  final int id;
  final int chapterId;
  final String title;
  final String description;
  final MaterialType type;
  final String fileUrl;
  final String greading; // Field untuk konten HTML dari API
  final bool isLocked;
  final int order;
  final bool isCompleted;
  final int? score;

  Material({
    required this.id,
    required this.chapterId,
    required this.title,
    required this.description,
    required this.type,
    required this.fileUrl,
    required this.greading,
    required this.isLocked,
    required this.order,
    required this.isCompleted,
    this.score,
  });

  factory Material.fromJson(Map<String, dynamic> json) {
    return Material(
      id: json['id'],
      chapterId: 0, // Akan diset dari luar
      title: json['nama_materi'],
      description:
          json['nama_materi'], // Gunakan nama_materi sebagai description
      type: (json['jenis_materi'] == 'pdf')
          ? MaterialType.PDF
          : MaterialType.VIDEO,
      fileUrl: json['file_materi'] ?? '',
      greading: json['greading'] ?? '',
      isLocked:
          !(json['is_unlocked'] ?? true), // Default unlocked jika tidak ada
      order: json['id'], // Gunakan id sebagai order
      isCompleted: json['is_done'] ?? false,
      score: null, // Score belum ada di API
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_materi': title,
      'file_materi': fileUrl,
      'jenis_materi': type == MaterialType.PDF ? 'pdf' : 'video',
      'greading': greading,
      'is_done': isCompleted,
      'is_unlocked': !isLocked,
    };
  }
}
