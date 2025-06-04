import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:education_game_app/providers/user_provider.dart';
import 'package:education_game_app/providers/chapter_provider.dart';
import 'package:education_game_app/providers/material_provider.dart';
import 'package:education_game_app/providers/quiz_provider.dart';
import 'package:education_game_app/screens/splash_screen.dart';
import 'package:education_game_app/utils/route_generator.dart';

Future<void> main() async {
  // WAJIB untuk memastikan binding terpasang sebelum async/await
  WidgetsFlutterBinding.ensureInitialized();

  // Muat variabel lingkungan dari .env
  // await dotenv.load();

  // Jalankan aplikasi
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ChapterProvider()),
        ChangeNotifierProvider(create: (_) => MaterialProvider()),
        ChangeNotifierProvider(create: (_) => QuizProvider()),
      ],
      child: MaterialApp(
        title: 'SQ4R Learning App',
        theme: ThemeData(
          primarySwatch: Colors.purple,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          fontFamily: 'Poppins',
        ),
        home: const SplashScreen(),
        onGenerateRoute: RouteGenerator.generateRoute,
      ),
    );
  }
}
