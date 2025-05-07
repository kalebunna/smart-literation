import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:education_game_app/constants/app_colors.dart';
import 'package:education_game_app/constants/app_styles.dart';
import 'package:education_game_app/models/material_model.dart';
import 'package:education_game_app/providers/material_provider.dart';
import 'package:education_game_app/screens/question_creation_screen.dart';
import 'package:education_game_app/widgets/custom_button.dart';

class MaterialOverviewScreen extends StatelessWidget {
  final int materialId;

  const MaterialOverviewScreen({
    Key? key,
    required this.materialId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final materialProvider = Provider.of<MaterialProvider>(context);
    final material = materialProvider.getMaterialById(materialId);

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan judul dan ikon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.menu_book,
                        size: 32,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Overview',
                          style: AppStyles.heading3,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          material.title,
                          style: AppStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Konten overview
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Materi Pengantar',
                    style: AppStyles.heading3,
                  ),
                  const SizedBox(height: 16),
                  // Konten overview materi (dari rich editor API)
                  // Contoh dummy
                  const Text(
                    'Huruf kapital merupakan huruf yang berukuran lebih besar dari huruf biasa dan sering disebut sebagai huruf besar. Dalam bahasa Indonesia, penggunaan huruf kapital memiliki aturan yang perlu dipahami dengan baik ',
                    style: AppStyles.bodyMedium,
                  ),
                  const SizedBox(height: 24),

                  // Gambar ilustrasi
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/images/sq4r_illustration.png',
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      // Jika tidak ada asset, tampilkan container berwarna
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: 200,
                          color: AppColors.primary.withOpacity(0.1),
                          child: const Center(
                            child: Icon(
                              Icons.image,
                              size: 64,
                              color: AppColors.primary,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Tombol lanjut
                  CustomButton(
                    text: 'Lanjutkan',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => QuestionCreationScreen(
                            materialId: materialId,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
