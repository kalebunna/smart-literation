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

  // Menggunakan API endpoint /materi/{babId}
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
        greading: material.greading,
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
          greading: nextMaterial.greading,
          isLocked: false,
          order: nextMaterial.order,
          isCompleted: nextMaterial.isCompleted,
          score: nextMaterial.score,
        );
      }

      notifyListeners();

      // Update status ke API (sementara dikomentari karena endpoint belum ada)
      // try {
      //   final apiService = ApiService();
      //   apiService.completeMaterial(materialId, score);
      // } catch (e) {
      //   print('Error updating material status: $e');
      // }
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
