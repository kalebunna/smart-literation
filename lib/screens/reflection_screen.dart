import 'package:flutter/material.dart';
import 'package:education_game_app/constants/app_colors.dart';
import 'package:education_game_app/models/reflection_model.dart';
import 'package:education_game_app/services/api_service.dart';
import 'package:education_game_app/widgets/custom_button.dart';
import 'package:education_game_app/screens/material_summary_screen.dart';
import 'package:education_game_app/screens/final_test_screen.dart';

class ReflectionScreen extends StatefulWidget {
  final int materialId;
  final int finalTestScore;
  final int correctAnswers;
  final int totalQuestions;
  final int elapsedTime;

  const ReflectionScreen({
    Key? key,
    required this.materialId,
    required this.finalTestScore,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.elapsedTime,
  }) : super(key: key);

  @override
  _ReflectionScreenState createState() => _ReflectionScreenState();
}

class _ReflectionScreenState extends State<ReflectionScreen>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  bool _isSubmitting = false;
  ReflectionQuestion? _reflectionQuestion;
  final TextEditingController _answerController = TextEditingController();
  final FocusNode _answerFocusNode = FocusNode();

  late AnimationController _backgroundController;
  late AnimationController _cardController;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _cardAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadReflectionQuestion();
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
    _backgroundController.dispose();
    _cardController.dispose();
    _answerController.dispose();
    _answerFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadReflectionQuestion() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = ApiService();
      final question = await apiService.getReflectionQuestion(widget.materialId);

      setState(() {
        _reflectionQuestion = question;
        _isLoading = false;
      });

      if (question != null) {
        _cardController.forward();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _submitReflection() async {
    if (_answerController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon isi jawaban refleksi Anda'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final apiService = ApiService();
      await apiService.submitReflection(
        _reflectionQuestion!.idSoal,
        _answerController.text.trim(),
      );

      // Navigate to final test celebration screen
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => FinalTestCelebrationScreen(
              materialId: widget.materialId,
              score: widget.finalTestScore,
              correctAnswers: widget.correctAnswers,
              totalQuestions: widget.totalQuestions,
              elapsedTime: widget.elapsedTime,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevent back navigation
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
                    : _reflectionQuestion == null
                        ? _buildNoReflectionWidget()
                        : _buildReflectionContent(),
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
                  'Memuat soal refleksi...',
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

  Widget _buildNoReflectionWidget() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(24),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.info_outline,
              size: 60,
              color: Colors.orange,
            ),
            const SizedBox(height: 20),
            const Text(
              'Tidak ada soal refleksi',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Untuk materi ini tidak ada soal refleksi. Anda akan langsung diarahkan ke rangkuman.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: 'Lanjut ke Hasil Final Test',
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => FinalTestCelebrationScreen(
                        materialId: widget.materialId,
                        score: widget.finalTestScore,
                        correctAnswers: widget.correctAnswers,
                        totalQuestions: widget.totalQuestions,
                        elapsedTime: widget.elapsedTime,
                      ),
                    ),
                  );
                },
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReflectionContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          Expanded(
            child: AnimatedBuilder(
              animation: _cardAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _cardAnimation.value,
                  child: _buildReflectionCard(),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          _buildSubmitButton(),
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
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.psychology,
              color: AppColors.primary,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '💭 REFLEKSI',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                Text(
                  'Renungkan pembelajaran Anda',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReflectionCard() {
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
          // Question Section
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.quiz,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Soal Refleksi:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _reflectionQuestion!.soal,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Answer Section
          Row(
            children: [
              Icon(
                Icons.edit_note,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Jawaban Anda:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: _answerFocusNode.hasFocus 
                    ? AppColors.primary 
                    : Colors.grey.shade200,
                  width: 2,
                ),
              ),
              child: TextField(
                controller: _answerController,
                focusNode: _answerFocusNode,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
                decoration: const InputDecoration(
                  hintText: 'Tuliskan refleksi Anda di sini...\n\nAnda dapat menulis dalam beberapa paragraf untuk mengekspresikan pemikiran dan pembelajaran Anda secara lengkap.',
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (value) {
                  setState(() {}); // Update UI untuk enable/disable button
                },
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Character count
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_answerController.text.length} karakter',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              if (_answerController.text.length < 50)
                Text(
                  'Minimal 50 karakter untuk refleksi yang bermakna',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange[700],
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    final bool isAnswerValid = _answerController.text.trim().length >= 50;
    
    return SizedBox(
      width: double.infinity,
      child: CustomButton(
        text: _isSubmitting 
          ? 'Mengirim Refleksi...' 
          : '📝 Kirim Refleksi & Lanjut ke Rangkuman',
        onPressed: isAnswerValid && !_isSubmitting ? _submitReflection : null,
        color: isAnswerValid ? AppColors.primary : Colors.grey,
        height: 60,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}