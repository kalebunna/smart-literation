import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
// import 'package:education_game_app/constants/app_colors.dart';
// import 'package:education_game_app/constants/app_styles.dart';
import 'package:education_game_app/models/question_model.dart';
// import 'package:education_game_app/providers/material_provider.dart';
import 'package:education_game_app/providers/quiz_provider.dart';
import 'package:education_game_app/screens/quiz_celebration_screen.dart';

class NewQuizScreen extends StatefulWidget {
  final int materialId;

  const NewQuizScreen({
    Key? key,
    required this.materialId,
  }) : super(key: key);

  @override
  _NewQuizScreenState createState() => _NewQuizScreenState();
}

class _NewQuizScreenState extends State<NewQuizScreen>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  List<QuizQuestion> _questions = [];
  int _currentQuestionIndex = 0;
  int? _selectedOptionIndex;
  bool _hasAnswered = false;
  bool _isCorrect = false;
  int _correctAnswers = 0;
  List<bool> _answerHistory = [];
  bool _showExplanation = false;
  String _currentExplanation = '';

  final AudioPlayer _audioPlayer = AudioPlayer();

  late AnimationController _bounceController;
  late AnimationController _shakeController;
  late AnimationController _progressController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _shakeAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadQuestions();
  }

  void _initializeAnimations() {
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));

    _shakeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.easeInOut,
    ));

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _shakeController.dispose();
    _progressController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playSound(String soundType) async {
    try {
      String soundPath;
      switch (soundType) {
        case 'correct':
          soundPath = 'sounds/correct.mp3';
          break;
        case 'wrong':
          soundPath = 'sounds/wrong.mp3';
          break;
        case 'select':
          soundPath = 'sounds/select.mp3';
          break;
        case 'complete':
          soundPath = 'sounds/complete.mp3';
          break;
        default:
          return;
      }
      await _audioPlayer.play(AssetSource(soundPath));
    } catch (e) {
      print('Error playing sound: $e');
    }
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<QuizProvider>(context, listen: false)
          .getQuestionsByMaterialId(widget.materialId);

      setState(() {
        _questions =
            Provider.of<QuizProvider>(context, listen: false).questions;
        _answerHistory = List.filled(_questions.length, false);
        _isLoading = false;
      });

      _progressController.forward();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _selectOption(int index) {
    if (_hasAnswered) return;

    _playSound('select');
    setState(() {
      _selectedOptionIndex = index;
    });
  }

  void _checkAnswer() {
    if (_selectedOptionIndex == null) return;

    final question = _questions[_currentQuestionIndex];
    final isCorrect = _selectedOptionIndex == question.correctOptionIndex;

    setState(() {
      _hasAnswered = true;
      _isCorrect = isCorrect;
      _answerHistory[_currentQuestionIndex] = isCorrect;

      if (isCorrect) {
        _correctAnswers++;
      } else {
        _currentExplanation = question.explanations[_selectedOptionIndex!];
        _showExplanation = true;
      }
    });

    if (isCorrect) {
      _playSound('correct');
      _bounceController.forward().then((_) {
        _bounceController.reverse();
      });
    } else {
      _playSound('wrong');
      _shakeController.forward().then((_) {
        _shakeController.reverse();
      });
    }
  }

  void _nextQuestion() {
    if (!_isCorrect) return;

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedOptionIndex = null;
        _hasAnswered = false;
        _isCorrect = false;
        _showExplanation = false;
        _currentExplanation = '';
      });
    } else {
      _playSound('complete');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => QuizCelebrationScreen(
            materialId: widget.materialId,
            score: _correctAnswers,
            totalQuestions: _questions.length,
          ),
        ),
      );
    }
  }

  void _tryAgain() {
    setState(() {
      _selectedOptionIndex = null;
      _hasAnswered = false;
      _isCorrect = false;
      _showExplanation = false;
      _currentExplanation = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6B73FF),
              Color(0xFF9B59B6),
              Color(0xFFE74C3C),
              Color(0xFFF39C12),
            ],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : _questions.isEmpty
                  ? const Center(
                      child: Text(
                        'Tidak ada pertanyaan tersedia',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        _buildHeader(),
                        _buildProgressBar(),
                        Expanded(
                          child: _buildQuestionCard(),
                        ),
                        _buildBottomSection(),
                      ],
                    ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  offset: const Offset(0, 2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back, color: Color(0xFF6B73FF)),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  offset: const Offset(0, 2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Text(
              '${_currentQuestionIndex + 1}/${_questions.length}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6B73FF),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 12,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: List.generate(_questions.length, (index) {
          Color color;
          if (index < _currentQuestionIndex) {
            color = _answerHistory[index] ? Colors.green : Colors.red;
          } else if (index == _currentQuestionIndex) {
            color = Colors.white;
          } else {
            color = Colors.transparent;
          }

          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildQuestionCard() {
    final question = _questions[_currentQuestionIndex];

    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            _shakeAnimation.value * 10 * (1 - _shakeAnimation.value * 2),
            0,
          ),
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  offset: const Offset(0, 8),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question.question,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView.builder(
                    itemCount: question.options.length,
                    itemBuilder: (context, index) {
                      return _buildOptionCard(index, question.options[index]);
                    },
                  ),
                ),
                if (_showExplanation) _buildExplanationCard(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionCard(int index, String option) {
    bool isSelected = _selectedOptionIndex == index;
    bool isCorrect = _hasAnswered &&
        index == _questions[_currentQuestionIndex].correctOptionIndex;
    bool isWrong = _hasAnswered && isSelected && !isCorrect;

    Color backgroundColor;
    Color borderColor;
    Color textColor;

    if (isCorrect) {
      backgroundColor = Colors.green.shade100;
      borderColor = Colors.green;
      textColor = Colors.green.shade800;
    } else if (isWrong) {
      backgroundColor = Colors.red.shade100;
      borderColor = Colors.red;
      textColor = Colors.red.shade800;
    } else if (isSelected) {
      backgroundColor = Colors.blue.shade50;
      borderColor = Colors.blue;
      textColor = Colors.blue.shade800;
    } else {
      backgroundColor = Colors.grey.shade50;
      borderColor = Colors.grey.shade300;
      textColor = Colors.grey.shade700;
    }

    return AnimatedBuilder(
      animation: _bounceAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: (isCorrect && _hasAnswered) ? _bounceAnimation.value : 1.0,
          child: GestureDetector(
            onTap: () => _selectOption(index),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: borderColor.withOpacity(0.2),
                    offset: const Offset(0, 4),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: borderColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        String.fromCharCode(65 + index),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                  ),
                  if (isCorrect)
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 24,
                    )
                  else if (isWrong)
                    const Icon(
                      Icons.cancel,
                      color: Colors.red,
                      size: 24,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildExplanationCard() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.orange),
              SizedBox(width: 8),
              Text(
                'Penjelasan:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _currentExplanation,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (_hasAnswered && !_isCorrect)
            Expanded(
              child: ElevatedButton(
                onPressed: _tryAgain,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Coba Lagi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          else if (_hasAnswered && _isCorrect)
            Expanded(
              child: ElevatedButton(
                onPressed: _nextQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _currentQuestionIndex < _questions.length - 1
                      ? 'Pertanyaan Berikutnya'
                      : 'Selesai',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: ElevatedButton(
                onPressed: _selectedOptionIndex == null ? null : _checkAnswer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Cek Jawaban',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
