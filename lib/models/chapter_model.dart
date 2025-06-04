class Chapter {
  final int id;
  final String name;
  final String description;
  final bool isDone;
  final bool isUnlocked;

  Chapter({
    required this.id,
    required this.name,
    required this.description,
    required this.isDone,
    required this.isUnlocked,
  });

  // Getter untuk compatibility dengan kode yang sudah ada
  String get title => name;
  bool get isLocked => !isUnlocked;
  int get order => id; // Menggunakan id sebagai order

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      isDone: json['is_done'] ?? false,
      isUnlocked: json['is_unlocked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'is_done': isDone,
      'is_unlocked': isUnlocked,
    };
  }
}
