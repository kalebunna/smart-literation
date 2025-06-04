import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:education_game_app/models/chapter_model.dart';
import 'package:education_game_app/models/material_model.dart';
import 'package:education_game_app/models/question_model.dart';
import 'package:education_game_app/models/user_model.dart';
import 'package:education_game_app/utils/api_response_handler.dart';

class ApiService {
  final String baseUrl =
      'http://127.0.0.1:8000/api'; // Ganti dengan URL API sebenarnya

  // Headers umum untuk request
  Map<String, String> _getHeaders({String? token}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // Endpoint: POST /login
  Future<ApiResponse<Map<String, dynamic>>> login(
      String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: _getHeaders(),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      return _handleResponse<Map<String, dynamic>>(response);
    } catch (e) {
      return ApiResponse.error('Failed to login: $e');
    }
  }

  // Endpoint: GET /chapters
  Future<List<Chapter>> getChapters() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/chapters'),
        headers: _getHeaders(),
      );

      final apiResponse = _handleResponse<List<dynamic>>(response);
      return apiResponse.data!.map((json) => Chapter.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load chapters: $e');
    }
  }

  // Endpoint: GET /chapters/{chapterId}/materials
  Future<List<Material>> getMaterialsByChapterId(int chapterId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/chapters/$chapterId/materials'),
        headers: _getHeaders(),
      );

      final apiResponse = _handleResponse<List<dynamic>>(response);
      return apiResponse.data!.map((json) => Material.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load materials: $e');
    }
  }

  // Endpoint: GET /materials/{materialId}/questions
  Future<List<QuizQuestion>> getQuestionsByMaterialId(int materialId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/materials/$materialId/questions'),
        headers: _getHeaders(),
      );

      final apiResponse = _handleResponse<List<dynamic>>(response);
      return apiResponse.data!
          .map((json) => QuizQuestion.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load questions: $e');
    }
  }

  // Endpoint: GET /materials/{materialId}/final-questions
  Future<List<QuizQuestion>> getFinalQuestionsByMaterialId(
      int materialId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/materials/$materialId/final-questions'),
        headers: _getHeaders(),
      );

      final apiResponse = _handleResponse<List<dynamic>>(response);
      return apiResponse.data!
          .map((json) => QuizQuestion.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load final questions: $e');
    }
  }

  // Endpoint: POST /materials/{materialId}/submit-question
  Future<String> submitQuestion(int materialId, String question) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/materials/$materialId/submit-question'),
        headers: _getHeaders(),
        body: jsonEncode({
          'question': question,
        }),
      );

      final apiResponse = _handleResponse<Map<String, dynamic>>(response);
      return apiResponse.data!['response'] as String;
    } catch (e) {
      throw Exception('Failed to submit question: $e');
    }
  }

  // Endpoint: POST /materials/{materialId}/questions/{questionId}/submit
  Future<void> submitQuizAnswer(
      int materialId, int questionId, int selectedOptionIndex) async {
    try {
      final response = await http.post(
        Uri.parse(
            '$baseUrl/materials/$materialId/questions/$questionId/submit'),
        headers: _getHeaders(),
        body: jsonEncode({
          'selected_option_index': selectedOptionIndex,
        }),
      );

      _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to submit answer: $e');
    }
  }

  // Endpoint: POST /materials/{materialId}/complete
  Future<void> completeMaterial(int materialId, int score) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/materials/$materialId/complete'),
        headers: _getHeaders(),
        body: jsonEncode({
          'score': score,
        }),
      );

      _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to complete material: $e');
    }
  }

  // Penanganan respons API
  ApiResponse<T> _handleResponse<T>(http.Response response) {
    try {
      final dynamic responseData = json.decode(response.body);

      // Cek apakah backend mengembalikan field 'success'
      if (responseData is Map<String, dynamic> &&
          responseData.containsKey('success')) {
        if (responseData['success'] == true) {
          return ApiResponse<T>.success(responseData as T);
        } else {
          // Backend mengembalikan success: false
          String errorMessage = responseData['message'] ??
              responseData['error'] ??
              'Unknown error occurred';
          return ApiResponse<T>.error(errorMessage);
        }
      }

      // Fallback untuk response tanpa field 'success'
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse<T>.success(responseData as T);
      } else {
        String errorMessage =
            responseData['message'] ?? 'Unknown error occurred';
        return ApiResponse<T>.error(errorMessage);
      }
    } catch (e) {
      return ApiResponse<T>.error(
          'Error processing response: ${response.statusCode}');
    }
  }
}
