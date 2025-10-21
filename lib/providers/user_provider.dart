import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UserProvider with ChangeNotifier {
  Map<String, dynamic>? _user;
  String? _token;
  bool _isInitialized = false;

  Map<String, dynamic>? get user => _user;
  String? get token => _token;
  bool get isLoggedIn => _token != null && _user != null;
  bool get isInitialized => _isInitialized;

  // Initialize provider by loading saved data
  Future<void> initializeFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('token');
      final userDataString = prefs.getString('user_data');
      
      if (userDataString != null) {
        _user = json.decode(userDataString);
      }
      
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      print('Error loading user data from storage: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }

  // Simpan data user dan token setelah login
  Future<void> setUserFromApi(Map<String, dynamic> userData, String token) async {
    try {
      _user = userData;
      _token = token;
      
      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setString('user_data', json.encode(userData));
      
      notifyListeners();
    } catch (e) {
      print('Error saving user data: $e');
    }
  }

  // Logout - clear all data
  Future<void> logout() async {
    try {
      _user = null;
      _token = null;
      
      // Clear from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('user_data');
      
      notifyListeners();
    } catch (e) {
      print('Error during logout: $e');
    }
  }
}
