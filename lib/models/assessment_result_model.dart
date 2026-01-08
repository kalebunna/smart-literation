class AssessmentResultItem {
  final int soalId;
  final String soal;
  final String pilihanA;
  final String pilihanB;
  final String pilihanC;
  final String pilihanD;
  final String jawabanBenar; // a, b, c, d
  final String? jawabanUser; // a, b, c, d
  final bool benar;

  AssessmentResultItem({
    required this.soalId,
    required this.soal,
    required this.pilihanA,
    required this.pilihanB,
    required this.pilihanC,
    required this.pilihanD,
    required this.jawabanBenar,
    this.jawabanUser,
    required this.benar,
  });

  factory AssessmentResultItem.fromJson(Map<String, dynamic> json) {
    return AssessmentResultItem(
      soalId: json['soal_id'] ?? 0,
      soal: json['soal'] ?? '',
      pilihanA: json['pilihan_a'] ?? '',
      pilihanB: json['pilihan_b'] ?? '',
      pilihanC: json['pilihan_c'] ?? '',
      pilihanD: json['pilihan_d'] ?? '',
      jawabanBenar: (json['jawaban_benar'] ?? 'a').toLowerCase(),
      jawabanUser: json['jawaban_user'] != null
          ? json['jawaban_user'].toString().toLowerCase()
          : null,
      benar: json['benar'] ?? false,
    );
  }

  // Get option by letter (a, b, c, d)
  String getOption(String letter) {
    switch (letter.toLowerCase()) {
      case 'a':
        return pilihanA;
      case 'b':
        return pilihanB;
      case 'c':
        return pilihanC;
      case 'd':
        return pilihanD;
      default:
        return '';
    }
  }

  // Get option index (0-3) from letter
  int getOptionIndex(String letter) {
    switch (letter.toLowerCase()) {
      case 'a':
        return 0;
      case 'b':
        return 1;
      case 'c':
        return 2;
      case 'd':
        return 3;
      default:
        return 0;
    }
  }

  // Get all options as list
  List<String> get options => [pilihanA, pilihanB, pilihanC, pilihanD];
}

class AssessmentResult {
  final List<AssessmentResultItem> results;
  final int totalSoal;
  final int jawabanBenar;
  final int jawabanSalah;
  final double skor;

  AssessmentResult({
    required this.results,
    required this.totalSoal,
    required this.jawabanBenar,
    required this.jawabanSalah,
    required this.skor,
  });

  factory AssessmentResult.fromJson(Map<String, dynamic> json) {
    final List<dynamic> resultsData = json['results'] ?? [];

    // Handle skor yang bisa int atau double
    double skorValue = 0.0;
    if (json['skor'] != null) {
      if (json['skor'] is int) {
        skorValue = (json['skor'] as int).toDouble();
      } else if (json['skor'] is double) {
        skorValue = json['skor'] as double;
      } else if (json['skor'] is String) {
        skorValue = double.tryParse(json['skor'] as String) ?? 0.0;
      }
    }

    return AssessmentResult(
      results: resultsData
          .map((item) => AssessmentResultItem.fromJson(item))
          .toList(),
      totalSoal: json['total_soal'] is int
          ? json['total_soal'] as int
          : int.tryParse(json['total_soal']?.toString() ?? '0') ?? 0,
      jawabanBenar: json['jawaban_benar'] is int
          ? json['jawaban_benar'] as int
          : int.tryParse(json['jawaban_benar']?.toString() ?? '0') ?? 0,
      jawabanSalah: json['jawaban_salah'] is int
          ? json['jawaban_salah'] as int
          : int.tryParse(json['jawaban_salah']?.toString() ?? '0') ?? 0,
      skor: skorValue,
    );
  }
}
