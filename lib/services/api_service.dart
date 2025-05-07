import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:education_game_app/models/chapter_model.dart';
import 'package:education_game_app/models/material_model.dart';
import 'package:education_game_app/models/question_model.dart';
import 'package:education_game_app/utils/api_response_handler.dart';

class ApiService {
  final String baseUrl =
      'https://api.sq4rapp.com'; // Ganti dengan URL API sebenarnya

  // Headers umum untuk request
  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      // Tambahkan header otentikasi jika diperlukan
      // 'Authorization': 'Bearer $token',
    };
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
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final dynamic responseData = json.decode(response.body);
      return ApiResponse<T>.success(responseData as T);
    } else {
      String errorMessage;
      try {
        final dynamic responseData = json.decode(response.body);
        errorMessage = responseData['message'] ?? 'Unknown error occurred';
      } catch (e) {
        errorMessage = 'Error processing response: ${response.statusCode}';
      }
      throw Exception(errorMessage);
    }
  }
}
