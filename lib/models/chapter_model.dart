class Chapter {
  final int id;
  final String title;
  final String description;
  final bool isLocked;
  final int order;

  Chapter({
    required this.id,
    required this.title,
    required this.description,
    required this.isLocked,
    required this.order,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      isLocked: json['is_locked'] ?? true,
      order: json['order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'is_locked': isLocked,
      'order': order,
    };
  }
}
