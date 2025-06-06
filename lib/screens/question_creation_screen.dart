// lib/screens/question_creation_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:education_game_app/constants/app_colors.dart';
import 'package:education_game_app/constants/app_styles.dart';
import 'package:education_game_app/providers/material_provider.dart';
import 'package:education_game_app/screens/material_content_screen.dart';
import 'package:education_game_app/widgets/custom_button.dart';
import 'package:education_game_app/services/api_service.dart';

class QuestionCreationScreen extends StatefulWidget {
  final int materialId;

  const QuestionCreationScreen({
    Key? key,
    required this.materialId,
  }) : super(key: key);

  @override
  _QuestionCreationScreenState createState() => _QuestionCreationScreenState();
}

class _QuestionCreationScreenState extends State<QuestionCreationScreen>
    with TickerProviderStateMixin {
  final _questionController = TextEditingController();
  final ApiService _apiService = ApiService();

  String _feedback = '';
  int _score = 0;
  bool _isLoadingPrompt = true;
  bool _isSubmitting = false;
  bool _hasSubmitted = false;
  bool _hasLoadedPrompt = false;
  String _instructionText = '';
  int _soalId = 0;

  // Animation controllers
  AnimationController? _bounceController;
  AnimationController? _floatingController;
  AnimationController? _pulseController;
  Animation<double>? _bounceAnimation;
  Animation<double>? _floatingAnimation;
  Animation<double>? _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadInstruction();
  }

  void _setupAnimations() {
    try {
      _bounceController = AnimationController(
        duration: const Duration(milliseconds: 800),
        vsync: this,
      );
      _floatingController = AnimationController(
        duration: const Duration(seconds: 3),
        vsync: this,
      );
      _pulseController = AnimationController(
        duration: const Duration(seconds: 2),
        vsync: this,
      );

      _bounceAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _bounceController!,
        curve: Curves.elasticOut,
      ));

      _floatingAnimation = Tween<double>(
        begin: -8.0,
        end: 8.0,
      ).animate(CurvedAnimation(
        parent: _floatingController!,
        curve: Curves.easeInOut,
      ));

      _pulseAnimation = Tween<double>(
        begin: 1.0,
        end: 1.05,
      ).animate(CurvedAnimation(
        parent: _pulseController!,
        curve: Curves.easeInOut,
      ));

      _bounceController!.forward();
      _floatingController!.repeat(reverse: true);
      _pulseController!.repeat(reverse: true);
    } catch (e) {
      print('Animation setup error: $e');
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    _bounceController?.dispose();
    _floatingController?.dispose();
    _pulseController?.dispose();
    super.dispose();
  }

  Future<void> _loadInstruction() async {
    setState(() {
      _isLoadingPrompt = true;
    });

    try {
      final result = await _apiService.getGreedingQuestion(widget.materialId);
      setState(() {
        _instructionText = result['soal'] ?? '';
        _soalId = result['id_soal'] ?? 0;
        _hasLoadedPrompt = true;
        _isLoadingPrompt = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingPrompt = false;
      });
      _showErrorSnackBar(
          'Oops! Ada masalah saat memuat instruksi: ${e.toString()}');
    }
  }

  Future<void> _submitQuestion() async {
    if (_questionController.text.trim().isEmpty) {
      _showEmptyQuestionDialog();
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final result = await _apiService.submitGreedingAssessment(
          _soalId, _questionController.text.trim());

      setState(() {
        _feedback = result['feedback'] ?? '';
        _score = result['nilai'] ?? 0;
        _hasSubmitted = true;
        _isSubmitting = false;
      });

      // Show celebration animation
      _bounceController?.reset();
      _bounceController?.forward();
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      _showErrorSnackBar(
          'Ups! Ada masalah saat mengirim pertanyaan: ${e.toString()}');
    }
  }

  void _showEmptyQuestionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        content: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.edit,
                  size: 40,
                  color: Colors.orange.shade600,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Halo Sahabat! 👋',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Kamu belum menulis pertanyaan nih!\nAyo tulis pertanyaan yang menarik ya! 😊',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6B7280),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade400,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'OK, Siap!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final material = Provider.of<MaterialProvider>(context)
        .getMaterialById(widget.materialId);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF0F9FF),
              Color(0xFFFEF3F2),
              Color(0xFFFFFBEB),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Simple Header
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Color(0xFF6366F1),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        material?.title ?? 'Buat Pertanyaan',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Main Content
              Expanded(
                child: _isLoadingPrompt
                    ? _buildLoadingState()
                    : _hasLoadedPrompt
                        ? _buildMainContent()
                        : _buildErrorState(),
              ),

              // Continue Button (only show after submitted)
              if (_hasSubmitted)
                Container(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => MaterialContentScreen(
                              materialId: widget.materialId,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.arrow_forward),
                          const SizedBox(width: 8),
                          const Text(
                            'Lanjut ke Materi',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _pulseAnimation != null
              ? AnimatedBuilder(
                  animation: _pulseAnimation!,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation!.value,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6366F1).withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.download,
                          size: 36,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                )
              : Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.download,
                    size: 36,
                    color: Colors.white,
                  ),
                ),
          const SizedBox(height: 24),
          const Text(
            'Sedang memuat instruksi...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6366F1),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tunggu sebentar ya! 😊',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sentiment_dissatisfied,
            size: 80,
            color: Colors.red.shade300,
          ),
          const SizedBox(height: 24),
          const Text(
            'Oops! Ada masalah',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coba lagi nanti ya! 😔',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadInstruction,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Friendly Character
          _floatingAnimation != null
              ? AnimatedBuilder(
                  animation: _floatingAnimation!,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _floatingAnimation!.value),
                      child: _buildCharacter(),
                    );
                  },
                )
              : _buildCharacter(),
          const SizedBox(height: 32),

          // Clear Instruction Card
          _buildInstructionCard(),
          const SizedBox(height: 24),

          // Question Input
          _buildQuestionInput(),

          if (_hasSubmitted) ...[
            const SizedBox(height: 24),
            _buildResultCard(),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCharacter() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          const Center(
            child: Icon(
              Icons.lightbulb,
              size: 60,
              color: Colors.white,
            ),
          ),
          // Sparkles
          Positioned(
            top: 15,
            right: 15,
            child: Icon(
              Icons.star,
              size: 20,
              color: Colors.amber.shade400,
            ),
          ),
          Positioned(
            bottom: 15,
            left: 15,
            child: Icon(
              Icons.auto_awesome,
              size: 16,
              color: Colors.pink.shade300,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.assignment,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Instruksi dari Guru 👨‍🏫',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Instruction Text in a highlighted box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF10B981).withOpacity(0.1),
                  const Color(0xFF059669).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF10B981).withOpacity(0.2),
                width: 2,
              ),
            ),
            child: Text(
              _instructionText,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF059669),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionInput() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.create,
                color: const Color(0xFF6366F1),
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Tulis Pertanyaanmu! ✏️',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Text Input
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFE5E7EB),
                width: 2,
              ),
            ),
            child: TextField(
              controller: _questionController,
              maxLines: 6,
              enabled: !_hasSubmitted,
              decoration: const InputDecoration(
                hintText:
                    'Contoh: Apa itu metode SQ4R dan bagaimana cara menggunakannya dalam belajar?',
                hintStyle: TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 16,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(20),
              ),
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF1F2937),
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Submit Button
          if (!_hasSubmitted)
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 2,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Mengirim...',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.send),
                          const SizedBox(width: 8),
                          const Text(
                            'Kirim Pertanyaan! 🚀',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    final isGoodScore = _score >= 70;
    final scoreColor = isGoodScore
        ? const Color(0xFF10B981)
        : _score >= 50
            ? const Color(0xFFF59E0B)
            : const Color(0xFFEF4444);

    return _bounceAnimation != null
        ? AnimatedBuilder(
            animation: _bounceAnimation!,
            builder: (context, child) {
              return Transform.scale(
                scale: _bounceAnimation!.value,
                child: _buildResultContent(scoreColor, isGoodScore),
              );
            },
          )
        : _buildResultContent(scoreColor, isGoodScore);
  }

  Widget _buildResultContent(Color scoreColor, bool isGoodScore) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Score Circle
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: scoreColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: scoreColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$_score',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  'poin',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Text(
            isGoodScore ? 'Luar Biasa! 🎉' : 'Tetap Semangat! 💪',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: scoreColor,
            ),
          ),
          const SizedBox(height: 16),

          // Feedback
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: scoreColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: scoreColor.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: Text(
              _feedback,
              style: TextStyle(
                fontSize: 16,
                color: const Color(0xFF374151),
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
