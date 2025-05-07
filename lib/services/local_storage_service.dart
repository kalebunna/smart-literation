import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static SharedPreferences? _preferences;

  // Inisialisasi shared preferences
  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  // Menyimpan string
  static Future<void> saveString(String key, String value) async {
    if (_preferences == null) {
      await init();
    }
    await _preferences!.setString(key, value);
  }

  // Mendapatkan string
  static String? getString(String key) {
    if (_preferences == null) {
      return null;
    }
    return _preferences!.getString(key);
  }

  // Menyimpan objek (dikonversi ke JSON string)
  static Future<void> saveObject(String key, Map<String, dynamic> value) async {
    if (_preferences == null) {
      await init();
    }
    await _preferences!.setString(key, json.encode(value));
  }

  // Mendapatkan objek (dari JSON string)
  static Map<String, dynamic>? getObject(String key) {
    if (_preferences == null) {
      return null;
    }
    final String? data = _preferences!.getString(key);
    if (data == null) {
      return null;
    }
    try {
      return json.decode(data) as Map<String, dynamic>;
    } catch (e) {
      print('Error decoding JSON: $e');
      return null;
    }
  }

  // Menghapus data berdasarkan key
  static Future<void> remove(String key) async {
    if (_preferences == null) {
      await init();
    }
    await _preferences!.remove(key);
  }

  // Menghapus semua data
  static Future<void> clear() async {
    if (_preferences == null) {
      await init();
    }
    await _preferences!.clear();
  }

  // Menyimpan boolean
  static Future<void> saveBool(String key, bool value) async {
    if (_preferences == null) {
      await init();
    }
    await _preferences!.setBool(key, value);
  }

  // Mendapatkan boolean
  static bool? getBool(String key) {
    if (_preferences == null) {
      return null;
    }
    return _preferences!.getBool(key);
  }

  // Menyimpan integer
  static Future<void> saveInt(String key, int value) async {
    if (_preferences == null) {
      await init();
    }
    await _preferences!.setInt(key, value);
  }

  // Mendapatkan integer
  static int? getInt(String key) {
    if (_preferences == null) {
      return null;
    }
    return _preferences!.getInt(key);
  }
}
