import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:education_game_app/constants/app_colors.dart';
import 'package:education_game_app/constants/app_styles.dart';
import 'package:education_game_app/models/chapter_model.dart';
import 'package:education_game_app/providers/chapter_provider.dart';
import 'package:education_game_app/screens/material_list_screen.dart';
import 'package:education_game_app/widgets/chapter_card.dart';

class ChapterListScreen extends StatefulWidget {
  const ChapterListScreen({Key? key}) : super(key: key);

  @override
  _ChapterListScreenState createState() => _ChapterListScreenState();
}

class _ChapterListScreenState extends State<ChapterListScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadChapters();
  }

  Future<void> _loadChapters() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Untuk implementasi dummy
      await Provider.of<ChapterProvider>(context, listen: false)
          .loadDummyChapters();

      // Untuk implementasi API sebenarnya
      // await Provider.of<ChapterProvider>(context, listen: false).getChapters();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Daftar BAB'),
        backgroundColor: AppColors.primary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : chapters.isEmpty
              ? const Center(child: Text('Tidak ada BAB tersedia'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: chapters.length,
                  itemBuilder: (context, index) {
                    final chapter = chapters[index];
                    return ChapterCard(
                      chapter: chapter,
                      onTap: () {
                        if (!chapter.isLocked) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  MaterialListScreen(chapterId: chapter.id),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Selesaikan BAB sebelumnya terlebih dahulu'),
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
    );
  }
}
