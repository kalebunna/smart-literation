import 'dart:convert';
// import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:education_game_app/constants/app_colors.dart';
// import 'package:education_game_app/constants/app_styles.dart';
import 'package:education_game_app/screens/dashboard_screen.dart';
// import 'package:education_game_app/widgets/custom_button.dart';
import 'package:education_game_app/services/api_service.dart';
import 'package:education_game_app/providers/user_provider.dart';
// import 'package:education_game_app/models/user_model.dart';
import 'dart:developer' as developer;

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _apiService = ApiService();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  late AnimationController _animationController;
  late AnimationController _bounceController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _bounceAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();
    _bounceController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await _apiService.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (response.success && response.data != null) {
        final responseData = response.data!;
        final token = responseData['data']['token'];
        final userData = responseData['data']['user'];

        if (token == null) {
          throw Exception('Token tidak ditemukan dalam respons login');
        }

        if (userData == null) {
          throw Exception('Data user tidak ditemukan dalam respons login');
        }

        // Simpan token dan user data ke SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('user', jsonEncode(userData));

        // Set user data ke provider
        if (!mounted) return;
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.setUserFromApi(userData, token);

        // Navigate ke dashboard
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      } else {
        // Handle error response
        String errorText = _getErrorMessage(response.error ?? 'Login gagal');

        if (!mounted) return;
        _showErrorSnackBar(errorText);
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('Terjadi kesalahan: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.sentiment_dissatisfied, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  String _getErrorMessage(String error) {
    final errorMessage = error.toLowerCase();

    if (errorMessage.contains('invalid credentials')) {
      return 'Email atau password yang kamu masukkan salah nih! 😅';
    } else if (errorMessage.contains('login failed')) {
      return 'Ups! Ada masalah saat login. Coba lagi ya! 🔄';
    } else if (errorMessage.contains('network error')) {
      return 'Koneksi internet bermasalah. Cek koneksi kamu ya! 📶';
    } else if (errorMessage.contains('email')) {
      return 'Email yang kamu masukkan tidak valid nih! ✉️';
    } else if (errorMessage.contains('password')) {
      return 'Password yang kamu masukkan salah! 🔒';
    } else {
      developer.log('Unknown error: $error');
      return 'Ada yang tidak beres nih! Coba lagi ya! 😊';
    }
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
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Character Header with Animation
                      ScaleTransition(
                        scale: _bounceAnimation,
                        child: Column(
                          children: [
                            // Cute character container
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  // Main character
                                  const Center(
                                    child: Icon(
                                      Icons.school,
                                      size: 60,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  // Sparkle effects
                                  Positioned(
                                    top: 15,
                                    right: 15,
                                    child: Icon(
                                      Icons.star,
                                      size: 16,
                                      color: Colors.amber.shade400,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 15,
                                    left: 15,
                                    child: Icon(
                                      Icons.star,
                                      size: 12,
                                      color: Colors.pink.shade300,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Fun clouds decoration
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildCloud(Colors.blue.shade100, 40),
                                _buildCloud(Colors.pink.shade100, 30),
                                _buildCloud(Colors.green.shade100, 35),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Welcome Text with Fun Style
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Halo Sahabat! ',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                                Icon(
                                  Icons.waving_hand,
                                  color: Colors.orange.shade400,
                                  size: 28,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Ayo masuk dan mulai petualangan belajar!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Email Input with Fun Design
                      _buildFunTextField(
                        controller: _emailController,
                        icon: Icons.email_rounded,
                        iconColor: Colors.blue.shade400,
                        hintText: 'Masukkan email kamu',
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email tidak boleh kosong ya!';
                          }
                          if (!value.contains('@')) {
                            return 'Email tidak valid nih!';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password Input with Fun Design
                      _buildFunTextField(
                        controller: _passwordController,
                        icon: Icons.lock_rounded,
                        iconColor: Colors.purple.shade400,
                        hintText: 'Masukkan password kamu',
                        obscureText: !_isPasswordVisible,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey.shade600,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password tidak boleh kosong ya!';
                          }
                          if (value.length < 6) {
                            return 'Password minimal 6 karakter ya!';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Fun Login Button
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, Color(0xFF7B4ED6)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isLoading
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Sedang masuk...',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.rocket_launch,
                                        color: Colors.white),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Ayo Masuk!',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Forgot Password with Fun Design
                      Center(
                        child: TextButton(
                          onPressed: () {
                            // TODO: Tambahkan forgot password
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.help_outline,
                                color: AppColors.textSecondary,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Lupa Password?',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Fun footer decorations
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.favorite,
                              color: Colors.red.shade300, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Belajar itu Menyenangkan!',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.favorite,
                              color: Colors.red.shade300, size: 20),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCloud(Color color, double size) {
    return Container(
      width: size,
      height: size * 0.7,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size),
      ),
    );
  }

  Widget _buildFunTextField({
    required TextEditingController controller,
    required IconData icon,
    required Color iconColor,
    required String hintText,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontWeight: FontWeight.normal,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          errorStyle: TextStyle(
            color: AppColors.error,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
