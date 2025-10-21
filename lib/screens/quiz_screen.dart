import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:education_game_app/constants/app_colors.dart';
import 'package:education_game_app/constants/app_styles.dart';
import 'package:education_game_app/providers/material_provider.dart';
import 'package:education_game_app/screens/quiz_start_screen.dart';

class QuizScreen extends StatelessWidget {
  final int materialId;

  const QuizScreen({
    Key? key,
    required this.materialId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final material = Provider.of<MaterialProvider>(context)
        .getMaterialById(materialId);

    return QuizStartScreen(
      materialId: materialId,
      materialTitle: material?.title ?? 'Quiz',
    );
  }
}
