import 'package:flutter/material.dart';
import 'package:education_game_app/constants/app_colors.dart';
import 'package:education_game_app/constants/app_styles.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class ReadingMaterialScreen extends StatefulWidget {
  const ReadingMaterialScreen({Key? key}) : super(key: key);

  @override
  _ReadingMaterialScreenState createState() => _ReadingMaterialScreenState();
}

class _ReadingMaterialScreenState extends State<ReadingMaterialScreen> {
  bool _isLoading = true;
  List<ReadingMaterial> _materials = [];

  @override
  void initState() {
    super.initState();
    _loadMaterials();
  }

  Future<void> _loadMaterials() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Untuk implementasi dummy
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _materials = [
          ReadingMaterial(
            id: 1,
            title: 'Pengantar Metode SQ4R',
            description:
                'Panduan lengkap tentang metode SQ4R dan aplikasinya dalam pembelajaran.',
            fileUrl: 'assets/pdf/sq4r_introduction.pdf',
            thumbnailUrl: 'assets/images/sq4r_thumb.png',
          ),
          ReadingMaterial(
            id: 2,
            title: 'Teknik Membaca Efektif',
            description:
                'Berbagai teknik membaca untuk meningkatkan pemahaman dan kecepatan.',
            fileUrl: 'assets/pdf/effective_reading.pdf',
            thumbnailUrl: 'assets/images/reading_thumb.png',
          ),
          ReadingMaterial(
            id: 3,
            title: 'Meningkatkan Daya Ingat',
            description:
                'Strategi untuk meningkatkan daya ingat dalam proses belajar.',
            fileUrl: 'assets/pdf/memory_enhancement.pdf',
            thumbnailUrl: 'assets/images/memory_thumb.png',
          ),
        ];
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Bahan Bacaan'),
        backgroundColor: AppColors.primary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _materials.isEmpty
              ? const Center(child: Text('Tidak ada bahan bacaan tersedia'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _materials.length,
                  itemBuilder: (context, index) {
                    final material = _materials[index];
                    return _buildMaterialCard(context, material);
                  },
                ),
    );
  }

  Widget _buildMaterialCard(BuildContext context, ReadingMaterial material) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PDFViewScreen(
                  url: material.fileUrl,
                  title: material.title,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: Container(
                  width: double.infinity,
                  height: 150,
                  color: AppColors.primary.withOpacity(0.1),
                  child: Image.asset(
                    material.thumbnailUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(
                          Icons.picture_as_pdf,
                          size: 64,
                          color: Colors.red.shade300,
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      material.title,
                      style: AppStyles.heading3,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      material.description,
                      style: AppStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(
                          Icons.picture_as_pdf,
                          color: Colors.red,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'PDF Document',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => PDFViewScreen(
                                  url: material.fileUrl,
                                  title: material.title,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Baca'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ReadingMaterial {
  final int id;
  final String title;
  final String description;
  final String fileUrl;
  final String thumbnailUrl;

  ReadingMaterial({
    required this.id,
    required this.title,
    required this.description,
    required this.fileUrl,
    required this.thumbnailUrl,
  });
}

class PDFViewScreen extends StatefulWidget {
  final String url;
  final String title;

  const PDFViewScreen({
    Key? key,
    required this.url,
    required this.title,
  }) : super(key: key);

  @override
  _PDFViewScreenState createState() => _PDFViewScreenState();
}

class _PDFViewScreenState extends State<PDFViewScreen> {
  String? localPath;
  bool _isLoading = true;
  int _totalPages = 0;
  int _currentPage = 0;
  PDFViewController? _pdfViewController;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _downloadFile();
  }

  Future<void> _downloadFile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Pada implementasi nyata, download PDF dari URL
      final response = await http.get(Uri.parse(widget.url));

      // Simpan ke penyimpanan lokal
      final bytes = response.bodyBytes;
      final dir = await getApplicationDocumentsDirectory();
      final file =
          File('${dir.path}/${DateTime.now().millisecondsSinceEpoch}.pdf');

      await file.writeAsBytes(bytes);

      setState(() {
        localPath = file.path;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: AppColors.primary,
        actions: [
          if (_isReady)
            IconButton(
              icon: const Icon(Icons.bookmark),
              onPressed: () {
                // Implementasi bookmark
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : localPath == null
              ? const Center(child: Text('Error loading PDF'))
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(error.toString())),
                        );
                      },
                      onPageError: (page, error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Error on page $page: $error')),
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
                    // Page indicator
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Container(
                        alignment: Alignment.center,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Halaman ${_currentPage + 1} dari $_totalPages',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
      // Tombol navigasi
      floatingActionButton: _isReady
          ? Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Previous page
                if (_currentPage > 0)
                  FloatingActionButton(
                    heroTag: 'prev',
                    mini: true,
                    backgroundColor: AppColors.primary,
                    child: const Icon(Icons.arrow_back),
                    onPressed: () {
                      _pdfViewController?.setPage(_currentPage - 1);
                    },
                  ),
                const SizedBox(width: 16),
                // Next page
                if (_currentPage < _totalPages - 1)
                  FloatingActionButton(
                    heroTag: 'next',
                    backgroundColor: AppColors.primary,
                    child: const Icon(Icons.arrow_forward),
                    onPressed: () {
                      _pdfViewController?.setPage(_currentPage + 1);
                    },
                  ),
              ],
            )
          : null,
    );
  }
}
