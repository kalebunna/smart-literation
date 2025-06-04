// lib/providers/material_provider.dart
import 'package:flutter/material.dart';
import 'package:education_game_app/models/material_model.dart' as model;
import 'package:education_game_app/services/api_service.dart';

class MaterialProvider extends ChangeNotifier {
  List<model.Material> _materials = [];
  bool _isLoading = false;
  String? _error;

  List<model.Material> get materials => _materials;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Untuk implementasi dummy
  Future<void> loadDummyMaterials(int chapterId) async {
    _setLoading(true);

    try {
      // Simulasi delay jaringan
      await Future.delayed(const Duration(seconds: 1));

      _materials = [
        model.Material(
          id: 1,
          chapterId: chapterId,
          title: 'Mengenal Huruf Kapital',
          description:
              'Peserta didik mampu menuliskan huruf kapital dengan benar',
          type: model.MaterialType.VIDEO,
          fileUrl: 'assets/pdf/file.pdf',
          isLocked: false,
          order: 1,
          isCompleted: true,
        ),
        model.Material(
          id: 2,
          chapterId: chapterId,
          title: 'Tehnik Membaca',
          description:
              '⁠Peserta didik mampu membaca tatap/pemindaian(scanning)',
          type: model.MaterialType.PDF,
          fileUrl: 'http://berka.test/kapital.pdf',
          isLocked: false,
          order: 2,
          isCompleted: false,
        ),
        model.Material(
          id: 3,
          chapterId: chapterId,
          title: 'Menentukan Judul Penulis ',
          description: ' menentukan judul penulis ',
          type: model.MaterialType.VIDEO,
          fileUrl: 'assets/pdf/question_making.pdf',
          isLocked: true,
          order: 3,
          isCompleted: false,
        ),
      ];

      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Untuk implementasi API sebenarnya
  Future<void> getMaterialsByChapterId(int chapterId) async {
    _setLoading(true);

    try {
      final apiService = ApiService();
      final materials = await apiService.getMaterialsByChapterId(chapterId);
      _materials = materials;
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Mendapatkan materi berdasarkan ID
  model.Material? getMaterialById(int materialId) {
    try {
      return _materials.firstWhere((material) => material.id == materialId);
    } catch (e) {
      return null;
    }
  }

  // Menandai materi sebagai selesai dan membuka materi berikutnya
  void completeMaterial(int materialId, int score) {
    final index =
        _materials.indexWhere((material) => material.id == materialId);

    if (index != -1) {
      final material = _materials[index];
      _materials[index] = model.Material(
        id: material.id,
        chapterId: material.chapterId,
        title: material.title,
        description: material.description,
        type: material.type,
        fileUrl: material.fileUrl,
        isLocked: material.isLocked,
        order: material.order,
        isCompleted: true,
        score: score,
      );

      // Buka materi berikutnya jika ada
      if (index < _materials.length - 1) {
        final nextMaterial = _materials[index + 1];
        _materials[index + 1] = model.Material(
          id: nextMaterial.id,
          chapterId: nextMaterial.chapterId,
          title: nextMaterial.title,
          description: nextMaterial.description,
          type: nextMaterial.type,
          fileUrl: nextMaterial.fileUrl,
          isLocked: false,
          order: nextMaterial.order,
          isCompleted: nextMaterial.isCompleted,
          score: nextMaterial.score,
        );
      }

      notifyListeners();

      // Implementasi nyata: update status ke API
      try {
        final apiService = ApiService();
        apiService.completeMaterial(materialId, score);
      } catch (e) {
        // Penanganan error API
        print('Error updating material status: $e');
      }
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
