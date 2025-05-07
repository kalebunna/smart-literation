import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:education_game_app/constants/app_colors.dart';
import 'package:education_game_app/models/material_model.dart';

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
