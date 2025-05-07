// lib/utils/route_generator.dart
import 'package:flutter/material.dart';
import 'package:education_game_app/screens/chapter_list_screen.dart';
import 'package:education_game_app/screens/dashboard_screen.dart';
import 'package:education_game_app/screens/final_test_screen.dart';
import 'package:education_game_app/screens/login_screen.dart';
import 'package:education_game_app/screens/material_content_screen.dart';
import 'package:education_game_app/screens/material_list_screen.dart';
import 'package:education_game_app/screens/material_overview_screen.dart';
import 'package:education_game_app/screens/profile_screen.dart';
import 'package:education_game_app/screens/question_creation_screen.dart'; // Certifique-se de que este arquivo existe
import 'package:education_game_app/screens/quiz_screen.dart';
import 'package:education_game_app/screens/reading_material_screen.dart';
import 'package:education_game_app/screens/score_screen.dart';
import 'package:education_game_app/screens/splash_screen.dart';
import 'package:education_game_app/screens/summary_screen.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Mendapatkan argumen yang dikirimkan
    final args = settings.arguments;

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/dashboard':
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case '/chapters':
        return MaterialPageRoute(builder: (_) => const ChapterListScreen());
      case '/materials':
        if (args is int) {
          return MaterialPageRoute(
            builder: (_) => MaterialListScreen(chapterId: args),
          );
        }
        return _errorRoute();
      case '/material_overview':
        if (args is int) {
          return MaterialPageRoute(
            builder: (_) => MaterialOverviewScreen(materialId: args),
          );
        }
        return _errorRoute();
      case '/question_creation':
        if (args is int) {
          return MaterialPageRoute(
            builder: (_) => QuestionCreationScreen(materialId: args),
          );
        }
        return _errorRoute();
      case '/material_content':
        if (args is int) {
          return MaterialPageRoute(
            builder: (_) => MaterialContentScreen(materialId: args),
          );
        }
        return _errorRoute();
      case '/quiz':
        if (args is int) {
          return MaterialPageRoute(
            builder: (_) => QuizScreen(materialId: args),
          );
        }
        return _errorRoute();
      case '/summary':
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => SummaryScreen(
              materialId: args['materialId'],
              score: args['score'],
              totalQuestions: args['totalQuestions'],
            ),
          );
        }
        return _errorRoute();
      case '/final_test':
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => FinalTestScreen(
              materialId: args['materialId'],
              midtestScore: args['midtestScore'],
              totalMidtestQuestions: args['totalMidtestQuestions'],
            ),
          );
        }
        return _errorRoute();
      case '/score':
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => ScoreScreen(
              score: args['score'],
              totalScore: args['totalScore'],
              materialTitle: args['materialTitle'],
              midtestScore: args['midtestScore'],
              totalMidtestQuestions: args['totalMidtestQuestions'],
            ),
          );
        }
        return _errorRoute();
      case '/reading_materials':
        return MaterialPageRoute(builder: (_) => const ReadingMaterialScreen());
      case '/profile':
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: const Center(
          child: Text('Halaman tidak ditemukan'),
        ),
      );
    });
  }
}
