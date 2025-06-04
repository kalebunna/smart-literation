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

  // Menggunakan API endpoint /list-babs
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
        name: nextChapter.name,
        description: nextChapter.description,
        isDone: nextChapter.isDone,
        isUnlocked: true, // Unlock chapter berikutnya
      );

      notifyListeners();
    }
  }

  // Menandai chapter sebagai selesai
  void markChapterComplete(int chapterId) {
    final index = _chapters.indexWhere((chapter) => chapter.id == chapterId);

    if (index != -1) {
      final chapter = _chapters[index];
      _chapters[index] = Chapter(
        id: chapter.id,
        name: chapter.name,
        description: chapter.description,
        isDone: true,
        isUnlocked: chapter.isUnlocked,
      );

      // Unlock chapter berikutnya
      unlockNextChapter(chapterId);
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
