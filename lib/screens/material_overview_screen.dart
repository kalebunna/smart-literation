import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:education_game_app/constants/app_colors.dart';
import 'package:education_game_app/constants/app_styles.dart';
import 'package:education_game_app/models/material_model.dart' as model;
import 'package:education_game_app/providers/material_provider.dart';
import 'package:education_game_app/screens/question_creation_screen.dart';
import 'package:education_game_app/widgets/custom_button.dart';

class MaterialOverviewScreen extends StatefulWidget {
  final int materialId;

  const MaterialOverviewScreen({
    Key? key,
    required this.materialId,
  }) : super(key: key);

  @override
  _MaterialOverviewScreenState createState() => _MaterialOverviewScreenState();
}

class _MaterialOverviewScreenState extends State<MaterialOverviewScreen>
    with TickerProviderStateMixin {
  AnimationController? _bounceController;
  AnimationController? _floatingController;
  Animation<double>? _bounceAnimation;
  Animation<double>? _floatingAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
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
        begin: -8.0,
        end: 8.0,
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

  @override
  Widget build(BuildContext context) {
    final materialProvider = Provider.of<MaterialProvider>(context);
    final material = materialProvider.getMaterialById(widget.materialId);

    if (material == null) {
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
            ),
          const SizedBox(height: 20),

          // Konten greading (HTML content)
          if (material.greading.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.blue.shade200,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.auto_stories,
                        color: Colors.blue.shade600,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Materi Pembelajaran',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Render HTML content
                  Html(
                    data: material.greading,
                    style: {
                      "body": Style(
                        fontSize: FontSize(16),
                        lineHeight: LineHeight(1.6),
                        color: const Color(0xFF374151),
                        fontFamily: 'Poppins',
                      ),
                      "p": Style(
                        fontSize: FontSize(16),
                        lineHeight: LineHeight(1.6),
                        margin: Margins.only(bottom: 16),
                        color: const Color(0xFF374151),
                      ),
                      "h1, h2, h3, h4, h5, h6": Style(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF6366F1),
                        margin: Margins.only(top: 16, bottom: 8),
                      ),
                      "strong, b": Style(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF374151),
                      ),
                      "em, i": Style(
                        fontStyle: FontStyle.italic,
                      ),
                      "ul": Style(
                        margin: Margins.only(left: 16, bottom: 16),
                      ),
                      "ol": Style(
                        margin: Margins.only(left: 16, bottom: 16),
                      ),
                      "li": Style(
                        margin: Margins.only(bottom: 4),
                      ),
                    },
                  ),
                ],
              ),
            ),
          ] else ...[
            // Fallback jika tidak ada konten greading
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.description,
                    size: 50,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Konten materi belum tersedia',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Silakan hubungi pengajar untuk informasi lebih lanjut',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Fun info cards
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.orange.shade100, Colors.orange.shade200],
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        material.type == MaterialType.PDF
                            ? Icons.picture_as_pdf
                            : Icons.play_circle_filled,
                        color: Colors.orange.shade700,
                        size: 30,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tipe Materi',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        material.type == MaterialType.PDF ? 'PDF' : 'Video',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.orange.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green.shade100, Colors.green.shade200],
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.timer,
                        color: Colors.green.shade700,
                        size: 30,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Status',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Siap Belajar',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.green.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
            ),
          ),
          child: SafeArea(
            child: Center(
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
                      Icons.sentiment_dissatisfied,
                      size: 50,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Materi tidak ditemukan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

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
                    // Back button dan judul
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
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
                            material.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6366F1),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Animated mascot dengan buku
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
                                  child: Stack(
                                    children: [
                                      const Center(
                                        child: Icon(
                                          Icons.menu_book,
                                          size: 40,
                                          color: Colors.white,
                                        ),
                                      ),
                                      // Sparkle effects
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Icon(
                                          Icons.star,
                                          size: 16,
                                          color: Colors.amber.shade400,
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 8,
                                        left: 8,
                                        child: Icon(
                                          Icons.auto_awesome,
                                          size: 12,
                                          color: Colors.pink.shade300,
                                        ),
                                      ),
                                    ],
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
                              Icons.menu_book,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                    const SizedBox(height: 16),

                    // Fun title bubble
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                            Icons.lightbulb,
                            color: Colors.amber.shade400,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Ayo Belajar!',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6366F1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Konten overview
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _bounceAnimation != null
                      ? AnimatedBuilder(
                          animation: _bounceAnimation!,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _bounceAnimation!.value,
                              child: _buildContentCard(material),
                            );
                          },
                        )
                      : _buildContentCard(material),
                ),
              ),

              // Tombol lanjutkan
              Container(
                padding: const EdgeInsets.all(20),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF059669)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      // Sementara kosongkan dulu sesuai permintaan
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.white),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Fitur ini akan segera tersedia! 🚀',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: const Color(0xFF6366F1),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.rocket_launch, color: Colors.white),
                        const SizedBox(width: 8),
                        const Text(
                          'Lanjutkan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
