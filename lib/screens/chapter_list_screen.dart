import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:education_game_app/constants/app_colors.dart';
import 'package:education_game_app/constants/app_styles.dart';
import 'package:education_game_app/models/chapter_model.dart';
import 'package:education_game_app/providers/chapter_provider.dart';
import 'package:education_game_app/screens/material_list_screen.dart';

class ChapterListScreen extends StatefulWidget {
  const ChapterListScreen({Key? key}) : super(key: key);

  @override
  _ChapterListScreenState createState() => _ChapterListScreenState();
}

class _ChapterListScreenState extends State<ChapterListScreen>
    with TickerProviderStateMixin {
  bool _isLoading = false;
  AnimationController? _bounceController;
  AnimationController? _floatingController;
  Animation<double>? _bounceAnimation;
  Animation<double>? _floatingAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadChapters();
  }

  void _setupAnimations() {
    try {
      _bounceController = AnimationController(
        duration: const Duration(milliseconds: 1200),
        vsync: this,
      );
      _floatingController = AnimationController(
        duration: const Duration(seconds: 3),
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
        begin: -10.0,
        end: 10.0,
      ).animate(CurvedAnimation(
        parent: _floatingController!,
        curve: Curves.easeInOut,
      ));

      _bounceController!.forward();
      _floatingController!.repeat(reverse: true);
    } catch (e) {
      print('Animation setup error: $e');
    }
  }

  @override
  void dispose() {
    _bounceController?.dispose();
    _floatingController?.dispose();
    super.dispose();
  }

  Future<void> _loadChapters() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Menggunakan API endpoint /list-babs dengan autentikasi
      await Provider.of<ChapterProvider>(context, listen: false).getChapters();
    } catch (e) {
      // Show friendly error message for kids
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.sentiment_dissatisfied, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Ups! Ada masalah saat memuat petualangan: ${e.toString()}',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          action: SnackBarAction(
            label: 'Coba Lagi',
            textColor: Colors.white,
            onPressed: _loadChapters,
          ),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final chapters = Provider.of<ChapterProvider>(context).chapters;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE3F2FD),
              Color(0xFFF3E5F5),
              Color(0xFFFFF8E1),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header yang menyenangkan
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Animasi karakter utama
                    _floatingAnimation != null
                        ? AnimatedBuilder(
                            animation: _floatingAnimation!,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(0, _floatingAnimation!.value),
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF6366F1),
                                        Color(0xFF8B5CF6)
                                      ],
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.purple.withOpacity(0.3),
                                        blurRadius: 15,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.auto_stories,
                                    size: 40,
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
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.purple.withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.auto_stories,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                    const SizedBox(height: 16),
                    // Judul yang menyenangkan
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.stars,
                            color: Colors.amber.shade400,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Petualangan Belajar!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6366F1),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.stars,
                            color: Colors.amber.shade400,
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Subtitle lucu
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Pilih BAB yang ingin kamu jelajahi! 🚀',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Floating clouds decoration
              Container(
                height: 50,
                child: Stack(
                  children: [
                    Positioned(
                      left: 20,
                      top: 10,
                      child: _buildFloatingCloud(Colors.blue.shade100, 30, 0.5),
                    ),
                    Positioned(
                      right: 30,
                      top: 5,
                      child: _buildFloatingCloud(Colors.pink.shade100, 25, 1.0),
                    ),
                    Positioned(
                      left: MediaQuery.of(context).size.width * 0.4,
                      top: 15,
                      child:
                          _buildFloatingCloud(Colors.green.shade100, 20, 1.5),
                    ),
                  ],
                ),
              ),

              // Daftar chapter
              Expanded(
                child: _isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF6366F1)),
                                strokeWidth: 3,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Sedang memuat petualangan...',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF6366F1),
                              ),
                            ),
                          ],
                        ),
                      )
                    : chapters.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 20,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.sentiment_neutral,
                                    size: 50,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  'Belum ada petualangan tersedia',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Coba lagi nanti ya! 😊',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadChapters,
                            color: const Color(0xFF6366F1),
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              itemCount: chapters.length,
                              itemBuilder: (context, index) {
                                final chapter = chapters[index];
                                return _bounceAnimation != null
                                    ? AnimatedBuilder(
                                        animation: _bounceAnimation!,
                                        builder: (context, child) {
                                          return Transform.scale(
                                            scale: _bounceAnimation!.value,
                                            child: _buildGameChapterCard(
                                                context, chapter, index),
                                          );
                                        },
                                      )
                                    : _buildGameChapterCard(
                                        context, chapter, index);
                              },
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingCloud(Color color, double size, double delay) {
    if (_floatingController == null || _floatingAnimation == null) {
      return Container(
        width: size,
        height: size * 0.7,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(size),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      );
    }

    return AnimatedBuilder(
      animation: _floatingController!,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatingAnimation!.value * (1 + delay * 0.3)),
          child: Container(
            width: size,
            height: size * 0.7,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(size),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGameChapterCard(
      BuildContext context, Chapter chapter, int index) {
    final isCompleted = chapter.isDone;
    final isLocked = !chapter.isUnlocked;
    final cardColors = _getCardColors(index);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (!isLocked) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      MaterialListScreen(chapterId: chapter.id),
                ),
              );
            } else {
              _showLockedDialog(context);
            }
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isLocked
                    ? [Colors.grey.shade300, Colors.grey.shade400]
                    : cardColors,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: isLocked
                      ? Colors.grey.withOpacity(0.3)
                      : cardColors[0].withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                // Icon chapter dengan desain game
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Icon(
                          isLocked
                              ? Icons.lock
                              : isCompleted
                                  ? Icons.star
                                  : _getChapterIcon(index),
                          size: 35,
                          color: isLocked
                              ? Colors.grey.shade600
                              : isCompleted
                                  ? Colors.amber.shade600
                                  : cardColors[1],
                        ),
                      ),
                      // Badge untuk completed
                      if (isCompleted)
                        Positioned(
                          top: 5,
                          right: 5,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.green.shade500,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Konten chapter
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              chapter.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isLocked
                                    ? Colors.grey.shade600
                                    : Colors.white,
                              ),
                            ),
                          ),
                          if (!isLocked && !isCompleted)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'MULAI!',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: cardColors[1],
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        chapter.description.isNotEmpty
                            ? chapter.description
                            : 'Petualangan seru menanti!',
                        style: TextStyle(
                          fontSize: 14,
                          color: isLocked
                              ? Colors.grey.shade500
                              : Colors.white.withOpacity(0.9),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Progress bar lucu
                      if (!isLocked)
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: isCompleted ? 1.0 : 0.0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isCompleted ? '100%' : '0%',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                // Arrow icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isLocked ? Icons.lock : Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Color> _getCardColors(int index) {
    final colorSets = [
      [const Color(0xFF6366F1), const Color(0xFF8B5CF6)], // Purple-Indigo
      [const Color(0xFFEC4899), const Color(0xFFF97316)], // Pink-Orange
      [const Color(0xFF06B6D4), const Color(0xFF3B82F6)], // Cyan-Blue
      [const Color(0xFF10B981), const Color(0xFF059669)], // Green-Emerald
      [const Color(0xFFF59E0B), const Color(0xFFEF4444)], // Yellow-Red
    ];
    return colorSets[index % colorSets.length];
  }

  IconData _getChapterIcon(int index) {
    final icons = [
      Icons.auto_stories,
      Icons.psychology,
      Icons.science,
      Icons.nature,
      Icons.language,
    ];
    return icons[index % icons.length];
  }

  void _showLockedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.lock, color: Colors.orange.shade400),
            const SizedBox(width: 8),
            const Text(
              'Oops! Terkunci',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Kamu harus menyelesaikan BAB sebelumnya dulu untuk membuka yang ini! 💪',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('OK, Mengerti!'),
          ),
        ],
      ),
    );
  }
}
