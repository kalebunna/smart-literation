class QuizQuestion {
  final int id;
  final String question;
  final List<String> options;
  final int correctOptionIndex;
  final String? explanation;

  QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctOptionIndex,
    this.explanation,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'],
      question: json['question'],
      options: List<String>.from(json['options']),
      correctOptionIndex: json['correct_option_index'],
      explanation: json['explanation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correct_option_index': correctOptionIndex,
      'explanation': explanation,
    };
  }
}
