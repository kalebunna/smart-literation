import 'package:flutter/material.dart';
import 'package:education_game_app/models/question_model.dart';
import 'package:education_game_app/services/api_service.dart';

class QuizProvider extends ChangeNotifier {
  List<QuizQuestion> _questions = [];
  List<QuizQuestion> _finalQuestions = [];
  bool _isLoading = false;
  String? _error;

  List<QuizQuestion> get questions => _questions;
  List<QuizQuestion> get finalQuestions => _finalQuestions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Untuk implementasi dummy
  Future<void> loadDummyQuestions() async {
    _setLoading(true);

    try {
      // Simulasi delay jaringan
      await Future.delayed(const Duration(seconds: 1));

      _questions = [
        QuizQuestion(
          id: 1,
          question: 'Apa kepanjangan dari SQ4R?',
          options: [
            'Survey, Question, Read, Recite, Reflect, Review',
            'Search, Question, Read, Recall, Revise, Report',
            'Study, Question, Read, Recite, Record, Review',
            'Scan, Query, Read, Record, Reflect, Reproduce',
          ],
          correctOptionIndex: 0,
          explanation:
              'SQ4R adalah singkatan dari Survey, Question, Read, Recite, Reflect, dan Review. Metode ini dikembangkan untuk meningkatkan pemahaman dan retensi informasi.',
        ),
        QuizQuestion(
          id: 2,
          question:
              'Tahapan apa yang dilakukan pertama kali dalam metode SQ4R?',
          options: [
            'Read',
            'Question',
            'Survey',
            'Recite',
          ],
          correctOptionIndex: 2,
          explanation:
              'Tahap pertama dalam metode SQ4R adalah Survey, yaitu melihat gambaran umum materi yang akan dipelajari dengan membaca judul, subjudul, dan kesimpulan.',
        ),
        QuizQuestion(
          id: 3,
          question: 'Apa yang dilakukan pada tahap Question dalam metode SQ4R?',
          options: [
            'Menjawab pertanyaan dari materi',
            'Membuat pertanyaan tentang materi',
            'Bertanya kepada guru',
            'Menguji pemahaman teman',
          ],
          correctOptionIndex: 1,
          explanation:
              'Pada tahap Question, kita membuat pertanyaan-pertanyaan tentang materi yang akan dipelajari. Pertanyaan ini membantu memfokuskan pikiran saat membaca.',
        ),
      ];

      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> loadDummyFinalQuestions() async {
    _setLoading(true);

    try {
      // Simulasi delay jaringan
      await Future.delayed(const Duration(seconds: 1));

      _finalQuestions = [
        QuizQuestion(
          id: 1,
          question:
              'Bagaimana cara meningkatkan efektivitas tahap Survey dalam metode SQ4R?',
          options: [
            'Membaca seluruh materi secara cepat',
            'Memperhatikan gambar, grafik, dan teks yang dicetak tebal',
            'Menghafal poin-poin penting',
            'Mencatat semua informasi yang ditemukan',
          ],
          correctOptionIndex: 1,
          explanation:
              'Tahap Survey menjadi lebih efektif dengan memperhatikan elemen visual dan teks yang menonjol seperti gambar, grafik, judul, subjudul, dan teks yang dicetak tebal.',
        ),
        QuizQuestion(
          id: 2,
          question: 'Apa manfaat tahap Recite dalam metode SQ4R?',
          options: [
            'Menghafalkan materi secara kata per kata',
            'Menceritakan kembali informasi dengan kata-kata sendiri',
            'Membuat ringkasan tertulis yang lengkap',
            'Berdiskusi dengan teman tentang materi',
          ],
          correctOptionIndex: 1,
          explanation:
              'Tahap Recite bermanfaat untuk memindahkan informasi dari memori jangka pendek ke memori jangka panjang dengan menceritakan kembali informasi menggunakan kata-kata sendiri.',
        ),
        QuizQuestion(
          id: 3,
          question: 'Pada tahap Reflect, apa yang sebaiknya dilakukan?',
          options: [
            'Mengulang bacaan beberapa kali',
            'Menghubungkan informasi baru dengan pengetahuan yang sudah dimiliki',
            'Membuat pertanyaan tambahan',
            'Mengevaluasi keberhasilan belajar',
          ],
          correctOptionIndex: 1,
          explanation:
              'Pada tahap Reflect, kita menghubungkan informasi baru dengan pengetahuan yang sudah dimiliki, mencari contoh aplikasi praktis, dan memikirkan implikasi dari materi yang dipelajari.',
        ),
        QuizQuestion(
          id: 4,
          question: 'Apa perbedaan utama antara tahap Read dan Review?',
          options: [
            'Read adalah membaca cepat, Review adalah membaca lambat',
            'Read adalah membaca pertama kali, Review adalah membaca ulang',
            'Read berfokus pada detail, Review berfokus pada gambaran umum',
            'Read untuk memahami, Review untuk mengingat',
          ],
          correctOptionIndex: 3,
          explanation:
              'Read berfokus pada pemahaman materi saat pertama kali membaca, sementara Review berfokus pada mengingat dan memperkuat pemahaman dengan peninjauan berkala.',
        ),
        QuizQuestion(
          id: 5,
          question:
              'Mengapa metode SQ4R lebih efektif dibandingkan membaca biasa?',
          options: [
            'Karena membutuhkan waktu lebih sedikit',
            'Karena melibatkan proses belajar aktif',
            'Karena tidak memerlukan konsentrasi tinggi',
            'Karena lebih mudah dilakukan',
          ],
          correctOptionIndex: 1,
          explanation:
              'Metode SQ4R lebih efektif karena melibatkan proses belajar aktif, di mana pembaca terlibat dalam berbagai aktivitas kognitif seperti bertanya, mengingat, menghubungkan, dan meninjau, bukan hanya memproses informasi secara pasif.',
        ),
      ];

      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Untuk implementasi API sebenarnya
  Future<void> getQuestionsByMaterialId(int materialId) async {
    _setLoading(true);

    try {
      final apiService = ApiService();
      final questions = await apiService.getQuestionsByMaterialId(materialId);
      _questions = questions;
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> getFinalQuestionsByMaterialId(int materialId) async {
    _setLoading(true);

    try {
      final apiService = ApiService();
      final questions =
          await apiService.getFinalQuestionsByMaterialId(materialId);
      _finalQuestions = questions;
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Submit jawaban quiz
  Future<void> submitAnswer(
      int materialId, int questionId, int selectedOptionIndex) async {
    try {
      final apiService = ApiService();
      await apiService.submitQuizAnswer(
        materialId,
        questionId,
        selectedOptionIndex,
      );
    } catch (e) {
      print('Error submitting answer: $e');
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    if (loading) {
      _error = null;
    }
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    _isLoading = false;
    notifyListeners();
  }
}
