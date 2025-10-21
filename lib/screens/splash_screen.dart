import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:education_game_app/screens/login_screen.dart';
import 'package:education_game_app/screens/dashboard_screen.dart';
import 'package:education_game_app/providers/user_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _progressController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();

    // Inisialisasi animasi
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeInOut,
      ),
    );

    // Mulai animasi
    _animationController.forward();
    _progressController.forward();

    // Initialize user provider and check login status
    _initializeAndNavigate();
  }

  Future<void> _initializeAndNavigate() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    // Initialize user provider (load from storage)
    await userProvider.initializeFromStorage();
    
    // Wait for animations to complete
    await Future.delayed(const Duration(seconds: 3));
    
    if (mounted) {
      if (userProvider.isLoggedIn) {
        // User is already logged in, go to dashboard
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      } else {
        // User not logged in, go to login screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE3F2FD),
              Color(0xFFF3E5F5),
              Color(0xFFFFF8E1),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Splash screen image dengan animasi
              Expanded(
                flex: 3,
                child: AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Container(
                        constraints: const BoxConstraints(
                          maxWidth: 300,
                          maxHeight: 400,
                        ),
                        child: Image.asset(
                          'assets/images/splash screen.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Bubble progress bar
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    AnimatedBuilder(
                      animation: _progressAnimation,
                      builder: (context, child) {
                        return _buildBubbleProgressBar(
                            _progressAnimation.value);
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Loading...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                      ),
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

  Widget _buildBubbleProgressBar(double progress) {
    const int totalBubbles = 5;
    final int activeBubbles = (progress * totalBubbles).ceil();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalBubbles, (index) {
        final isActive = index < activeBubbles;
        final bubbleProgress = isActive
            ? ((progress * totalBubbles) - index).clamp(0.0, 1.0)
            : 0.0;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 16 + (bubbleProgress * 8),
          height: 16 + (bubbleProgress * 8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isActive
                ? const LinearGradient(
                    colors: [
                      Color(0xFF9064F5),
                      Color(0xFF7B4ED6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isActive
                ? null
                : Colors.white.withOpacity(0.3),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: const Color(0xFF9064F5).withOpacity(0.6),
                      blurRadius: 12,
                      spreadRadius: 3,
                    ),
                  ]
                : null,
          ),
        );
      }),
    );
  }
}
