import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:education_game_app/constants/app_colors.dart';
import 'package:education_game_app/constants/app_styles.dart';
import 'package:education_game_app/models/material_model.dart';
import 'package:education_game_app/providers/chapter_provider.dart';
import 'package:education_game_app/providers/material_provider.dart';
import 'package:education_game_app/screens/material_overview_screen.dart';
import 'package:education_game_app/screens/score_screen.dart';
import 'package:education_game_app/widgets/material_card.dart';

class MaterialListScreen extends StatefulWidget {
  final int chapterId;

  const MaterialListScreen({
    Key? key,
    required this.chapterId,
  }) : super(key: key);

  @override
  _MaterialListScreenState createState() => _MaterialListScreenState();
}

class _MaterialListScreenState extends State<MaterialListScreen> {
  bool _isLoading = false;

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
      await Provider.of<MaterialProvider>(context, listen: false)
          .loadDummyMaterials(widget.chapterId);

      // Untuk implementasi API sebenarnya
      // await Provider.of<MaterialProvider>(context, listen: false)
      //     .getMaterialsByChapterId(widget.chapterId);
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
    final materials = Provider.of<MaterialProvider>(context).materials;
    final chapter = Provider.of<ChapterProvider>(context)
        .chapters
        .firstWhere((c) => c.id == widget.chapterId);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(chapter.title),
        backgroundColor: AppColors.primary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : materials.isEmpty
              ? const Center(child: Text('Tidak ada Materi tersedia'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: materials.length,
                  itemBuilder: (context, index) {
                    final material = materials[index];
                    return MaterialCard(
                      material: material,
                      onTap: () {
                        if (material.isCompleted) {
                          // Jika materi sudah selesai, tampilkan skor saja
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ScoreScreen(
                                score: material.score ?? 0,
                                totalScore: 10,
                                materialTitle: material.title,
                              ),
                            ),
                          );
                        } else if (!material.isLocked) {
                          // Jika materi belum terkunci, buka overview
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => MaterialOverviewScreen(
                                materialId: material.id,
                              ),
                            ),
                          );
                        } else {
                          // Jika materi terkunci, tampilkan pesan
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Selesaikan Materi sebelumnya terlebih dahulu'),
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
