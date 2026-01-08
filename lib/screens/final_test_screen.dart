import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:education_game_app/constants/app_colors.dart';
import 'package:education_game_app/models/question_model.dart';
import 'package:education_game_app/providers/quiz_provider.dart';
import 'package:education_game_app/services/api_service.dart';
import 'package:education_game_app/widgets/custom_button.dart';
import 'package:education_game_app/screens/reflection_screen.dart';

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

class _FinalTestScreenState extends State<FinalTestScreen>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  bool _showConfirmation = true;
  List<QuizQuestion> _questions = [];
  int _currentQuestionIndex = 0;
  Map<int, int?> _answers = {}; // questionIndex -> selectedOptionIndex
  Timer? _timer;
  int _elapsedSeconds = 0;
  late AnimationController _backgroundController;
  late AnimationController _cardController;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _cardAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    if (!_showConfirmation) {
      _loadQuestions();
    }
  }

  void _initializeAnimations() {
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _cardController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_backgroundController);

    _cardAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _backgroundController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = ApiService();
      final questions =
          await apiService.getFinalQuestionsByMaterialId(widget.materialId);

      setState(() {
        _questions = questions;
        _isLoading = false;
      });

      _cardController.forward();
      _startTimer();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _confirmStartTest() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: Colors.orange, size: 30),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Konfirmasi Final Test',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Anda akan memulai Final Test. Pastikan Anda siap karena:',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('⚠️ TIDAK ADA tombol kembali'),
                      Text('⏱️ Waktu akan dihitung mulai dari sekarang'),
                      Text('❌ Tidak ada indikator jawaban benar/salah'),
                      Text('📝 Anda harus menyelesaikan semua soal'),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _showConfirmation = false;
                  });
                  _loadQuestions();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Mulai Test',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }

  void _selectAnswer(int optionIndex) {
    setState(() {
      _answers[_currentQuestionIndex] = optionIndex;
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
      _cardController.reset();
      _cardController.forward();
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
      _cardController.reset();
      _cardController.forward();
    }
  }

  void _skipQuestion() {
    _nextQuestion();
  }

  bool _areAllQuestionsAnswered() {
    for (int i = 0; i < _questions.length; i++) {
      if (!_answers.containsKey(i) || _answers[i] == null) {
        return false;
      }
    }
    return true;
  }

  Future<void> _finishTest() async {
    // Show confirmation dialog first
    final shouldFinish = await _showFinishConfirmationDialog();
    if (!shouldFinish) return;

    _timer?.cancel();

    // Calculate score
    int correctAnswers = 0;
    List<Map<String, dynamic>> jawaban = [];

    for (int i = 0; i < _questions.length; i++) {
      final question = _questions[i];
      final userAnswer = _answers[i];
      final isCorrect = userAnswer == question.correctOptionIndex;

      if (isCorrect) correctAnswers++;

      // Create answer object for API
      jawaban.add({
        'soal_id': question.id,
        'jawaban': ['a', 'b', 'c', 'd'][userAnswer!], // Convert index to letter
        'penjelasan': 'User answered ${[
          'A',
          'B',
          'C',
          'D'
        ][userAnswer]} and the correct answer is ${[
          'A',
          'B',
          'C',
          'D'
        ][question.correctOptionIndex]}',
        'benar': isCorrect,
      });
    }

    final score = ((correctAnswers / _questions.length) * 100).round();

    try {
      // Submit answers to API
      await ApiService()
          .submitFinalTestAnswers(jawaban, score, widget.materialId);

      // Navigate to reflection screen
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ReflectionScreen(
              materialId: widget.materialId,
              finalTestScore: score,
              correctAnswers: correctAnswers,
              totalQuestions: _questions.length,
              elapsedTime: _elapsedSeconds,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting test: ${e.toString()}')),
        );
      }
    }
  }

  Future<bool> _showFinishConfirmationDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 30),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Selesaikan Test?',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Apakah Anda yakin ingin menyelesaikan Final Test?',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            '📊 ${_answers.length}/${_questions.length} soal terjawab'),
                        Text('⏱️ Waktu: ${_formatTime(_elapsedSeconds)}'),
                        const Text(
                            '⚠️ Anda tidak dapat mengubah jawaban setelah ini'),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Ya, Selesaikan',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    if (_showConfirmation) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _confirmStartTest();
      });
    }

    return WillPopScope(
      onWillPop: () async => false, // Disable back button
      child: Scaffold(
        body: AnimatedBuilder(
          animation: _backgroundAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    Colors.blue.shade50,
                    Colors.purple.shade50,
                    Colors.pink.shade50,
                  ],
                  stops: [
                    0.0,
                    0.3 + (_backgroundAnimation.value * 0.1),
                    0.6 + (_backgroundAnimation.value * 0.1),
                    1.0,
                  ],
                ),
              ),
              child: SafeArea(
                child: _isLoading
                    ? _buildLoadingWidget()
                    : _questions.isEmpty
                        ? _buildEmptyWidget()
                        : _buildTestContent(),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Mempersiapkan Final Test...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return const Center(
      child: Text('Tidak ada pertanyaan tersedia'),
    );
  }

  Widget _buildTestContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildProgressIndicator(),
          const SizedBox(height: 20),
          Expanded(
            child: AnimatedBuilder(
              animation: _cardAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _cardAnimation.value,
                  child: _buildQuestionCard(),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '🏆 FINAL TEST',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              Text(
                'Waktu: ${_formatTime(_elapsedSeconds)}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_currentQuestionIndex + 1}/${_questions.length}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progress:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                '${_answers.length}/${_questions.length} terjawab',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: _answers.length / _questions.length,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 16),
          _buildQuestionNumbers(),
        ],
      ),
    );
  }

  Widget _buildQuestionNumbers() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(_questions.length, (index) {
        final isAnswered =
            _answers.containsKey(index) && _answers[index] != null;
        final isCurrent = index == _currentQuestionIndex;

        return GestureDetector(
          onTap: () => _goToQuestion(index),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCurrent
                  ? AppColors.primary
                  : isAnswered
                      ? Colors.green
                      : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isCurrent ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color:
                      isCurrent || isAnswered ? Colors.white : Colors.black54,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  void _goToQuestion(int questionIndex) {
    setState(() {
      _currentQuestionIndex = questionIndex;
    });
    _cardController.reset();
    _cardController.forward();
  }

  Widget _buildQuestionCard() {
    final question = _questions[_currentQuestionIndex];
    final selectedAnswer = _answers[_currentQuestionIndex];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade100, Colors.purple.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              question.question,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: question.options.length,
              itemBuilder: (context, index) {
                final isSelected = selectedAnswer == index;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () => _selectAnswer(index),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withOpacity(0.1)
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.grey.shade200,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.grey.shade300,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                String.fromCharCode(65 + index), // A, B, C, D
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black54,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              question.options[index],
                              style: TextStyle(
                                fontSize: 16,
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.black87,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    final isLastQuestion = _currentQuestionIndex == _questions.length - 1;
    final allAnswered = _areAllQuestionsAnswered();

    return Column(
      children: [
        // Main navigation row
        Row(
          children: [
            if (_currentQuestionIndex > 0)
              Expanded(
                child: CustomButton(
                  text: '← Sebelumnya',
                  onPressed: _previousQuestion,
                  color: Colors.grey.shade300,
                ),
              ),
            if (_currentQuestionIndex > 0) const SizedBox(width: 10),
            Expanded(
              child: CustomButton(
                text: 'Skip →',
                onPressed: _skipQuestion,
                color: Colors.orange.shade300,
              ),
            ),
            const SizedBox(width: 10),
            if (!isLastQuestion)
              Expanded(
                child: CustomButton(
                  text: 'Selanjutnya →',
                  onPressed: _answers.containsKey(_currentQuestionIndex)
                      ? _nextQuestion
                      : null,
                ),
              ),
          ],
        ),

        // Finish button (always visible at bottom when ready)
        if (allAnswered) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: '🏁 SELESAIKAN FINAL TEST',
              onPressed: _finishTest,
              color: Colors.green,
              height: 60,
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ] else if (isLastQuestion) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Column(
              children: [
                const Icon(Icons.warning_amber, color: Colors.orange, size: 30),
                const SizedBox(height: 8),
                const Text(
                  'Masih ada soal yang belum dijawab!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Gunakan indikator nomor di atas untuk melengkapi jawaban',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.orange.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class FinalTestCelebrationScreen extends StatefulWidget {
  final int score;
  final int correctAnswers;
  final int totalQuestions;
  final int elapsedTime;
  final int materialId;

  const FinalTestCelebrationScreen({
    Key? key,
    required this.score,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.elapsedTime,
    required this.materialId,
  }) : super(key: key);

  @override
  _FinalTestCelebrationScreenState createState() =>
      _FinalTestCelebrationScreenState();
}

class _FinalTestCelebrationScreenState extends State<FinalTestCelebrationScreen>
    with TickerProviderStateMixin {
  late AnimationController _confettiController;
  late AnimationController _trophyController;
  late AnimationController _scoreController;
  late Animation<double> _confettiAnimation;
  late Animation<double> _trophyAnimation;
  late Animation<double> _scoreAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _confettiController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _trophyController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scoreController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _confettiAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_confettiController);

    _trophyAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _trophyController, curve: Curves.elasticOut));

    _scoreAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _scoreController, curve: Curves.easeOutBack));
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 500), () {
      _trophyController.forward();
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      _scoreController.forward();
    });
    Future.delayed(const Duration(milliseconds: 1000), () {
      _confettiController.forward();
    });

    if (widget.score >= 60) {
      Future.delayed(const Duration(seconds: 2), () {
        _showNewLevelUnlockedDialog();
      });
    }
  }

  void _showNewLevelUnlockedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '🎉',
                style: TextStyle(fontSize: 60),
              ),
              const SizedBox(height: 16),
              const Text(
                'Selamat!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Level baru telah terbuka!\nKerjakan sekarang!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Lanjutkan',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _trophyController.dispose();
    _scoreController.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes}m ${remainingSeconds}s';
  }

  String _getScoreEmoji() {
    if (widget.score >= 90) return '🏆';
    if (widget.score >= 80) return '🥇';
    if (widget.score >= 70) return '🥈';
    if (widget.score >= 60) return '🥉';
    if (widget.score >= 50) return '😊';
    return '😔';
  }

  String _getScoreMessage() {
    if (widget.score >= 90) return 'Luar Biasa!';
    if (widget.score >= 80) return 'Sangat Baik!';
    if (widget.score >= 70) return 'Baik!';
    if (widget.score >= 60) return 'Cukup Baik!';
    if (widget.score >= 50) return 'Perlu Perbaikan';
    return 'Perlu Belajar Lagi';
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                Colors.blue.shade50,
                Colors.purple.shade50,
              ],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Selamat!',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const Text(
                        'Final Test Selesai!',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Trophy Animation
                      AnimatedBuilder(
                        animation: _trophyAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _trophyAnimation.value,
                            child: Container(
                              padding: const EdgeInsets.all(30),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Text(
                                _getScoreEmoji(),
                                style: const TextStyle(fontSize: 80),
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 30),

                      // Score Display
                      AnimatedBuilder(
                        animation: _scoreAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _scoreAnimation.value,
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    '${widget.score}',
                                    style: TextStyle(
                                      fontSize: 60,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const Text(
                                    'SKOR ANDA',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _getScoreMessage(),
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      // Stats
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(
                                '✅', '${widget.correctAnswers}', 'Benar'),
                            _buildStatItem(
                                '❌',
                                '${widget.totalQuestions - widget.correctAnswers}',
                                'Salah'),
                            _buildStatItem(
                                '⏱️', _formatTime(widget.elapsedTime), 'Waktu'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Home Button
                      SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                          text: '🏠 Kembali ke Home',
                          onPressed: () {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              '/dashboard',
                              (route) => false,
                            );
                          },
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String emoji, String value, String label) {
    return Column(
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
