import 'package:education_game_app/models/reading_material_model.dart';
import 'package:flutter/material.dart';
import 'package:education_game_app/constants/app_colors.dart';
import 'package:education_game_app/constants/app_styles.dart';
import 'package:education_game_app/services/api_service.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class ReadingMaterialScreen extends StatefulWidget {
  const ReadingMaterialScreen({Key? key}) : super(key: key);

  @override
  _ReadingMaterialScreenState createState() => _ReadingMaterialScreenState();
}

class _ReadingMaterialScreenState extends State<ReadingMaterialScreen>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  List<ReadingMaterial> _materials = [];
  final ApiService _apiService = ApiService();

  AnimationController? _bounceController;
  AnimationController? _floatingController;
  Animation<double>? _bounceAnimation;
  Animation<double>? _floatingAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadMaterials();
  }

  @override
  void dispose() {
    _bounceController?.dispose();
    _floatingController?.dispose();
    super.dispose();
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

  Future<void> _loadMaterials() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final materials = await _apiService.getReadingMaterials();
      setState(() {
        _materials = materials;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.sentiment_dissatisfied, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Ups! Ada masalah saat memuat bahan bacaan: ${e.toString()}',
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
            onPressed: _loadMaterials,
          ),
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    // Animasi karakter buku
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
                                        Color(0xFFFF6B6B),
                                        Color(0xFFFFE66D)
                                      ],
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.orange.withOpacity(0.3),
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
                              );
                            },
                          )
                        : Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF6B6B), Color(0xFFFFE66D)],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.orange.withOpacity(0.3),
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
                            Icons.local_library,
                            color: Colors.orange.shade400,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Perpustakaan Kecil!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF6B6B),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.local_library,
                            color: Colors.orange.shade400,
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
                        'Pilih buku yang ingin kamu baca! 📚✨',
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

              // Daftar bahan bacaan
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
                                    Color(0xFFFF6B6B)),
                                strokeWidth: 3,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Sedang memuat buku-buku seru...',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFFFF6B6B),
                              ),
                            ),
                          ],
                        ),
                      )
                    : _materials.isEmpty
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
                                  'Belum ada buku tersedia',
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
                            onRefresh: _loadMaterials,
                            color: const Color(0xFFFF6B6B),
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              itemCount: _materials.length,
                              itemBuilder: (context, index) {
                                final material = _materials[index];
                                return _bounceAnimation != null
                                    ? AnimatedBuilder(
                                        animation: _bounceAnimation!,
                                        builder: (context, child) {
                                          return Transform.scale(
                                            scale: _bounceAnimation!.value,
                                            child: _buildMaterialCard(
                                                context, material, index),
                                          );
                                        },
                                      )
                                    : _buildMaterialCard(
                                        context, material, index);
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

  Widget _buildMaterialCard(
      BuildContext context, ReadingMaterial material, int index) {
    final cardColors = _getCardColors(index);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => FunPDFViewScreen(
                  fileUrl: material.fileUrl,
                  title: material.title,
                  author: material.penulis,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: cardColors,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: cardColors[0].withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Icon buku dengan desain menarik
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
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
                              Icons.picture_as_pdf,
                              size: 30,
                              color: Colors.red.shade400,
                            ),
                          ),
                          // Sparkle effect
                          Positioned(
                            top: 5,
                            right: 5,
                            child: Icon(
                              Icons.auto_awesome,
                              size: 14,
                              color: Colors.amber.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Content info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            material.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.person,
                                size: 16,
                                color: Colors.white.withOpacity(0.8),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  material.penulis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.date_range,
                                size: 16,
                                color: Colors.white.withOpacity(0.8),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                material.tahun,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.8),
                                ),
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
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Description
                if (material.description.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      material.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                const SizedBox(height: 12),
                // Fun action button
                Container(
                  width: double.infinity,
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => FunPDFViewScreen(
                              fileUrl: material.fileUrl,
                              title: material.title,
                              author: material.penulis,
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(25),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.menu_book,
                            color: cardColors[1],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Baca Sekarang!',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: cardColors[1],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.auto_awesome,
                            color: Colors.amber.shade600,
                            size: 16,
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
      ),
    );
  }

  List<Color> _getCardColors(int index) {
    final colorSets = [
      [const Color(0xFFFF6B6B), const Color(0xFFFF8E53)], // Red-Orange
      [const Color(0xFF4ECDC4), const Color(0xFF44A08D)], // Teal-Green
      [const Color(0xFF6C5CE7), const Color(0xFFA29BFE)], // Purple-Lavender
      [const Color(0xFFFFBE0B), const Color(0xFFFFCF47)], // Yellow-Gold
      [const Color(0xFFFF7675), const Color(0xFFE17055)], // Pink-Coral
      [const Color(0xFF00B894), const Color(0xFF00CEC9)], // Green-Mint
    ];
    return colorSets[index % colorSets.length];
  }
}

class FunPDFViewScreen extends StatefulWidget {
  final String fileUrl;
  final String title;
  final String author;

  const FunPDFViewScreen({
    Key? key,
    required this.fileUrl,
    required this.title,
    required this.author,
  }) : super(key: key);

  @override
  _FunPDFViewScreenState createState() => _FunPDFViewScreenState();
}

class _FunPDFViewScreenState extends State<FunPDFViewScreen>
    with TickerProviderStateMixin {
  String? localPath;
  bool _isLoading = true;
  int _totalPages = 0;
  int _currentPage = 0;
  PDFViewController? _pdfViewController;
  bool _isReady = false;
  AnimationController? _pulseController;
  Animation<double>? _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
    _downloadFile();
  }

  @override
  void dispose() {
    _pulseController?.dispose();
    super.dispose();
  }

  void _setupAnimation() {
    try {
      _pulseController = AnimationController(
        duration: const Duration(seconds: 2),
        vsync: this,
      );
      _pulseAnimation = Tween<double>(
        begin: 1.0,
        end: 1.1,
      ).animate(CurvedAnimation(
        parent: _pulseController!,
        curve: Curves.easeInOut,
      ));
      _pulseController!.repeat(reverse: true);
    } catch (e) {
      print('Animation setup error: $e');
    }
  }

  Future<void> _downloadFile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Pada implementasi nyata, download PDF dari URL di server
      final baseUrl = 'http://127.0.0.1:8000/storage/';
      final fullUrl = baseUrl + widget.fileUrl;

      final response = await http.get(Uri.parse(fullUrl));

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final dir = await getApplicationDocumentsDirectory();
        final file =
            File('${dir.path}/${DateTime.now().millisecondsSinceEpoch}.pdf');

        await file.writeAsBytes(bytes);

        setState(() {
          localPath = file.path;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to download PDF: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Error loading PDF: ${e.toString()}'),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Fun header
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Back button dengan style menarik
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          borderRadius: BorderRadius.circular(15),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Color(0xFF667eea),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Title section
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.auto_stories,
                                  size: 16,
                                  color: Colors.orange.shade600,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    widget.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF667eea),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.person,
                                  size: 14,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    'oleh ${widget.author}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Fun bookmark button
                    if (_isReady)
                      Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.amber.shade400,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      Icon(Icons.bookmark, color: Colors.white),
                                      const SizedBox(width: 8),
                                      const Text('Bookmark disimpan! 📖✨'),
                                    ],
                                  ),
                                  backgroundColor: Colors.green.shade400,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15)),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(15),
                            child: const Icon(
                              Icons.bookmark,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // PDF Content
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: _isLoading
                        ? Center(
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
                                                gradient: const LinearGradient(
                                                  colors: [
                                                    Color(0xFFFF6B6B),
                                                    Color(0xFFFFE66D)
                                                  ],
                                                ),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.picture_as_pdf,
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
                                        decoration: const BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Color(0xFFFF6B6B),
                                              Color(0xFFFFE66D)
                                            ],
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.picture_as_pdf,
                                          size: 40,
                                          color: Colors.white,
                                        ),
                                      ),
                                const SizedBox(height: 20),
                                const Text(
                                  'Sedang memuat buku...',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF667eea),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Sabar ya! 😊',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : localPath == null
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      size: 80,
                                      color: Colors.red.shade300,
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Oops! Ada masalah',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF667eea),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Coba lagi nanti ya! 😔',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF94A3B8),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Stack(
                                children: [
                                  PDFView(
                                    filePath: localPath!,
                                    enableSwipe: true,
                                    swipeHorizontal: true,
                                    autoSpacing: true,
                                    pageFling: true,
                                    pageSnap: true,
                                    onRender: (pages) {
                                      setState(() {
                                        _totalPages = pages!;
                                        _isReady = true;
                                      });
                                    },
                                    onError: (error) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(error.toString())),
                                      );
                                    },
                                    onPageError: (page, error) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Error on page $page: $error')),
                                      );
                                    },
                                    onViewCreated:
                                        (PDFViewController pdfViewController) {
                                      _pdfViewController = pdfViewController;
                                    },
                                    onPageChanged: (int? page, int? total) {
                                      setState(() {
                                        _currentPage = page!;
                                      });
                                    },
                                  ),
                                  // Fun page indicator
                                  if (_isReady)
                                    Positioned(
                                      bottom: 20,
                                      left: 0,
                                      right: 0,
                                      child: Center(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 10),
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFF667eea),
                                                Color(0xFF764ba2),
                                              ],
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.3),
                                                blurRadius: 10,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.menu_book,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Halaman ${_currentPage + 1} dari $_totalPages',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
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
              ),
            ],
          ),
        ),
      ),
      // Fun floating action buttons
      floatingActionButton: _isReady
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Previous page
                if (_currentPage > 0)
                  Container(
                    margin: const EdgeInsets.only(left: 32),
                    child: FloatingActionButton(
                      heroTag: 'prev',
                      mini: true,
                      backgroundColor: Colors.orange.shade400,
                      onPressed: () {
                        _pdfViewController?.setPage(_currentPage - 1);
                      },
                      child: const Icon(Icons.navigate_before,
                          color: Colors.white),
                    ),
                  )
                else
                  const SizedBox(width: 80),
                // Next page
                if (_currentPage < _totalPages - 1)
                  FloatingActionButton(
                    heroTag: 'next',
                    backgroundColor: Colors.green.shade400,
                    onPressed: () {
                      _pdfViewController?.setPage(_currentPage + 1);
                    },
                    child: const Icon(Icons.navigate_next, color: Colors.white),
                  ),
              ],
            )
          : null,
    );
  }
}
