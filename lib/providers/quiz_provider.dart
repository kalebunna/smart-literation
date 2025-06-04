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
          question:
              'Manakah penulisan huruf kapital yang benar sesuai kaidah bahasa Indonesia?',
          options: [
            'Saya bertemu dengan Presiden Jokowi di acara itu.',
            'Saya bertemu dengan presiden Jokowi di acara itu.',
            'Saya bertemu dengan Presiden jokowi di acara itu.',
            'Saya bertemu dengan presiden jokowi di acara itu.',
          ],
          correctOptionIndex: 0,
          explanation:
              'Huruf kapital digunakan untuk nama jabatan atau gelar yang diikuti nama orang, seperti "Presiden Jokowi".',
        ),
        QuizQuestion(
          id: 2,
          question:
              'Huruf kapital digunakan pada awal kata untuk hal berikut, KECUALI:',
          options: [
            'Nama orang',
            'Awal kalimat',
            'Kata tugas seperti "dan", "atau", "dari"',
            'Nama tempat',
          ],
          correctOptionIndex: 2,
          explanation:
              'Kata tugas seperti "dan", "atau", dan "dari" tidak ditulis dengan huruf kapital kecuali berada di awal kalimat.',
        ),
        QuizQuestion(
          id: 3,
          question:
              'Kalimat manakah yang menggunakan huruf kapital secara salah?',
          options: [
            'Dia berasal dari Kota Surabaya.',
            'Besok saya akan ke kantor Gubernur Jawa Barat.',
            'Aku tinggal di jalan Melati nomor dua.',
            'Kami akan berkunjung ke Museum Nasional.',
          ],
          correctOptionIndex: 2,
          explanation:
              'Kata "jalan" dalam nama jalan seperti "Jalan Melati" seharusnya diawali huruf kapital. Penulisan yang benar adalah "Jalan Melati".',
        ),
        QuizQuestion(
          id: 4,
          question:
              'Manakah yang merupakan penggunaan huruf kapital yang tepat dalam penulisan judul buku?',
          options: [
            'Belajar menulis dengan baik dan benar',
            'Belajar Menulis Dengan Baik dan Benar',
            'Belajar Menulis dengan Baik Dan Benar',
            'belajar Menulis Dengan Baik dan Benar',
          ],
          correctOptionIndex: 1,
          explanation:
              'Dalam penulisan judul, setiap kata penting diawali huruf kapital kecuali kata hubung seperti "dan", "dengan", "di", kecuali di awal.',
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
              'Manakah penulisan huruf kapital yang benar sesuai kaidah bahasa Indonesia?',
          options: [
            'Saya bertemu dengan Presiden Jokowi di acara itu.',
            'Saya bertemu dengan presiden Jokowi di acara itu.',
            'Saya bertemu dengan Presiden jokowi di acara itu.',
            'Saya bertemu dengan presiden jokowi di acara itu.',
          ],
          correctOptionIndex: 0,
          explanation:
              'Huruf kapital digunakan untuk nama jabatan yang diikuti nama orang, seperti "Presiden Jokowi".',
        ),
        QuizQuestion(
          id: 2,
          question:
              'Huruf kapital digunakan pada awal kata untuk hal berikut, KECUALI:',
          options: [
            'Nama orang',
            'Awal kalimat',
            'Kata tugas seperti "dan", "atau", "dari"',
            'Nama tempat',
          ],
          correctOptionIndex: 2,
          explanation:
              'Kata tugas seperti "dan", "atau", dan "dari" tidak ditulis dengan huruf kapital kecuali berada di awal kalimat.',
        ),
        QuizQuestion(
          id: 3,
          question:
              'Kalimat manakah yang menggunakan huruf kapital secara salah?',
          options: [
            'Dia berasal dari Kota Surabaya.',
            'Besok saya akan ke kantor Gubernur Jawa Barat.',
            'Aku tinggal di jalan Melati nomor dua.',
            'Kami akan berkunjung ke Museum Nasional.',
          ],
          correctOptionIndex: 2,
          explanation:
              'Penulisan "jalan" seharusnya "Jalan" karena bagian dari nama jalan resmi.',
        ),
        QuizQuestion(
          id: 4,
          question:
              'Manakah yang merupakan penggunaan huruf kapital yang tepat dalam penulisan judul buku?',
          options: [
            'Belajar menulis dengan baik dan benar',
            'Belajar Menulis Dengan Baik dan Benar',
            'Belajar Menulis dengan Baik Dan Benar',
            'belajar Menulis Dengan Baik dan Benar',
          ],
          correctOptionIndex: 1,
          explanation:
              'Setiap kata penting dalam judul diawali huruf kapital, kecuali kata hubung seperti "dan", "dengan" (kecuali di awal).',
        ),
        QuizQuestion(
          id: 5,
          question:
              'Manakah kalimat berikut yang menggunakan huruf kapital dengan benar?',
          options: [
            'ibu pergi ke pasar bersama tante lina.',
            'Kami akan mengunjungi Taman Mini indonesia Indah.',
            'Pada hari Minggu, Andi dan Budi bermain bola di Lapangan.',
            'Setiap hari Jumat, kami membersihkan lingkungan sekolah.',
          ],
          correctOptionIndex: 4 - 1,
          explanation:
              'Huruf kapital digunakan pada nama hari dan awal kalimat. "Lapangan" tidak perlu kapital jika bukan nama khusus.',
        ),
        QuizQuestion(
          id: 6,
          question:
              'Huruf kapital digunakan dalam penulisan berikut ini, KECUALI:',
          options: [
            'Awal kalimat',
            'Nama suku bangsa',
            'Kata ganti orang kedua',
            'Nama bulan',
          ],
          correctOptionIndex: 2,
          explanation:
              'Kata ganti orang kedua seperti "kamu", "engkau" tidak perlu kapital kecuali dalam surat resmi.',
        ),
        QuizQuestion(
          id: 7,
          question:
              'Penulisan manakah yang tepat sesuai dengan aturan huruf kapital?',
          options: [
            'Kami akan berkunjung ke Rumah Sakit umum daerah.',
            'Mereka berasal dari suku batak dan suku jawa.',
            'Kakak saya kuliah di Universitas Indonesia.',
            'Hari raya idul fitri dirayakan umat Islam.',
          ],
          correctOptionIndex: 2,
          explanation:
              '"Universitas Indonesia" adalah nama lembaga, sehingga ditulis kapital di setiap katanya.',
        ),
        QuizQuestion(
          id: 8,
          question:
              'Dalam kalimat "Saya dan Ibu pergi ke pasar", penggunaan huruf kapital pada kata "Ibu" menunjukkan:',
          options: [
            'Nama orang',
            'Panggilan hormat kepada orang tua',
            'Kata benda biasa',
            'Nama jabatan',
          ],
          correctOptionIndex: 1,
          explanation:
              '"Ibu" ditulis kapital karena digunakan sebagai sapaan atau panggilan hormat.',
        ),
        QuizQuestion(
          id: 9,
          question:
              'Penulisan huruf kapital yang benar untuk nama acara berikut adalah:',
          options: [
            'Festival seni budaya nasional',
            'Festival Seni Budaya Nasional',
            'festival Seni Budaya Nasional',
            'Festival seni budaya Nasional',
          ],
          correctOptionIndex: 1,
          explanation:
              'Nama acara resmi ditulis dengan huruf kapital di setiap kata penting.',
        ),
        QuizQuestion(
          id: 10,
          question:
              'Manakah penulisan alamat yang benar menurut kaidah kapitalisasi?',
          options: [
            'jalan melati no. 14, surabaya',
            'Jalan melati No. 14, Surabaya',
            'Jalan Melati No. 14, Surabaya',
            'Jalan Melati no. 14, surabaya',
          ],
          correctOptionIndex: 2,
          explanation:
              'Nama jalan dan kota harus diawali huruf kapital. "No." sebagai singkatan tetap kapital.',
        ),
        QuizQuestion(
          id: 11,
          question:
              'Huruf kapital digunakan untuk menuliskan nama-nama berikut, KECUALI:',
          options: [
            'Nama bulan',
            'Nama kitab suci',
            'Nama hewan umum',
            'Nama negara',
          ],
          correctOptionIndex: 2,
          explanation:
              'Nama hewan umum seperti "kucing", "sapi" tidak ditulis kapital karena bukan nama khusus.',
        ),
        QuizQuestion(
          id: 12,
          question: 'Manakah penulisan gelar yang benar?',
          options: [
            'dr. Budi Santoso',
            'DR. Budi Santoso',
            'Dr. Budi Santoso',
            'dr Budi Santoso',
          ],
          correctOptionIndex: 2,
          explanation:
              'Gelar seperti "Dr." ditulis dengan huruf kapital dan diakhiri titik.',
        ),
        QuizQuestion(
          id: 13,
          question:
              'Dalam penulisan "Hari Kemerdekaan Republik Indonesia", huruf kapital digunakan karena:',
          options: [
            'Kalimat seremonial',
            'Nama dokumen resmi',
            'Nama peristiwa nasional',
            'Kalimat perintah',
          ],
          correctOptionIndex: 2,
          explanation:
              'Nama peristiwa nasional atau sejarah ditulis dengan huruf kapital di setiap kata penting.',
        ),
        QuizQuestion(
          id: 14,
          question:
              'Manakah contoh penulisan nama agama dan kitab suci yang benar?',
          options: [
            'agama islam dan al-qur’an',
            'Agama Islam dan Al-Qur’an',
            'Agama islam dan Al-Qur’an',
            'agama Islam dan al-Qur’an',
          ],
          correctOptionIndex: 1,
          explanation:
              'Nama agama dan kitab suci ditulis dengan huruf kapital, seperti "Islam" dan "Al-Qur’an".',
        ),
        QuizQuestion(
          id: 15,
          question:
              'Dalam penulisan surat resmi, sapaan seperti "Saudara" atau "Anda" ditulis kapital karena:',
          options: [
            'Terdapat di tengah kalimat',
            'Sebagai bentuk penghormatan',
            'Bagian dari salam penutup',
            'Nama umum',
          ],
          correctOptionIndex: 1,
          explanation:
              'Dalam surat resmi, sapaan seperti "Anda" ditulis kapital sebagai bentuk penghormatan.',
        ),
        QuizQuestion(
          id: 16,
          question:
              'Manakah penulisan hari dan tanggal yang tepat menurut EYD?',
          options: [
            'senin, 10 april 2023',
            'Senin, 10 April 2023',
            'Senin, 10 april 2023',
            'senin, 10 April 2023',
          ],
          correctOptionIndex: 1,
          explanation:
              'Nama hari dan bulan ditulis dengan huruf kapital, seperti "Senin, 10 April 2023".',
        ),
        QuizQuestion(
          id: 17,
          question:
              'Kalimat manakah yang salah dalam penggunaan huruf kapital?',
          options: [
            'Saya tinggal di Kabupaten Gresik.',
            'Kita akan bertemu dengan Menteri Pendidikan.',
            'Adik saya belajar di smp negeri 1.',
            'Kami akan pergi ke Gedung Kesenian Jakarta.',
          ],
          correctOptionIndex: 2,
          explanation:
              'Penulisan "smp negeri 1" salah, seharusnya "SMP Negeri 1" karena nama lembaga.',
        ),
        QuizQuestion(
          id: 18,
          question:
              'Huruf kapital digunakan dalam penulisan nama dokumen resmi berikut, KECUALI:',
          options: [
            'Undang-Undang Dasar Negara Republik Indonesia',
            'Kartu Tanda Penduduk',
            'akta kelahiran',
            'Surat Izin Mengemudi',
          ],
          correctOptionIndex: 2,
          explanation:
              'Nama dokumen resmi seperti "Akta Kelahiran" seharusnya ditulis dengan huruf kapital di awal setiap kata penting.',
        ),
        QuizQuestion(
          id: 19,
          question:
              'Dalam penulisan "Sang Merah Putih berkibar gagah", huruf kapital digunakan pada:',
          options: [
            'Sang',
            'Merah',
            'Putih',
            'Semua benar',
          ],
          correctOptionIndex: 3,
          explanation:
              '"Sang Merah Putih" merupakan julukan bagi bendera negara, sehingga ditulis dengan huruf kapital.',
        ),
        QuizQuestion(
          id: 20,
          question: 'Kalimat dengan penulisan huruf kapital yang salah adalah:',
          options: [
            'Ia membaca kitab Injil di gereja.',
            'Kami sedang belajar Bahasa Indonesia.',
            'Mereka menonton film di Bioskop Grand City.',
            'Dia berasal dari Provinsi Kalimantan Barat.',
          ],
          correctOptionIndex: 1,
          explanation:
              '"Bahasa Indonesia" benar, tapi dalam konteks umum "bahasa Indonesia" lebih tepat. Kata "bahasa" bukan nama diri.',
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
