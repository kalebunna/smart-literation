class SummaryParagraph {
  final int id;
  final int materialId;
  final int paragraphNumber;
  final String paragraph;
  final String createdAt;
  final String updatedAt;

  SummaryParagraph({
    required this.id,
    required this.materialId,
    required this.paragraphNumber,
    required this.paragraph,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SummaryParagraph.fromJson(Map<String, dynamic> json) {
    return SummaryParagraph(
      id: json['id'] ?? 0,
      materialId: json['materi_id'] ?? 0,
      paragraphNumber: json['paragraph_number'] ?? 0,
      paragraph: json['paragraph'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'materi_id': materialId,
      'paragraph_number': paragraphNumber,
      'paragraph': paragraph,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}