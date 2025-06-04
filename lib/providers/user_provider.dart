import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  Map<String, dynamic>? _user;
  String? _token;

  Map<String, dynamic>? get user => _user;
  String? get token => _token;

  // Simpan data user dan token setelah login
  void setUserFromApi(Map<String, dynamic> userData, String token) {
    _user = userData;
    _token = token;
    notifyListeners();
  }

  // Contoh method logout
  void logout() {
    _user = null;
    _token = null;
    notifyListeners();
  }
}
