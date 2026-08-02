import 'dart:convert';
import 'package:education_game_app/models/reading_material_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:education_game_app/models/chapter_model.dart';

import 'package:education_game_app/models/material_model.dart' as model;
import 'package:education_game_app/models/question_model.dart';
import 'package:education_game_app/models/summary_model.dart';
import 'package:education_game_app/models/reflection_model.dart';
import 'package:education_game_app/models/dashboard_model.dart';
import 'package:education_game_app/models/assessment_result_model.dart';
import 'package:education_game_app/utils/api_response_handler.dart';

class ApiService {
  static const String baseUrl =
      'https://admin-smart-literation.fiks.web.id/api';
  static const String storageBaseUrl =
      'https://admin-smart-literation.fiks.web.id/storage';

  // Headers umum untuk request
  Future<Map<String, String>> _getHeaders({String? token}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Jika token tidak diberikan, ambil dari SharedPreferences
    if (token == null) {
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString('token');
    }

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
        headers: await _getHeaders(),
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

  // Endpoint: GET /list-babs (Updated untuk menggunakan endpoint yang benar)
  Future<List<Chapter>> getChapters() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/list-babs'),
        headers: await _getHeaders(),
      );

      final apiResponse = _handleResponse<Map<String, dynamic>>(response);

      if (apiResponse.success && apiResponse.data != null) {
        final data = apiResponse.data!;
        final List<dynamic> chaptersData = data['data'] ?? [];
        return chaptersData.map((json) => Chapter.fromJson(json)).toList();
      } else {
        throw Exception(apiResponse.error ?? 'Failed to load chapters');
      }
    } catch (e) {
      throw Exception('Failed to load chapters: $e');
    }
  }

  Future<List<ReadingMaterial>> getReadingMaterials() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/bahan-bacaan'),
        headers: await _getHeaders(),
      );

      final apiResponse = _handleResponse<Map<String, dynamic>>(response);

      if (apiResponse.success && apiResponse.data != null) {
        final data = apiResponse.data!;
        final List<dynamic> materialsData = data['data'] ?? [];
        return materialsData
            .map((json) => ReadingMaterial.fromJson(json))
            .toList();
      } else {
        throw Exception(
            apiResponse.error ?? 'Failed to load reading materials');
      }
    } catch (e) {
      throw Exception('Failed to load reading materials: $e');
    }
  }

  Future<List<model.Material>> getMaterialsByChapterId(int chapterId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/materi/$chapterId'),
        headers: await _getHeaders(),
      );

      final apiResponse = _handleResponse<Map<String, dynamic>>(response);

      if (apiResponse.success && apiResponse.data != null) {
        final data = apiResponse.data!;
        final List<dynamic> materialsData = data['data'] ?? [];
        return materialsData.map((json) {
          final material = model.Material.fromJson(json);
          // Set chapterId yang benar
          return model.Material(
            id: material.id,
            chapterId: chapterId,
            title: material.title,
            description: material.description,
            type: material.type,
            fileUrl: material.fileUrl,
            greading: material.greading,
            isLocked: material.isLocked,
            order: material.order,
            isCompleted: material.isCompleted,
            score: material.score,
          );
        }).toList();
      } else {
        throw Exception(apiResponse.error ?? 'Failed to load materials');
      }
    } catch (e) {
      throw Exception('Failed to load materials: $e');
    }
  }

  // Endpoint: GET /soal-greeding/{materi_id}
  Future<Map<String, dynamic>> getGreedingQuestion(int materialId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/soal-greeding/$materialId'),
        headers: await _getHeaders(),
      );

      final apiResponse = _handleResponse<Map<String, dynamic>>(response);

      if (apiResponse.success && apiResponse.data != null) {
        final data = apiResponse.data!;
        return {
          'id_soal': data['data']['id_soal'] ?? 0,
          'soal': data['data']['soal'] ?? '',
        };
      } else {
        throw Exception(apiResponse.error ?? 'Failed to load question prompt');
      }
    } catch (e) {
      throw Exception('Failed to load question prompt: $e');
    }
  }

  // Endpoint: POST /greading-assesment
  Future<Map<String, dynamic>> submitGreedingAssessment(
      int soalId, String jawabanSiswa) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/greading-assesment'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'soal_id': soalId,
          'jawaban_siswa': jawabanSiswa,
        }),
      );

      final apiResponse = _handleResponse<Map<String, dynamic>>(response);

      if (apiResponse.success && apiResponse.data != null) {
        final data = apiResponse.data!;

        // Handle raw Gemini response structure
        // The backend puts the Gemini response in 'data' or 'message'
        var geminiData = data['data'] ?? data['message'];

        String feedback = '';
        int nilai = 0;

        try {
          // Check if we have the raw Gemini structure
          if (geminiData != null &&
              geminiData is Map<String, dynamic> &&
              geminiData.containsKey('candidates') &&
              geminiData['candidates'] is List &&
              (geminiData['candidates'] as List).isNotEmpty) {
            final candidate = geminiData['candidates'][0];
            if (candidate['content'] != null &&
                candidate['content']['parts'] != null &&
                (candidate['content']['parts'] as List).isNotEmpty) {
              feedback = candidate['content']['parts'][0]['text'] ?? '';

              // Extract score using regex: "nilai pertanyaanmu adalah [angka]"
              final RegExp scoreRegex = RegExp(
                  r'nilai pertanyaanmu adalah (\d+)',
                  caseSensitive: false);
              final match = scoreRegex.firstMatch(feedback);
              if (match != null && match.groupCount >= 1) {
                nilai = int.tryParse(match.group(1)!) ?? 0;
              }
            }
          } else {
            // Fallback: check if it's the old structure or flattened
            // Sometimes parsed JSON might behave differently
            final fallbackData = data['data'] ?? data;
            feedback = fallbackData['feedback'] ?? '';
            nilai = fallbackData['nilai'] ?? 0;
          }
        } catch (e) {
          print('Error parsing Gemini response: $e');
          feedback = 'Gagal memproses respon AI. Silakan coba lagi.';
        }

        return {
          'feedback': feedback,
          'nilai': nilai,
        };
      } else {
        throw Exception(apiResponse.error ?? 'Failed to submit question');
      }
    } catch (e) {
      throw Exception('Failed to submit question: $e');
    }
  }

  // Endpoint: GET /soal-quiz/{materialId}
  Future<List<QuizQuestion>> getQuestionsByMaterialId(int materialId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/soal-quiz/$materialId'),
        headers: await _getHeaders(),
      );

      final apiResponse = _handleResponse<Map<String, dynamic>>(response);

      if (apiResponse.success && apiResponse.data != null) {
        final data = apiResponse.data!;
        final List<dynamic> questionsData = data['data'] ?? [];
        return questionsData
            .map((json) => QuizQuestion.fromJson(json))
            .toList();
      } else {
        throw Exception(apiResponse.error ?? 'Failed to load questions');
      }
    } catch (e) {
      throw Exception('Failed to load questions: $e');
    }
  }

  // Endpoint: GET /final-test/{materialId}
  Future<List<QuizQuestion>> getFinalQuestionsByMaterialId(
      int materialId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/final-test/$materialId'),
        headers: await _getHeaders(),
      );

      final apiResponse = _handleResponse<Map<String, dynamic>>(response);

      if (apiResponse.success && apiResponse.data != null) {
        final data = apiResponse.data!;
        final List<dynamic> questionsData = data['data'] ?? [];
        return questionsData
            .map((json) => QuizQuestion.fromJson(json))
            .toList();
      } else {
        throw Exception(
            apiResponse.error ?? 'Failed to load final test questions');
      }
    } catch (e) {
      throw Exception('Failed to load final test questions: $e');
    }
  }

  // Endpoint: POST /materials/{materialId}/submit-question
  Future<String> submitQuestion(int materialId, String question) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/materials/$materialId/submit-question'),
        headers: await _getHeaders(),
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
        headers: await _getHeaders(),
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
        headers: await _getHeaders(),
        body: jsonEncode({
          'score': score,
        }),
      );

      _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to complete material: $e');
    }
  }

  // Endpoint: GET /rangkuman/{materialId}
  Future<List<SummaryParagraph>> getSummaryByMaterialId(int materialId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/rangkuman/$materialId'),
        headers: await _getHeaders(),
      );

      final apiResponse = _handleResponse<Map<String, dynamic>>(response);

      if (apiResponse.success && apiResponse.data != null) {
        final data = apiResponse.data!;
        final List<dynamic> summaryData = data['data'] ?? [];
        return summaryData
            .map((json) => SummaryParagraph.fromJson(json))
            .toList();
      } else {
        throw Exception(apiResponse.error ?? 'Failed to load summary');
      }
    } catch (e) {
      throw Exception('Failed to load summary: $e');
    }
  }

  // Endpoint: POST /jawaban-user
  Future<Map<String, dynamic>> submitFinalTestAnswers(
      List<Map<String, dynamic>> jawaban, int skor, int materialId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/jawaban-user'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'jawaban': jawaban,
          'skor': skor,
          'materi_id': materialId,
        }),
      );

      final apiResponse = _handleResponse<Map<String, dynamic>>(response);

      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!;
      } else {
        throw Exception(
            apiResponse.error ?? 'Failed to submit final test answers');
      }
    } catch (e) {
      throw Exception('Failed to submit final test answers: $e');
    }
  }

  // Endpoint: GET /dashboard
  Future<DashboardData> getDashboardData() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/dashboard'),
        headers: await _getHeaders(),
      );

      final apiResponse = _handleResponse<Map<String, dynamic>>(response);

      if (apiResponse.success && apiResponse.data != null) {
        final data = apiResponse.data!;
        return DashboardData.fromJson(data['data'] ?? data);
      } else {
        throw Exception(apiResponse.error ?? 'Failed to load dashboard data');
      }
    } catch (e) {
      throw Exception('Failed to load dashboard data: $e');
    }
  }

  // Endpoint: POST /logout
  Future<Map<String, dynamic>> logout() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: await _getHeaders(),
      );

      final apiResponse = _handleResponse<Map<String, dynamic>>(response);

      if (apiResponse.success) {
        // Clear stored token
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');
        await prefs.remove('user_data');

        return apiResponse.data ?? {'message': 'Logout successful'};
      } else {
        throw Exception(apiResponse.error ?? 'Failed to logout');
      }
    } catch (e) {
      throw Exception('Failed to logout: $e');
    }
  }

  // Endpoint: GET /reflection/{materialId}
  Future<ReflectionQuestion?> getReflectionQuestion(int materialId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reflection/$materialId'),
        headers: await _getHeaders(),
      );

      final apiResponse = _handleResponse<Map<String, dynamic>>(response);

      if (apiResponse.success && apiResponse.data != null) {
        final data = apiResponse.data!;
        if (data['data'] != null) {
          return ReflectionQuestion.fromJson(data['data']);
        } else {
          return null; // No reflection question available
        }
      } else {
        throw Exception(
            apiResponse.error ?? 'Failed to load reflection question');
      }
    } catch (e) {
      throw Exception('Failed to load reflection question: $e');
    }
  }

  // Endpoint: POST /reflection
  Future<Map<String, dynamic>> submitReflection(
      int soalId, String jawaban) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reflection'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'soal_id': soalId,
          'jawaban': jawaban,
        }),
      );

      final apiResponse = _handleResponse<Map<String, dynamic>>(response);

      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!;
      } else {
        throw Exception(apiResponse.error ?? 'Failed to submit reflection');
      }
    } catch (e) {
      throw Exception('Failed to submit reflection: $e');
    }
  }

  // Endpoint: GET /assessment-sumatif
  Future<ApiResponse<Map<String, dynamic>>> getAssessmentSumatif() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/assessment-sumatif'),
        headers: await _getHeaders(),
      );

      final responseData = json.decode(response.body);

      // Handle 403 error (belum selesai semua bab)
      if (response.statusCode == 403) {
        return ApiResponse<Map<String, dynamic>>.error(
          responseData['message'] ?? 'Anda belum menyelesaikan semua bab',
        );
      }

      final apiResponse = _handleResponse<Map<String, dynamic>>(response);

      if (apiResponse.success && apiResponse.data != null) {
        final data = apiResponse.data!;
        final List<dynamic> questionsData = data['data'] ?? [];
        final questions =
            questionsData.map((json) => QuizQuestion.fromJson(json)).toList();

        return ApiResponse<Map<String, dynamic>>.success({
          'questions': questions,
          'data': responseData['data'],
        });
      } else {
        return ApiResponse<Map<String, dynamic>>.error(
          apiResponse.error ?? 'Failed to load assessment sumatif',
        );
      }
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>.error(
        'Failed to load assessment sumatif: $e',
      );
    }
  }

  // Endpoint: POST /assessment-sumatif/submit
  Future<ApiResponse<Map<String, dynamic>>> submitAssessmentSumatif(
      List<Map<String, dynamic>> jawaban) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/assessment-sumatif/submit'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'jawaban': jawaban,
        }),
      );

      final apiResponse = _handleResponse<Map<String, dynamic>>(response);

      if (apiResponse.success && apiResponse.data != null) {
        return ApiResponse<Map<String, dynamic>>.success(apiResponse.data!);
      } else {
        return ApiResponse<Map<String, dynamic>>.error(
          apiResponse.error ?? 'Failed to submit assessment sumatif',
        );
      }
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>.error(
        'Failed to submit assessment sumatif: $e',
      );
    }
  }

  // Endpoint: GET /assessment-sumatif/results
  Future<ApiResponse<AssessmentResult>> getAssessmentSumatifResults() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/assessment-sumatif/results'),
        headers: await _getHeaders(),
      );

      final responseData = json.decode(response.body);

      // Handle 404 error (belum mengerjakan assessment)
      if (response.statusCode == 404) {
        return ApiResponse<AssessmentResult>.error(
          responseData['message'] ??
              'Anda belum mengerjakan assessment sumatif',
        );
      }

      final apiResponse = _handleResponse<Map<String, dynamic>>(response);

      if (apiResponse.success && apiResponse.data != null) {
        final data = apiResponse.data!;
        // The API returns {status: true, data: {...}}, so we need to access data['data']
        final resultData = data['data'] ?? data;
        final assessmentResult = AssessmentResult.fromJson(resultData);
        return ApiResponse<AssessmentResult>.success(assessmentResult);
      } else {
        return ApiResponse<AssessmentResult>.error(
          apiResponse.error ?? 'Failed to load assessment results',
        );
      }
    } catch (e) {
      return ApiResponse<AssessmentResult>.error(
        'Failed to load assessment results: $e',
      );
    }
  }

  // Pretest Methods

  // Endpoint: GET /pretest
  Future<ApiResponse<List<QuizQuestion>>> getPretestQuestions() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/pretest'),
        headers: await _getHeaders(),
      );

      final apiResponse = _handleResponse<Map<String, dynamic>>(response);

      if (apiResponse.success && apiResponse.data != null) {
        final data = apiResponse.data!;
        final List<dynamic> questionsData = data['data'] ?? [];
        final questions =
            questionsData.map((json) => QuizQuestion.fromJson(json)).toList();

        return ApiResponse<List<QuizQuestion>>.success(questions);
      } else {
        return ApiResponse<List<QuizQuestion>>.error(
          apiResponse.error ?? 'Failed to load pretest questions',
        );
      }
    } catch (e) {
      return ApiResponse<List<QuizQuestion>>.error(
        'Failed to load pretest questions: $e',
      );
    }
  }

  // Endpoint: POST /pretest/submit
  Future<ApiResponse<Map<String, dynamic>>> submitPretestAnswers(
      List<Map<String, dynamic>> jawaban) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/pretest/submit'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'jawaban': jawaban,
        }),
      );

      final apiResponse = _handleResponse<Map<String, dynamic>>(response);

      if (apiResponse.success && apiResponse.data != null) {
        return ApiResponse<Map<String, dynamic>>.success(
            apiResponse.data!['data']);
      } else {
        return ApiResponse<Map<String, dynamic>>.error(
          apiResponse.error ?? 'Failed to submit pretest answers',
        );
      }
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>.error(
        'Failed to submit pretest answers: $e',
      );
    }
  }

  // Endpoint: GET /pretest/results
  Future<ApiResponse<AssessmentResult>> getPretestResults() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/pretest/results'),
        headers: await _getHeaders(),
      );

      final responseData = json.decode(response.body);

      // Handle 404 error
      if (response.statusCode == 404) {
        return ApiResponse<AssessmentResult>.error(
          responseData['message'] ?? 'Anda belum mengerjakan pretest',
        );
      }

      final apiResponse = _handleResponse<Map<String, dynamic>>(response);

      if (apiResponse.success && apiResponse.data != null) {
        final data = apiResponse.data!;
        final resultData = data['data'] ?? data;
        final assessmentResult = AssessmentResult.fromJson(resultData);
        return ApiResponse<AssessmentResult>.success(assessmentResult);
      } else {
        return ApiResponse<AssessmentResult>.error(
          apiResponse.error ?? 'Failed to load pretest results',
        );
      }
    } catch (e) {
      return ApiResponse<AssessmentResult>.error(
        'Failed to load pretest results: $e',
      );
    }
  }

  // Penanganan respons API
  ApiResponse<T> _handleResponse<T>(http.Response response) {
    try {
      final dynamic responseData = json.decode(response.body);

      // Cek apakah backend mengembalikan field 'status'
      if (responseData is Map<String, dynamic> &&
          responseData.containsKey('status')) {
        if (responseData['status'] == true) {
          return ApiResponse<T>.success(responseData as T);
        } else {
          // Backend mengembalikan status: false
          String errorMessage = responseData['message'] ??
              responseData['error'] ??
              'Unknown error occurred';
          return ApiResponse<T>.error(errorMessage);
        }
      }

      // Fallback untuk response tanpa field 'status'
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
