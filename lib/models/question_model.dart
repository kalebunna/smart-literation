class QuizQuestion {
  final int id;
  final String question;
  final List<String> options;
  final int correctOptionIndex;
  final String? explanation;
  final List<String> explanations;

  QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctOptionIndex,
    this.explanation,
    this.explanations = const [],
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    List<String> options = [
      json['pilihan_a'] ?? '',
      json['pilihan_b'] ?? '',
      json['pilihan_c'] ?? '',
      json['pilihan_d'] ?? '',
    ];

    List<String> explanations = [
      json['penjelasan_a'] ?? '',
      json['penjelasan_b'] ?? '',
      json['penjelasan_c'] ?? '',
      json['penjelasan_d'] ?? '',
    ];

    int correctIndex = 0;
    String correctAnswer = (json['jawaban'] ?? 'a').toLowerCase();
    switch (correctAnswer) {
      case 'a':
        correctIndex = 0;
        break;
      case 'b':
        correctIndex = 1;
        break;
      case 'c':
        correctIndex = 2;
        break;
      case 'd':
        correctIndex = 3;
        break;
    }

    return QuizQuestion(
      id: json['id'],
      question: json['soal'] ?? '',
      options: options,
      correctOptionIndex: correctIndex,
      explanation: explanations[correctIndex],
      explanations: explanations,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correct_option_index': correctOptionIndex,
      'explanation': explanation,
      'explanations': explanations,
    };
  }
}
