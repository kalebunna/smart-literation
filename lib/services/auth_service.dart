import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:education_game_app/models/user_model.dart';
import 'package:education_game_app/utils/api_response_handler.dart';

class AuthService {
  final String baseUrl =
      'https://api.sq4rapp.com'; // Ganti dengan URL API sebenarnya

  // Headers umum untuk request
  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  // Endpoint: POST /login
  Future<User> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: _getHeaders(),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        // Simpan token jika ada
        if (data.containsKey('token')) {
          // TODO: Simpan token di secure storage
          // await secureStorage.write(key: 'token', value: data['token']);
        }

        return User.fromJson(data['user']);
      } else {
        String errorMessage;
        try {
          final Map<String, dynamic> data = json.decode(response.body);
          errorMessage = data['message'] ?? 'Failed to login';
        } catch (e) {
          errorMessage = 'Failed to login: ${response.statusCode}';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }

  // Endpoint: POST /register
  Future<void> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: _getHeaders(),
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        String errorMessage;
        try {
          final Map<String, dynamic> data = json.decode(response.body);
          errorMessage = data['message'] ?? 'Failed to register';
        } catch (e) {
          errorMessage = 'Failed to register: ${response.statusCode}';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Failed to register: $e');
    }
  }

  // Endpoint: POST /logout
  Future<void> logout() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: _getHeaders(),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to logout: ${response.statusCode}');
      }

      // Hapus token dari secure storage
      // await secureStorage.delete(key: 'token');
    } catch (e) {
      throw Exception('Failed to logout: $e');
    }
  }

  // Endpoint: POST /forgot-password
  Future<void> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/forgot-password'),
        headers: _getHeaders(),
        body: jsonEncode({
          'email': email,
        }),
      );

      if (response.statusCode != 200) {
        String errorMessage;
        try {
          final Map<String, dynamic> data = json.decode(response.body);
          errorMessage = data['message'] ?? 'Failed to send reset password';
        } catch (e) {
          errorMessage =
              'Failed to send reset password: ${response.statusCode}';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Failed to send reset password: $e');
    }
  }
}
