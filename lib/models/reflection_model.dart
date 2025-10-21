class ReflectionQuestion {
  final int idSoal;
  final String soal;

  ReflectionQuestion({
    required this.idSoal,
    required this.soal,
  });

  factory ReflectionQuestion.fromJson(Map<String, dynamic> json) {
    return ReflectionQuestion(
      idSoal: json['id_soal'] ?? 0,
      soal: json['soal'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_soal': idSoal,
      'soal': soal,
    };
  }
}

class ReflectionSubmission {
  final int soalId;
  final String jawaban;

  ReflectionSubmission({
    required this.soalId,
    required this.jawaban,
  });

  Map<String, dynamic> toJson() {
    return {
      'soal_id': soalId,
      'jawaban': jawaban,
    };
  }
}