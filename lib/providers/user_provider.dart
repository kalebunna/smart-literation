import 'package:flutter/material.dart';
import 'package:education_game_app/models/user_model.dart';
import 'package:education_game_app/services/auth_service.dart';
import 'package:education_game_app/services/local_storage_service.dart';

class UserProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;

  // Inisialisasi user dari storage lokal
  Future<void> init() async {
    final userData = LocalStorageService.getObject('user');
    if (userData != null) {
      _user = User.fromJson(userData);
      notifyListeners();
    }
  }

  // Untuk implementasi dummy
  void setDummyUser() {
    _user = User(
      id: 1,
      name: 'John Doe',
      email: 'john.doe@example.com',
      profileImage: '',
    );

    // Simpan ke storage lokal
    LocalStorageService.saveObject('user', _user!.toJson());

    notifyListeners();
  }

  // Untuk implementasi API sebenarnya
  Future<void> login(String email, String password) async {
    _setLoading(true);

    try {
      final authService = AuthService();
      final user = await authService.login(email, password);

      _user = user;

      // Simpan ke storage lokal
      LocalStorageService.saveObject('user', user.toJson());

      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> register(String name, String email, String password) async {
    _setLoading(true);

    try {
      final authService = AuthService();
      await authService.register(name, email, password);

      // Login setelah registrasi
      await login(email, password);

      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> logout() async {
    _setLoading(true);

    try {
      // Implementasi API sebenarnya
      // final authService = AuthService();
      // await authService.logout();

      // Hapus data dari storage lokal
      await LocalStorageService.remove('user');

      _user = null;
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> forgotPassword(String email) async {
    _setLoading(true);

    try {
      final authService = AuthService();
      await authService.forgotPassword(email);
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
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
