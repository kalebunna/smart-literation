import 'package:flutter/material.dart';
import 'package:education_game_app/constants/app_colors.dart';
import 'package:education_game_app/constants/app_styles.dart';
import 'package:education_game_app/models/chapter_model.dart';

class ChapterCard extends StatefulWidget {
  final Chapter chapter;
  final VoidCallback onTap;
  final int index;

  const ChapterCard({
    Key? key,
    required this.chapter,
    required this.onTap,
    required this.index,
  }) : super(key: key);

  @override
  _ChapterCardState createState() => _ChapterCardState();
}

class _ChapterCardState extends State<ChapterCard>
    with SingleTickerProviderStateMixin {
  AnimationController? _pulseController;
  Animation<double>? _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
  }

  void _setupAnimation() {
    try {
      _pulseController = AnimationController(
        duration: const Duration(seconds: 2),
        vsync: this,
      );
      _pulseAnimation = Tween<double>(
        begin: 1.0,
        end: 1.05,
      ).animate(CurvedAnimation(
        parent: _pulseController!,
        curve: Curves.easeInOut,
      ));

      if (!widget.chapter.isLocked && !widget.chapter.isDone) {
        _pulseController!.repeat(reverse: true);
      }
    } catch (e) {
      print('ChapterCard animation setup error: $e');
    }
  }

  @override
  void dispose() {
    _pulseController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = widget.chapter.isDone;
    final isLocked = !widget.chapter.isUnlocked;
    final cardColors = _getCardColors(widget.index);

    // Build without animation if controllers are not ready
    Widget cardContent = Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (!isLocked) {
              widget.onTap();
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
                // Game-style chapter icon
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
                                  : _getChapterIcon(widget.index),
                          size: 35,
                          color: isLocked
                              ? Colors.grey.shade600
                              : isCompleted
                                  ? Colors.amber.shade600
                                  : cardColors[1],
                        ),
                      ),
                      // Completion badge
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
                      // New chapter sparkle
                      if (!isLocked && !isCompleted)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Icon(
                            Icons.auto_awesome,
                            size: 16,
                            color: Colors.yellow.shade600,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Chapter content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.chapter.name,
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
                          if (isCompleted)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'SELESAI!',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.chapter.description.isNotEmpty
                            ? widget.chapter.description
                            : 'Petualangan seru menanti kamu!',
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
                      // Fun progress bar
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
                            Row(
                              children: [
                                Icon(
                                  isCompleted ? Icons.star : Icons.play_circle,
                                  size: 14,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                                const SizedBox(width: 4),
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
                    ],
                  ),
                ),
                // Playful arrow
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

    // Only add animation if controllers are ready
    if (_pulseController != null && _pulseAnimation != null) {
      return AnimatedBuilder(
        animation: _pulseAnimation!,
        builder: (context, child) {
          return Transform.scale(
            scale: isLocked || isCompleted ? 1.0 : _pulseAnimation!.value,
            child: cardContent,
          );
        },
      );
    }

    return cardContent;
  }

  List<Color> _getCardColors(int index) {
    final colorSets = [
      [const Color(0xFF6366F1), const Color(0xFF8B5CF6)], // Purple-Indigo
      [const Color(0xFFEC4899), const Color(0xFFF97316)], // Pink-Orange
      [const Color(0xFF06B6D4), const Color(0xFF3B82F6)], // Cyan-Blue
      [const Color(0xFF10B981), const Color(0xFF059669)], // Green-Emerald
      [const Color(0xFFF59E0B), const Color(0xFFEF4444)], // Yellow-Red
      [const Color(0xFF8B5A2B), const Color(0xFFD2691E)], // Brown-Orange
    ];
    return colorSets[index % colorSets.length];
  }

  IconData _getChapterIcon(int index) {
    final icons = [
      Icons.auto_stories,
      Icons.psychology,
      Icons.science,
      Icons.nature_people,
      Icons.language,
      Icons.explore,
    ];
    return icons[index % icons.length];
  }

  void _showLockedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock,
                color: Colors.orange.shade600,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Oops! Masih Terkunci',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF374151),
                ),
              ),
            ),
          ],
        ),
        content: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange.shade50, Colors.yellow.shade50],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.emoji_emotions,
                size: 50,
                color: Colors.orange.shade400,
              ),
              const SizedBox(height: 12),
              const Text(
                'Kamu harus menyelesaikan BAB sebelumnya dulu untuk membuka yang ini!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF374151),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.fitness_center,
                      size: 16,
                      color: Colors.orange.shade600,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Ayo semangat!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          Container(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.thumb_up, size: 18),
                  const SizedBox(width: 8),
                  const Text(
                    'OK, Mengerti!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
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
}
