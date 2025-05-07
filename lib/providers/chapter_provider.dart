import 'package:flutter/material.dart';
import 'package:education_game_app/models/chapter_model.dart';
import 'package:education_game_app/services/api_service.dart';

class ChapterProvider extends ChangeNotifier {
  List<Chapter> _chapters = [];
  bool _isLoading = false;
  String? _error;

  List<Chapter> get chapters => _chapters;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Untuk implementasi dummy
  Future<void> loadDummyChapters() async {
    _setLoading(true);

    try {
      // Simulasi delay jaringan
      await Future.delayed(const Duration(seconds: 1));

      _chapters = [
        Chapter(
          id: 1,
          title: 'BAB VI, Cinta Indonesia',
          description: '',
          isLocked: false,
          order: 1,
        ),
        Chapter(
          id: 2,
          title: 'BAB VII, Sayangi Bumi',
          description: '',
          isLocked: false,
          order: 2,
        ),
        Chapter(
          id: 3,
          title: 'BAB VIII, Bergerak Bersama',
          description: '',
          isLocked: true,
          order: 3,
        )
      ];

      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Untuk implementasi API sebenarnya
  Future<void> getChapters() async {
    _setLoading(true);

    try {
      final apiService = ApiService();
      final chapters = await apiService.getChapters();
      _chapters = chapters;
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Mendapatkan chapter berdasarkan ID
  Chapter? getChapterById(int id) {
    try {
      return _chapters.firstWhere((chapter) => chapter.id == id);
    } catch (e) {
      return null;
    }
  }

  // Membuka chapter berikutnya
  void unlockNextChapter(int currentChapterId) {
    final currentIndex =
        _chapters.indexWhere((chapter) => chapter.id == currentChapterId);

    if (currentIndex != -1 && currentIndex < _chapters.length - 1) {
      final nextChapter = _chapters[currentIndex + 1];
      _chapters[currentIndex + 1] = Chapter(
        id: nextChapter.id,
        title: nextChapter.title,
        description: nextChapter.description,
        isLocked: false,
        order: nextChapter.order,
      );

      notifyListeners();
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
