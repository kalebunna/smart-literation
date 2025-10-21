import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:education_game_app/screens/material_summary_screen.dart';
import 'dart:math' as math;

class QuizCelebrationScreen extends StatefulWidget {
  final int materialId;
  final int score;
  final int totalQuestions;

  const QuizCelebrationScreen({
    Key? key,
    required this.materialId,
    required this.score,
    required this.totalQuestions,
  }) : super(key: key);

  @override
  _QuizCelebrationScreenState createState() => _QuizCelebrationScreenState();
}

class _QuizCelebrationScreenState extends State<QuizCelebrationScreen>
    with TickerProviderStateMixin {
  late AnimationController _confettiController;
  late AnimationController _trophyController;
  late AnimationController _textController;
  late AnimationController _buttonController;
  
  late Animation<double> _confettiAnimation;
  late Animation<double> _trophyAnimation;
  late Animation<double> _textAnimation;
  late Animation<double> _buttonAnimation;
  
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<ConfettiParticle> _confettiParticles = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _createConfettiParticles();
    _startAnimations();
    _playSound('complete');
  }

  void _initializeAnimations() {
    _confettiController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _trophyController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _confettiAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_confettiController);
    
    _trophyAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _trophyController,
      curve: Curves.elasticOut,
    ));
    
    _textAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutBack,
    ));
    
    _buttonAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: Curves.elasticOut,
    ));
  }

  void _createConfettiParticles() {
    final random = math.Random();
    for (int i = 0; i < 50; i++) {
      _confettiParticles.add(
        ConfettiParticle(
          x: random.nextDouble(),
          y: -0.1,
          color: _getRandomColor(),
          size: random.nextDouble() * 8 + 4,
          rotation: random.nextDouble() * 2 * math.pi,
          rotationSpeed: (random.nextDouble() - 0.5) * 0.2,
          fallSpeed: random.nextDouble() * 0.02 + 0.01,
        ),
      );
    }
  }

  Color _getRandomColor() {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.pink,
    ];
    return colors[math.Random().nextInt(colors.length)];
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 200), () {
      _trophyController.forward();
    });
    
    Future.delayed(const Duration(milliseconds: 800), () {
      _textController.forward();
    });
    
    Future.delayed(const Duration(milliseconds: 1200), () {
      _buttonController.forward();
    });
    
    _confettiController.repeat();
  }

  Future<void> _playSound(String soundType) async {
    try {
      await _audioPlayer.play(AssetSource('sounds/$soundType.mp3'));
    } catch (e) {
      print('Error playing sound: $e');
    }
  }

  @override
  void dispose() {
    _confettiController.stop();
    _confettiController.dispose();
    _trophyController.dispose();
    _textController.dispose();
    _buttonController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double percentage = (widget.score / widget.totalQuestions) * 100;
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF6B73FF),
              Color(0xFF9B59B6),
              Color(0xFFE74C3C),
              Color(0xFFF39C12),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Confetti Animation
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _confettiAnimation,
                builder: (context, child) {
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      return CustomPaint(
                        painter: ConfettiPainter(
                          particles: _confettiParticles,
                          animationValue: _confettiAnimation.value,
                        ),
                        size: Size(constraints.maxWidth, constraints.maxHeight),
                      );
                    },
                  );
                },
              ),
            ),
            
            // Main Content
            SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Trophy Animation
                      AnimatedBuilder(
                        animation: _trophyAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _trophyAnimation.value,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.yellow.withValues(alpha: 0.5),
                                    blurRadius: 30,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                              child: const Text(
                                '🏆',
                                style: TextStyle(fontSize: 120),
                              ),
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Congratulations Text
                      AnimatedBuilder(
                        animation: _textAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _textAnimation.value,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    offset: const Offset(0, 8),
                                    blurRadius: 20,
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    '🎉 Selamat! 🎉',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF4CAF50),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Kamu telah menyelesaikan kuis!',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Color(0xFF666666),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Skor: ${widget.score}/${widget.totalQuestions}',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2196F3),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${percentage.toStringAsFixed(0)}%',
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFE91E63),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Performance Message
                      AnimatedBuilder(
                        animation: _textAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, 50 * (1 - _textAnimation.value)),
                            child: Opacity(
                              opacity: _textAnimation.value.clamp(0.0, 1.0),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  _getPerformanceMessage(percentage),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF333333),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 48),
                      
                      // Action Buttons
                      AnimatedBuilder(
                        animation: _buttonAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _buttonAnimation.value,
                            child: Column(
                              children: [
                                // Summary Button
                                Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.3),
                                        offset: const Offset(0, 6),
                                        blurRadius: 15,
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => MaterialSummaryScreen(
                                            materialId: widget.materialId,
                                            quizScore: widget.score,
                                            totalQuizQuestions: widget.totalQuestions,
                                          ),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF9B59B6),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 20,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.library_books, size: 24),
                                        SizedBox(width: 8),
                                        Text(
                                          'Lihat Rangkuman',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                
                                // Back to Material Button
                                Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        offset: const Offset(0, 6),
                                        blurRadius: 15,
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).popUntil(
                                        (route) => route.isFirst,
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF4CAF50),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 20,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.home, size: 24),
                                        SizedBox(width: 8),
                                        Text(
                                          'Kembali ke Materi',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                
                                // Try Again Button
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        offset: const Offset(0, 6),
                                        blurRadius: 15,
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      Navigator.of(context).pop();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2196F3),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 20,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.refresh, size: 24),
                                        SizedBox(width: 8),
                                        Text(
                                          'Coba Lagi',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getPerformanceMessage(double percentage) {
    if (percentage == 100) {
      return '🌟 Sempurna! Kamu hebat sekali! 🌟';
    } else if (percentage >= 80) {
      return '😊 Bagus sekali! Terus belajar ya!';
    } else if (percentage >= 60) {
      return '👍 Lumayan! Bisa lebih baik lagi!';
    } else {
      return '💪 Jangan menyerah! Coba lagi yuk!';
    }
  }
}

class ConfettiParticle {
  double x;
  double y;
  final Color color;
  final double size;
  double rotation;
  final double rotationSpeed;
  final double fallSpeed;

  ConfettiParticle({
    required this.x,
    required this.y,
    required this.color,
    required this.size,
    required this.rotation,
    required this.rotationSpeed,
    required this.fallSpeed,
  });
}

class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;
  final double animationValue;

  ConfettiPainter({
    required this.particles,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Ensure we have valid dimensions
    if (size.width <= 0 || size.height <= 0) return;
    
    for (var particle in particles) {
      particle.y += particle.fallSpeed;
      particle.rotation += particle.rotationSpeed;
      
      if (particle.y > 1.1) {
        particle.y = -0.1;
        particle.x = math.Random().nextDouble();
      }

      final paint = Paint()..color = particle.color;
      
      // Calculate actual positions
      final x = particle.x * size.width;
      final y = particle.y * size.height;
      
      // Only draw if within bounds
      if (x >= -particle.size && x <= size.width + particle.size &&
          y >= -particle.size && y <= size.height + particle.size) {
        canvas.save();
        canvas.translate(x, y);
        canvas.rotate(particle.rotation);
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: particle.size,
            height: particle.size,
          ),
          paint,
        );
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}