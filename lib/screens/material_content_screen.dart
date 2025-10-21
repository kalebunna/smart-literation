// lib/screens/material_content_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:education_game_app/constants/app_colors.dart';
import 'package:education_game_app/constants/app_styles.dart';
import 'package:education_game_app/models/material_model.dart' as model;
import 'package:education_game_app/providers/material_provider.dart';
import 'package:education_game_app/screens/quiz_screen.dart';
import 'package:education_game_app/widgets/custom_button.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class MaterialContentScreen extends StatefulWidget {
  final int materialId;

  const MaterialContentScreen({
    Key? key,
    required this.materialId,
  }) : super(key: key);

  @override
  _MaterialContentScreenState createState() => _MaterialContentScreenState();
}

class _MaterialContentScreenState extends State<MaterialContentScreen>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  String? _pdfPath;
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  // PDF Navigation
  int _totalPages = 0;
  int _currentPage = 0;
  PDFViewController? _pdfViewController;
  bool _isReady = false;

  // Animations
  AnimationController? _floatingController;
  Animation<double>? _floatingAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadContent();
  }

  void _setupAnimations() {
    try {
      _floatingController = AnimationController(
        duration: const Duration(seconds: 4),
        vsync: this,
      );

      _floatingAnimation = Tween<double>(
        begin: -3.0,
        end: 3.0,
      ).animate(CurvedAnimation(
        parent: _floatingController!,
        curve: Curves.easeInOut,
      ));

      _floatingController!.repeat(reverse: true);
    } catch (e) {
      print('Animation setup error: $e');
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    _floatingController?.dispose();
    super.dispose();
  }

  Future<void> _loadContent() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final material = Provider.of<MaterialProvider>(context, listen: false)
          .getMaterialById(widget.materialId);

      if (material == null) {
        throw Exception('Material tidak ditemukan');
      }

      if (material.type == model.MaterialType.PDF) {
        await _downloadPDF(material.fileUrl);
      } else if (material.type == model.MaterialType.VIDEO) {
        await _initializeVideo(material.fileUrl);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.sentiment_dissatisfied, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('Ups! Ada masalah: ${e.toString()}')),
            ],
          ),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _downloadPDF(String url) async {
    try {
      final baseUrl = 'http://127.0.0.1:8000/storage/';
      final fullUrl = baseUrl + url;

      final response = await http.get(Uri.parse(fullUrl));

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final dir = await getApplicationDocumentsDirectory();
        final file =
            File('${dir.path}/${DateTime.now().millisecondsSinceEpoch}.pdf');

        await file.writeAsBytes(bytes);

        setState(() {
          _pdfPath = file.path;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to download PDF: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to download PDF: $e');
    }
  }

  Future<void> _initializeVideo(String url) async {
    try {
      // For demo purposes, using a sample video URL
      // In real implementation, use the actual video URL from the material
      _videoPlayerController = VideoPlayerController.network(
        'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
      );

      await _videoPlayerController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: false,
        looping: false,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        materialProgressColors: ChewieProgressColors(
          playedColor: AppColors.primary,
          handleColor: AppColors.primary,
          backgroundColor: Colors.grey.shade300,
          bufferedColor: Colors.grey.shade500,
        ),
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.sentiment_dissatisfied,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Oops! Video bermasalah',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Coba lagi nanti ya! 😊',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          );
        },
      );

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      throw Exception('Failed to initialize video: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final materialProvider = Provider.of<MaterialProvider>(context);
    final material = materialProvider.getMaterialById(widget.materialId);

    if (material == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.sentiment_dissatisfied,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Materi tidak ditemukan',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
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
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: material.type == model.MaterialType.PDF
          ? Colors.grey.shade100 // Soft background for PDF reading
          : Colors.black, // Black background for video
      body: SafeArea(
        child: Column(
          children: [
            // Simple minimal header
            _buildMinimalHeader(),

            // Content area - full screen focus
            Expanded(
              child: _isLoading
                  ? _buildLoadingState(material)
                  : _buildContentArea(material),
            ),

            // Bottom navigation - only show when content is ready
            if (!_isLoading) _buildBottomNavigation(material),
          ],
        ),
      ),
    );
  }

  Widget _buildMinimalHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Simple back button
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
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Color(0xFF6366F1),
                size: 20,
              ),
            ),
          ),
          const Spacer(),
          // Simple progress for PDF
          if (_isReady && _totalPages > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                '${_currentPage + 1}/$_totalPages',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6366F1),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(model.Material material) {
    final isPDF = material.type == model.MaterialType.PDF;

    return Container(
      color: isPDF ? Colors.grey.shade100 : Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Simple loading animation
            _floatingAnimation != null
                ? AnimatedBuilder(
                    animation: _floatingAnimation!,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _floatingAnimation!.value),
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6366F1).withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  ),
            const SizedBox(height: 20),
            Text(
              'Sedang memuat...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isPDF ? const Color(0xFF6366F1) : Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tunggu sebentar ya! 😊',
              style: TextStyle(
                fontSize: 12,
                color: isPDF ? Colors.grey.shade600 : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentArea(model.Material material) {
    return material.type == model.MaterialType.PDF
        ? _buildPDFViewer()
        : _buildVideoPlayer();
  }

  Widget _buildPDFViewer() {
    if (_pdfPath == null) {
      return Container(
        color: Colors.grey.shade100,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.sentiment_dissatisfied,
                size: 80,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 20),
              const Text(
                'Materi tidak bisa dibuka',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
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
        ),
      );
    }

    // PDF displayed like natural pages with soft shadow
    return Container(
      color: Colors.grey.shade100,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: PDFView(
            filePath: _pdfPath!,
            enableSwipe: true,
            swipeHorizontal: true,
            autoSpacing: false,
            pageFling: true,
            pageSnap: true,
            backgroundColor: Colors.white,
            fitPolicy: FitPolicy.BOTH,
            fitEachPage: true,
            onRender: (pages) {
              setState(() {
                _totalPages = pages!;
                _isReady = true;
              });
            },
            onError: (error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.sentiment_dissatisfied, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(child: Text('Error: $error')),
                    ],
                  ),
                  backgroundColor: Colors.red.shade400,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            onPageError: (page, error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error pada halaman $page: $error'),
                  backgroundColor: Colors.red.shade400,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            onViewCreated: (PDFViewController pdfViewController) {
              _pdfViewController = pdfViewController;
            },
            onPageChanged: (int? page, int? total) {
              setState(() {
                _currentPage = page!;
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (_chewieController == null) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.sentiment_dissatisfied,
                size: 80,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 20),
              const Text(
                'Video tidak bisa diputar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Coba lagi nanti ya! 😊',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      color: Colors.black,
      child: Chewie(
        controller: _chewieController!,
      ),
    );
  }

  Widget _buildBottomNavigation(model.Material material) {
    final isPDF = material.type == model.MaterialType.PDF;

    return Container(
      padding: const EdgeInsets.all(16),
      color: isPDF ? Colors.grey.shade100 : Colors.black,
      child: Row(
        children: [
          // PDF navigation controls
          if (isPDF && _isReady) ...[
            // Previous page
            GestureDetector(
              onTap: _currentPage > 0
                  ? () => _pdfViewController?.setPage(_currentPage - 1)
                  : null,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _currentPage > 0
                      ? const Color(0xFF6366F1)
                      : Colors.grey.shade300,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.chevron_left,
                  color: _currentPage > 0 ? Colors.white : Colors.grey.shade500,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Next page
            GestureDetector(
              onTap: _currentPage < _totalPages - 1
                  ? () => _pdfViewController?.setPage(_currentPage + 1)
                  : null,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _currentPage < _totalPages - 1
                      ? const Color(0xFF6366F1)
                      : Colors.grey.shade300,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.chevron_right,
                  color: _currentPage < _totalPages - 1
                      ? Colors.white
                      : Colors.grey.shade500,
                  size: 24,
                ),
              ),
            ),
            const Spacer(),
          ] else
            const Spacer(),

          // Continue to quiz button
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF059669)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF10B981).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        QuizScreen(materialId: widget.materialId),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.quiz, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  const Text(
                    'Lanjut Quiz',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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
