import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:education_game_app/constants/app_colors.dart';
import 'package:education_game_app/constants/app_styles.dart';
import 'package:education_game_app/providers/user_provider.dart';
import 'package:education_game_app/screens/chapter_list_screen.dart';
import 'package:education_game_app/screens/profile_screen.dart';
import 'package:education_game_app/screens/reading_material_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardHomeScreen(),
    const ChapterListScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Bab',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

class DashboardHomeScreen extends StatelessWidget {
  const DashboardHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan nama user
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    user?.name.substring(0, 1) ?? 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Halo, ${user?.name ?? 'Pengguna'}',
                      style: AppStyles.heading3,
                    ),
                    const Text(
                      'Selamat belajar hari ini!',
                      style: AppStyles.bodySmall,
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    // TODO: Tampilkan fitur pencarian
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Banner utama seperti gambar yang diberikan
            Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Let's play together",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            // Navigasi ke halaman bab
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ChapterListScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Play now',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Image.asset(
                      'assets/images/trophy.png',
                      // Jika tidak ada aset, gunakan icon
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.emoji_events,
                          size: 80,
                          color: AppColors.secondary,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Kategori
            const Text(
              'Featured Categories',
              style: AppStyles.heading3,
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildCategoryItem(
                    context,
                    icon: Icons.biotech,
                    label: 'Biology',
                    color: AppColors.biologyCategory,
                  ),
                  _buildCategoryItem(
                    context,
                    icon: Icons.pets,
                    label: 'Animals',
                    color: AppColors.animalsCategory,
                  ),
                  _buildCategoryItem(
                    context,
                    icon: Icons.public,
                    label: 'Geography',
                    color: AppColors.geographyCategory,
                  ),
                  _buildCategoryItem(
                    context,
                    icon: Icons.science,
                    label: 'Science',
                    color: AppColors.scienceCategory,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Hasil terbaru
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Result',
                  style: AppStyles.heading3,
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Navigasi ke halaman hasil lengkap
                  },
                  child: const Text(
                    'See all',
                    style: TextStyle(
                      color: AppColors.info,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Item hasil terbaru
            _buildResultItem(
              context,
              number: 1,
              title: 'Science & technology',
              score: 6,
              totalScore: 10,
              color: Color(0xFFE6D9F2),
              progressColor: AppColors.primary,
            ),
            const SizedBox(height: 12),
            _buildResultItem(
              context,
              number: 2,
              title: 'Geography & history',
              score: 9,
              totalScore: 10,
              color: Color(0xFFD9EFFA),
              progressColor: AppColors.info,
            ),

            const SizedBox(height: 24),

            // Button untuk reading materials
            Container(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ReadingMaterialScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.menu_book),
                label: const Text('Bahan Bacaan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              icon,
              size: 40,
              color: color.withAlpha(255),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppStyles.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildResultItem(
    BuildContext context, {
    required int number,
    required String title,
    required int score,
    required int totalScore,
    required Color color,
    required Color progressColor,
  }) {
    final progress = score / totalScore;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Lingkaran dengan nomor
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color == AppColors.info
                  ? Colors.blue.shade100
                  : Colors.purple.shade100,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number.toString(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Judul dan progress
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white,
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Skor
          Text(
            '$score/$totalScore',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
