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
import 'package:education_game_app/screens/assessment_sumatif_screen.dart';
import 'package:education_game_app/screens/assessment_result_review_screen.dart';
import 'package:education_game_app/screens/pretest_screen.dart';
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
  bool?
      _hasCompletedAssessment; // null = belum dicek, true = sudah, false = belum
  bool _pretestModalShown = false;
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

      // Cek apakah user sudah mengerjakan assessment sumatif (tidak perlu await, bisa berjalan parallel)
      _checkAssessmentStatus();

      setState(() {
        _dashboardData = data;
        _isLoading = false;
      });

      // Start animations setelah data dimuat
      _fadeController.forward();
      _slideController.forward();
      _liquidController.forward();

      // Show pretest modal if not completed
      if (data.userOverview.hasCompletedPretest == false && !_pretestModalShown) {
        setState(() {
          _pretestModalShown = true;
        });
        _showPretestModal();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      // Start animations even on error untuk menghindari blank screen
      _fadeController.forward();
      _slideController.forward();
      _liquidController.forward();
    }
  }

  void _showPretestModal() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                const Icon(Icons.celebration, color: Colors.orange, size: 28),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Halo Sahabat Pintar! 👋',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Sebelum mulai belajar, yuk kita cek dulu sejauh mana pengetahuan kamu di Pretest!',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 12),
                Text(
                  'Tenang saja, skornya tidak akan mempengaruhi nilai akhir kok. Semangat! 🚀',
                  style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Nanti Saja'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const PretestScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Mulai Pretest!', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      );
    });
  }

  Future<void> _checkAssessmentStatus() async {
    try {
      final apiService = ApiService();
      final resultsResponse = await apiService.getAssessmentSumatifResults();

      setState(() {
        // Jika berhasil mendapatkan hasil (meskipun skor 0), berarti sudah mengerjakan
        _hasCompletedAssessment =
            resultsResponse.success && resultsResponse.data != null;
      });
    } catch (e) {
      setState(() {
        _hasCompletedAssessment = false;
      });
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

    // Pastikan animasi sudah di-start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted &&
          !_fadeController.isAnimating &&
          _fadeAnimation.value == 0.0) {
        _fadeController.forward();
        _slideController.forward();
        _liquidController.forward();
      }
    });

    // Gunakan AnimatedBuilder untuk memastikan widget rebuild saat animasi berubah
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        // Jika animasi belum dimulai dan opacity masih 0, langsung tampilkan tanpa animasi
        if (_fadeAnimation.value == 0.0 && !_fadeController.isAnimating) {
          return DashboardHomeContent(
            dashboardData: _dashboardData!,
            onLogout: _logout,
            hasCompletedAssessment: _hasCompletedAssessment,
          );
        }

        return Opacity(
          opacity: _fadeAnimation.value > 0 ? _fadeAnimation.value : 1.0,
          child: Transform.translate(
            offset: _slideAnimation.value,
            child: DashboardHomeContent(
              dashboardData: _dashboardData!,
              onLogout: _logout,
              hasCompletedAssessment: _hasCompletedAssessment,
            ),
          ),
        );
      },
    );
  }
}

class DashboardHomeContent extends StatelessWidget {
  final DashboardData dashboardData;
  final VoidCallback onLogout;
  final bool? hasCompletedAssessment;

  const DashboardHomeContent({
    Key? key,
    required this.dashboardData,
    required this.onLogout,
    this.hasCompletedAssessment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            _buildPretestScoreCard(),
            const SizedBox(height: 20),
            _buildStatsGrid(),
            const SizedBox(height: 24),
            if (!dashboardData.userOverview.hasCompletedPretest) ...[
              _buildPretestCard(context),
              const SizedBox(height: 24),
            ],
            _buildAssessmentSumatifCard(context, hasCompletedAssessment),
            const SizedBox(height: 24),
            _buildSectionHeader('Progres Kamu'),
            const SizedBox(height: 16),
            _buildRecentResults(),
          ],
        ),
      ),
    );
  }

  Widget _buildPretestCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.shade400,
            Colors.orange.shade600,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.assignment_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ujian Pretest',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Cek pengetahuan awalanmu yuk!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const PretestScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.orange.shade700,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Mulai Pretest Sekarang',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
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

  Widget _buildPretestScoreCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.indigo.shade600,
            Colors.indigo.shade800,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withValues(alpha: 0.3),
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
              Icons.stars_rounded,
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
                  dashboardData.userOverview.hasCompletedPretest
                      ? 'Skor Pretest Kamu: ${dashboardData.userOverview.pretestScore.toInt()}'
                      : 'Belum Ada Skor Pretest',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dashboardData.userOverview.hasCompletedPretest
                      ? 'Hebat! Terus tingkatkan kemampuanmu ya!'
                      : 'Yuk kerjakan pretest untuk cek kemampuan awal!',
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

  Widget _buildAssessmentSumatifCard(
      BuildContext context, bool? hasCompletedAssessment) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.assignment_turned_in_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Assessment Sumatif',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ujian akhir setelah semua bab selesai',
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
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                try {
                  final apiService = ApiService();

                  // Cek apakah user sudah mengerjakan assessment sumatif
                  final resultsResponse =
                      await apiService.getAssessmentSumatifResults();

                  // Jika berhasil mendapatkan hasil (meskipun skor 0), berarti sudah mengerjakan
                  if (resultsResponse.success && resultsResponse.data != null) {
                    // User sudah mengerjakan assessment, langsung ke review
                    if (context.mounted) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              const AssessmentResultReviewScreen(),
                        ),
                      );
                    }
                    return;
                  }

                  // Jika error dan bukan 404, berarti ada masalah lain
                  if (resultsResponse.error != null &&
                      !resultsResponse.error!
                          .toLowerCase()
                          .contains('belum mengerjakan')) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              resultsResponse.error ?? 'Terjadi kesalahan'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                    return;
                  }

                  // Jika belum mengerjakan, cek apakah sudah selesai semua bab
                  final response = await apiService.getAssessmentSumatif();

                  if (response.success) {
                    // Navigate to assessment sumatif screen
                    if (context.mounted) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AssessmentSumatifScreen(),
                        ),
                      );
                    }
                  } else {
                    // Show error dialog
                    if (context.mounted) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            content: Text(
                              response.error ??
                                  'Anda belum menyelesaikan semua bab. Silakan selesaikan semua bab terlebih dahulu untuk mengakses assessment sumatif.',
                              style: const TextStyle(fontSize: 16),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Mengerti'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                hasCompletedAssessment == true
                    ? 'Lihat Hasil Assessment'
                    : 'Mulai Assessment Sumatif',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
    final completedMaterials = dashboardData.recentActivity.completedMaterials;

    if (completedMaterials.isEmpty) {
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

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: completedMaterials.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final materialName = completedMaterials[index];
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
                      materialName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Materi telah diselesaikan',
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
        );
      },
    );
  }
}
