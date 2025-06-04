// lib/screens/question_creation_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:education_game_app/constants/app_colors.dart';
import 'package:education_game_app/constants/app_styles.dart';
import 'package:education_game_app/providers/material_provider.dart';
import 'package:education_game_app/screens/material_content_screen.dart';
import 'package:education_game_app/widgets/custom_button.dart';

class QuestionCreationScreen extends StatefulWidget {
  final int materialId;

  const QuestionCreationScreen({
    Key? key,
    required this.materialId,
  }) : super(key: key);

  @override
  _QuestionCreationScreenState createState() => _QuestionCreationScreenState();
}

class _QuestionCreationScreenState extends State<QuestionCreationScreen> {
  final _questionController = TextEditingController();
  String _response = '';
  bool _isSubmitting = false;
  bool _hasSubmitted = false;

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  Future<void> _submitQuestion() async {
    if (_questionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pertanyaan tidak boleh kosong')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Simulasi pemanggilan API untuk mendapatkan jawaban
      await Future.delayed(const Duration(seconds: 2));

      // Contoh respons dummy
      setState(() {
        _response = '';
        _hasSubmitted = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final material = Provider.of<MaterialProvider>(context)
        .getMaterialById(widget.materialId);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(material?.title ?? 'Buat Pertanyaan'),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan instruksi
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.help_outline,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Question',
                        style: AppStyles.heading3,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Buatlah pertanyaan tentang materi yang baru saja Anda baca. '
                    'Hal ini akan membantu Anda memahami materi dengan lebih baik.',
                    style: AppStyles.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Form pertanyaan
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pertanyaan Anda:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _questionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Contoh: Apa itu metode SQ4R?',
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: 'Submit Pertanyaan',
                    isLoading: _isSubmitting,
                    onPressed: _submitQuestion,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Jawaban
            if (_hasSubmitted)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Jawaban:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _response,
                      style: AppStyles.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: 'Lanjutkan ke Materi',
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => MaterialContentScreen(
                              materialId: widget.materialId,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
