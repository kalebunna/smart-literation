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

class _MaterialContentScreenState extends State<MaterialContentScreen> {
  bool _isLoading = true;
  String? _pdfPath;
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
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

      // Untuk implementasi dummy
      if (material.type == model.MaterialType.PDF) {
        // Di implementasi sebenarnya, download PDF dari URL di material.fileUrl
        // Untuk dummy, tunda beberapa detik
        // await Future.delayed(const Duration(seconds: 2));
        // setState(() {
        //   // Untuk pengembangan, kita tidak benar-benar memiliki file PDF
        //   // Jadi hanya set flag loading menjadi false
        //   _isLoading = false;
        //   _buildRealPdfView(context);
        // });
        await _downloadPDF(material.fileUrl);
      } else if (material.type == model.MaterialType.VIDEO) {
        // Di implementasi sebenarnya, init video player dengan URL di material.fileUrl
        // Untuk dummy, gunakan video dari internet
        _videoPlayerController = VideoPlayerController.network(
          'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
        );

        await _videoPlayerController!.initialize();

        _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController!,
          autoPlay: false,
          looping: false,
          aspectRatio: _videoPlayerController!.value.aspectRatio,
          placeholder: Container(
            color: Colors.black,
          ),
          materialProgressColors: ChewieProgressColors(
            playedColor: AppColors.primary,
            handleColor: AppColors.primary,
            backgroundColor: Colors.grey.shade300,
            bufferedColor: Colors.grey.shade500,
          ),
        );

        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Untuk implementasi sebenarnya, anda akan perlu fungsi untuk mengunduh PDF
  Future<void> _downloadPDF(String url) async {
    try {
      final response = await http.get(Uri.parse(url));

      final bytes = response.bodyBytes;
      final dir = await getApplicationDocumentsDirectory();
      final file =
          File('${dir.path}/${DateTime.now().millisecondsSinceEpoch}.pdf');

      await file.writeAsBytes(bytes);

      setState(() {
        _pdfPath = file.path;
        _isLoading = false;
      });
    } catch (e) {
      throw Exception('Failed to download PDF: $e');
    }
  }

  Future<void> _continueToQuiz() async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QuizScreen(materialId: widget.materialId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final material = Provider.of<MaterialProvider>(context)
        .getMaterialById(widget.materialId);

    if (material == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Materi tidak ditemukan'),
          backgroundColor: AppColors.primary,
        ),
        body: const Center(
          child: Text('Materi tidak ditemukan'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(material.title),
        backgroundColor: AppColors.primary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: material.type == model.MaterialType.PDF
                      ? _buildRealPdfView(context)
                      : _buildVideoPlayer(context),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: CustomButton(
                    text: 'Lanjut ke Quiz',
                    onPressed: _continueToQuiz,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildPdfView(BuildContext context) {
    // Untuk implementasi nyata, gunakan PDFView dengan _pdfPath
    // Untuk dummy, tampilkan placeholder
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.picture_as_pdf,
              size: 80,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            const Text(
              'PDF Viewer',
              style: AppStyles.heading3,
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Pada implementasi sebenarnya, di sini akan ditampilkan dokumen PDF menggunakan flutter_pdfview.',
                textAlign: TextAlign.center,
                style: AppStyles.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRealPdfView(BuildContext context) {
    if (_pdfPath == null) {
      return const Center(
        child: Text('Error loading PDF'),
      );
    }

    return PDFView(
      filePath: _pdfPath!,
      enableSwipe: true,
      swipeHorizontal: true,
      autoSpacing: true,
      pageFling: true,
      pageSnap: true,
      onError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      },
      onPageError: (page, error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error on page $page: $error')),
        );
      },
    );
  }

  Widget _buildVideoPlayer(BuildContext context) {
    if (_chewieController == null) {
      return const Center(
        child: Text('Error loading video'),
      );
    }

    return Container(
      color: Colors.black,
      child: Chewie(
        controller: _chewieController!,
      ),
    );
  }
}
