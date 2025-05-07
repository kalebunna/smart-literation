enum MaterialType { PDF, VIDEO }

class Material {
  final int id;
  final int chapterId;
  final String title;
  final String description;
  final MaterialType type;
  final String fileUrl;
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
    required this.isLocked,
    required this.order,
    required this.isCompleted,
    this.score,
  });

  factory Material.fromJson(Map<String, dynamic> json) {
    return Material(
      id: json['id'],
      chapterId: json['chapter_id'],
      title: json['title'],
      description: json['description'],
      type: json['type'] == 'pdf' ? MaterialType.PDF : MaterialType.VIDEO,
      fileUrl: json['file_url'],
      isLocked: json['is_locked'] ?? true,
      order: json['order'] ?? 0,
      isCompleted: json['is_completed'] ?? false,
      score: json['score'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chapter_id': chapterId,
      'title': title,
      'description': description,
      'type': type == MaterialType.PDF ? 'pdf' : 'video',
      'file_url': fileUrl,
      'is_locked': isLocked,
      'order': order,
      'is_completed': isCompleted,
      'score': score,
    };
  }
}
