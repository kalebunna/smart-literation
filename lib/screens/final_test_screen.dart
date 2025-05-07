import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:education_game_app/constants/app_colors.dart';
import 'package:education_game_app/constants/app_styles.dart';
import 'package:education_game_app/models/question_model.dart';
import 'package:education_game_app/providers/material_provider.dart';
import 'package:education_game_app/providers/quiz_provider.dart';
import 'package:education_game_app/screens/score_screen.dart';
import 'package:education_game_app/widgets/custom_button.dart';
import 'package:education_game_app/widgets/quiz_option.dart';

class FinalTestScreen extends StatefulWidget {
  final int materialId;
  final int midtestScore;
  final int totalMidtestQuestions;

  const FinalTestScreen({
    Key? key,
    required this.materialId,
    required this.midtestScore,
    required this.totalMidtestQuestions,
  }) : super(key: key);

  @override
  _FinalTestScreenState createState() => _FinalTestScreenState();
}

class _FinalTestScreenState extends State<FinalTestScreen> {
  bool _isLoading = true;
  List<QuizQuestion> _questions = [];
  int _currentQuestionIndex = 0;
  int? _selectedOptionIndex;
  bool _hasAnswered = false;
  int _correctAnswers = 0;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Untuk implementasi dummy
      await Provider.of<QuizProvider>(context, listen: false)
          .loadDummyFinalQuestions();

      // Untuk implementasi API sebenarnya
      // await Provider.of<QuizProvider>(context, listen: false).getFinalQuestionsByMaterialId(widget.materialId);

      setState(() {
        _questions =
            Provider.of<QuizProvider>(context, listen: false).finalQuestions;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _checkAnswer() {
    if (_selectedOptionIndex == null) {
      return;
    }

    final question = _questions[_currentQuestionIndex];
    final isCorrect = _selectedOptionIndex == question.correctOptionIndex;

    setState(() {
      _hasAnswered = true;
      if (isCorrect) {
        _correctAnswers++;
      }
    });

    // Submit jawaban ke API (untuk implementasi sebenarnya)
    try {
      Provider.of<QuizProvider>(context, listen: false).submitAnswer(
        widget.materialId,
        question.id,
        _selectedOptionIndex!,
      );
    } catch (e) {
      print('Error submitting answer: $e');
    }
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedOptionIndex = null;
        _hasAnswered = false;
      });
    } else {
      // Final test selesai, navigasi ke score screen
      final totalScore = _correctAnswers;

      // Perbarui status materi menjadi completed
      Provider.of<MaterialProvider>(context, listen: false)
          .completeMaterial(widget.materialId, totalScore);

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => ScoreScreen(
            score: totalScore,
            totalScore: _questions.length,
            materialTitle: Provider.of<MaterialProvider>(context, listen: false)
                    .getMaterialById(widget.materialId)
                    ?.title ??
                'Materi',
            midtestScore: widget.midtestScore,
            totalMidtestQuestions: widget.totalMidtestQuestions,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final material = Provider.of<MaterialProvider>(context)
        .getMaterialById(widget.materialId);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Final Test ${material?.title ?? ''}'),
        backgroundColor: AppColors.primary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _questions.isEmpty
              ? const Center(child: Text('Tidak ada pertanyaan tersedia'))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Progress bar
                      Container(
                        width: double.infinity,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor:
                              (_currentQuestionIndex + 1) / _questions.length,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Indikator progres
                      Text(
                        'Pertanyaan ${_currentQuestionIndex + 1} dari ${_questions.length}',
                        style: AppStyles.bodySmall,
                      ),
                      const SizedBox(height: 24),

                      // Kartu pertanyaan
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Pertanyaan
                              Text(
                                _questions[_currentQuestionIndex].question,
                                style: AppStyles.heading3,
                              ),
                              const SizedBox(height: 24),

                              // Pilihan jawaban
                              Expanded(
                                child: ListView.builder(
                                  itemCount: _questions[_currentQuestionIndex]
                                      .options
                                      .length,
                                  itemBuilder: (context, index) {
                                    return QuizOption(
                                      option: _questions[_currentQuestionIndex]
                                          .options[index],
                                      index: index,
                                      isSelected: _selectedOptionIndex == index,
                                      isCorrect: _hasAnswered &&
                                          index ==
                                              _questions[_currentQuestionIndex]
                                                  .correctOptionIndex,
                                      isWrong: _hasAnswered &&
                                          _selectedOptionIndex == index &&
                                          index !=
                                              _questions[_currentQuestionIndex]
                                                  .correctOptionIndex,
                                      onTap: _hasAnswered
                                          ? null
                                          : () {
                                              setState(() {
                                                _selectedOptionIndex = index;
                                              });
                                            },
                                    );
                                  },
                                ),
                              ),

                              // Penjelasan jawaban jika sudah menjawab
                              if (_hasAnswered &&
                                  _questions[_currentQuestionIndex]
                                          .explanation !=
                                      null)
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Penjelasan:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _questions[_currentQuestionIndex]
                                            .explanation!,
                                        style: AppStyles.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),

                              const SizedBox(height: 16),

                              // Tombol cek jawaban atau lanjut
                              if (!_hasAnswered)
                                CustomButton(
                                  text: 'Cek Jawaban',
                                  onPressed: _selectedOptionIndex == null
                                      ? null
                                      : _checkAnswer,
                                )
                              else
                                CustomButton(
                                  text: _currentQuestionIndex <
                                          _questions.length - 1
                                      ? 'Pertanyaan Berikutnya'
                                      : 'Lihat Hasil',
                                  onPressed: _nextQuestion,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
