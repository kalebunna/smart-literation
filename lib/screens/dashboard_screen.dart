import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'package:education_game_app/constants/app_colors.dart';
import 'package:education_game_app/models/dashboard_model.dart';
import 'package:education_game_app/services/api_service.dart';
import 'package:education_game_app/screens/chapter_list_screen.dart';
import 'package:education_game_app/screens/profile_screen.dart';
import 'package:education_game_app/screens/reading_material_screen.dart';
import 'package:education_game_app/screens/login_screen.dart';
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';
import 'package:animations/animations.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  DashboardData? _dashboardData;
  bool _isLoading = true;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _liquidController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _liquidAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _liquidController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _liquidAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _liquidController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _liquidController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    try {
      final apiService = ApiService();
      final data = await apiService.getDashboardData();

      setState(() {
        _dashboardData = data;
        _isLoading = false;
      });

      // Start animations
      _fadeController.forward();
      _slideController.forward();
      _liquidController.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Waduh, ada masalah nih! Coba lagi yuk! 😅'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _logout() async {
    try {
      final apiService = ApiService();
      await apiService.logout();

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ups, belum bisa keluar nih! Coba lagi ya! 🤔'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _getBodyWidget() {
    switch (_currentIndex) {
      case 0:
        return _buildDashboardHome();
      case 1:
        return const ChapterListScreen();
      case 2:
        return const ReadingMaterialScreen();
      case 3:
        return const ProfileScreen();
      default:
        return _buildDashboardHome();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: _getBodyWidget(),
      bottomNavigationBar: AnimatedBuilder(
        animation: _liquidAnimation,
        builder: (context, child) {
          return StylishBottomBar(
            option: BubbleBarOptions(
              barStyle: BubbleBarStyle.horizontal,
              bubbleFillStyle: BubbleFillStyle.fill,
              opacity: 1.0,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(30)),
              padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 6),
              inkEffect: true,
              inkColor: AppColors.primary.withValues(alpha: 0.1),
            ),
            backgroundColor: Colors.white,
            elevation: 25,
            items: [
              BottomBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: _currentIndex == 0
                        ? LinearGradient(
                            colors: [
                              AppColors.primary.withValues(
                                  alpha: 0.8 + (_liquidAnimation.value * 0.2)),
                              AppColors.primary.withValues(
                                  alpha: 0.6 + (_liquidAnimation.value * 0.2)),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    boxShadow: _currentIndex == 0
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(
                                  alpha: 0.3 + (_liquidAnimation.value * 0.2)),
                              blurRadius: 8 + (_liquidAnimation.value * 4),
                              spreadRadius: 1 + (_liquidAnimation.value * 1),
                            ),
                          ]
                        : null,
                  ),
                  child: Transform.scale(
                    scale: _currentIndex == 0
                        ? (1.0 + (_liquidAnimation.value * 0.1))
                        : 1.0,
                    child: Icon(
                      Icons.home_rounded,
                      color:
                          _currentIndex == 0 ? Colors.white : Colors.grey[600],
                      size: 20,
                    ),
                  ),
                ),
                selectedIcon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withValues(alpha: 0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.home_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                selectedColor: AppColors.primary,
                unSelectedColor: Colors.grey[600]!,
                title: Text(
                  'Home',
                  style: TextStyle(
                    fontWeight: _currentIndex == 0
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: 10,
                    color: _currentIndex == 0
                        ? AppColors.primary
                        : Colors.grey[600],
                  ),
                ),
                showBadge: false,
              ),
              BottomBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: _currentIndex == 1
                        ? LinearGradient(
                            colors: [
                              AppColors.primary.withValues(
                                  alpha: 0.8 + (_liquidAnimation.value * 0.2)),
                              AppColors.primary.withValues(
                                  alpha: 0.6 + (_liquidAnimation.value * 0.2)),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    boxShadow: _currentIndex == 1
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(
                                  alpha: 0.3 + (_liquidAnimation.value * 0.2)),
                              blurRadius: 8 + (_liquidAnimation.value * 4),
                              spreadRadius: 1 + (_liquidAnimation.value * 1),
                            ),
                          ]
                        : null,
                  ),
                  child: Transform.scale(
                    scale: _currentIndex == 1
                        ? (1.0 + (_liquidAnimation.value * 0.1))
                        : 1.0,
                    child: Icon(
                      Icons.book_rounded,
                      color:
                          _currentIndex == 1 ? Colors.white : Colors.grey[600],
                      size: 20,
                    ),
                  ),
                ),
                selectedIcon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withValues(alpha: 0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.book_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                selectedColor: AppColors.primary,
                unSelectedColor: Colors.grey[600]!,
                title: Text(
                  'Bab',
                  style: TextStyle(
                    fontWeight: _currentIndex == 1
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: 10,
                    color: _currentIndex == 1
                        ? AppColors.primary
                        : Colors.grey[600],
                  ),
                ),
                showBadge: false,
              ),
              BottomBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: _currentIndex == 2
                        ? LinearGradient(
                            colors: [
                              AppColors.primary.withValues(
                                  alpha: 0.8 + (_liquidAnimation.value * 0.2)),
                              AppColors.primary.withValues(
                                  alpha: 0.6 + (_liquidAnimation.value * 0.2)),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    boxShadow: _currentIndex == 2
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(
                                  alpha: 0.3 + (_liquidAnimation.value * 0.2)),
                              blurRadius: 8 + (_liquidAnimation.value * 4),
                              spreadRadius: 1 + (_liquidAnimation.value * 1),
                            ),
                          ]
                        : null,
                  ),
                  child: Transform.scale(
                    scale: _currentIndex == 2
                        ? (1.0 + (_liquidAnimation.value * 0.1))
                        : 1.0,
                    child: Icon(
                      Icons.menu_book_rounded,
                      color:
                          _currentIndex == 2 ? Colors.white : Colors.grey[600],
                      size: 20,
                    ),
                  ),
                ),
                selectedIcon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withValues(alpha: 0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.menu_book_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                selectedColor: AppColors.primary,
                unSelectedColor: Colors.grey[600]!,
                title: Text(
                  'Read',
                  style: TextStyle(
                    fontWeight: _currentIndex == 2
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: 10,
                    color: _currentIndex == 2
                        ? AppColors.primary
                        : Colors.grey[600],
                  ),
                ),
                showBadge: false,
              ),
              BottomBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: _currentIndex == 3
                        ? LinearGradient(
                            colors: [
                              AppColors.primary.withValues(
                                  alpha: 0.8 + (_liquidAnimation.value * 0.2)),
                              AppColors.primary.withValues(
                                  alpha: 0.6 + (_liquidAnimation.value * 0.2)),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    boxShadow: _currentIndex == 3
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(
                                  alpha: 0.3 + (_liquidAnimation.value * 0.2)),
                              blurRadius: 8 + (_liquidAnimation.value * 4),
                              spreadRadius: 1 + (_liquidAnimation.value * 1),
                            ),
                          ]
                        : null,
                  ),
                  child: Transform.scale(
                    scale: _currentIndex == 3
                        ? (1.0 + (_liquidAnimation.value * 0.1))
                        : 1.0,
                    child: Icon(
                      Icons.person_rounded,
                      color:
                          _currentIndex == 3 ? Colors.white : Colors.grey[600],
                      size: 20,
                    ),
                  ),
                ),
                selectedIcon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withValues(alpha: 0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                selectedColor: AppColors.primary,
                unSelectedColor: Colors.grey[600]!,
                title: Text(
                  'User',
                  style: TextStyle(
                    fontWeight: _currentIndex == 3
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: 10,
                    color: _currentIndex == 3
                        ? AppColors.primary
                        : Colors.grey[600],
                  ),
                ),
                showBadge: false,
              ),
            ],
            hasNotch: false,
            fabLocation: StylishBarFabLocation.center,
            currentIndex: _currentIndex,
            onTap: (index) {
              HapticFeedback.lightImpact();
              setState(() {
                _currentIndex = index;
              });
              _liquidController.reset();
              _liquidController.forward();
            },
          );
        },
      ),
    );
  }

  Widget _buildDashboardHome() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }

    if (_dashboardData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Waduh, belum bisa muat nih! 😱',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                });
                SchedulerBinding.instance.addPostFrameCallback((_) {
                  _loadDashboardData();
                });
              },
              child: const Text('Yuk Coba Lagi! 💪'),
            ),
          ],
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: DashboardHomeContent(
          dashboardData: _dashboardData!,
          onLogout: _logout,
        ),
      ),
    );
  }
}

class DashboardHomeContent extends StatelessWidget {
  final DashboardData dashboardData;
  final VoidCallback onLogout;

  const DashboardHomeContent({
    Key? key,
    required this.dashboardData,
    required this.onLogout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            _buildStreakCard(),
            const SizedBox(height: 20),
            _buildStatsGrid(),
            const SizedBox(height: 24),
            _buildWeeklyGoalCard(),
            const SizedBox(height: 24),
            _buildSectionHeader('Progres Kamu'),
            const SizedBox(height: 16),
            _buildRecentResults(),
            const SizedBox(height: 24),
            _buildCurrentLearningCard(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.primary.withValues(alpha: 0.7)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              dashboardData.userOverview.name.isNotEmpty
                  ? dashboardData.userOverview.name[0].toUpperCase()
                  : 'U',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hai ${dashboardData.userOverview.name.split(' ').first}! 👋',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Kamu sudah ${dashboardData.userOverview.overallProgressPercentage.toInt()}% nih! Nilai rata-rata ${dashboardData.userOverview.totalScoreAverage.toInt()}% 🌟',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStreakCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.local_fire_department_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kamu sudah belajar ${dashboardData.userOverview.streakDays} Hari',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Wah keren! Terus semangat belajar ya!',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Bab Cerita',
            '${dashboardData.userOverview.completedChapters}/${dashboardData.userOverview.totalChapters}',
            dashboardData.userOverview.chaptersProgress,
            Icons.book_rounded,
            AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Materi Seru',
            '${dashboardData.userOverview.totalMaterialsCompleted}/${dashboardData.userOverview.totalMaterialsAvailable}',
            dashboardData.userOverview.materialsProgress,
            Icons.article_rounded,
            AppColors.secondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Nilai Kamu',
            '${dashboardData.userOverview.totalScoreAverage.toStringAsFixed(1)}%',
            dashboardData.userOverview.totalScoreAverage / 100,
            Icons.trending_up_rounded,
            AppColors.success,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, double progress, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyGoalCard() {
    final materialsCompleted =
        dashboardData.recentActivity.materialsCompletedThisWeek;
    final weeklyGoal = 5; // Default weekly goal
    final progress = materialsCompleted / weeklyGoal;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.flag_rounded,
                  color: AppColors.info,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Target Minggu Ini! 🎯',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              Text(
                '$materialsCompleted/$weeklyGoal',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.info),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            progress >= 1.0
                ? 'Yeay! Kamu sudah selesai target minggu ini! Hebat banget! 🎉'
                : 'Ayok semangat! Tinggal ${weeklyGoal - materialsCompleted} materi lagi nih! Kamu pasti bisa! 💪',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentResults() {
    final recentScores = dashboardData.recentActivity.recentScores;
    final lastCompletedMaterial =
        dashboardData.recentActivity.lastCompletedMaterial;

    if (recentScores.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'Belum ada hasil nih! Yuk mulai belajar! 🚀',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        // Last completed material
        if (lastCompletedMaterial != null)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check_circle,
                      color: AppColors.success,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lastCompletedMaterial,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Materi terakhir yang kamu selesaikan',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Selesai! 🎉',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        // Recent scores display
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.trending_up,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Nilai ',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Rata-rata kamu: ${dashboardData.recentActivity.averageRecentScore.toInt()}% 📊',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: recentScores.take(5).map((score) {
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(right: 4),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _getScoreColor(score.toDouble())
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '$score%',
                          style: TextStyle(
                            color: _getScoreColor(score.toDouble()),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentLearningCard() {
    final currentLearning = dashboardData.currentLearning;
    final activeChapter = currentLearning.activeChapter;
    final nextMaterial = currentLearning.nextMaterial;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Belajar Yuk!'),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (activeChapter != null) ...[
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.book_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activeChapter.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            activeChapter.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      'Sejauh ini:',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${activeChapter.materialsCompleted} dari ${activeChapter.materialsTotal} materi selesai!',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: activeChapter.progress.clamp(0.0, 1.0),
                    backgroundColor: Colors.grey[200],
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    minHeight: 8,
                  ),
                ),
              ] else ...[
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.school_outlined,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Belum ada bab yang kamu pilih nih! 📖',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (nextMaterial != null) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: nextMaterial.isUnlocked
                        ? AppColors.secondary.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: nextMaterial.isUnlocked
                          ? AppColors.secondary.withValues(alpha: 0.3)
                          : Colors.grey.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        nextMaterial.isUnlocked
                            ? Icons.play_circle_outline
                            : Icons.lock_outline,
                        color: nextMaterial.isUnlocked
                            ? AppColors.secondary
                            : Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Selanjutnya kita belajar: ${nextMaterial.name}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: nextMaterial.isUnlocked
                                    ? Colors.black87
                                    : Colors.grey,
                              ),
                            ),
                            Text(
                              nextMaterial.type.toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                color: nextMaterial.isUnlocked
                                    ? AppColors.secondary
                                    : Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (nextMaterial.isUnlocked)
                        Icon(
                          Icons.arrow_forward_ios,
                          color: AppColors.secondary,
                          size: 16,
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Color _getScoreColor(double percentage) {
    if (percentage >= 80) return AppColors.success;
    if (percentage >= 60) return AppColors.secondary;
    return AppColors.error;
  }
}
