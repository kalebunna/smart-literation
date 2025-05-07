import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:education_game_app/constants/app_colors.dart';
import 'package:education_game_app/constants/app_styles.dart';
import 'package:education_game_app/providers/user_provider.dart';
import 'package:education_game_app/screens/dashboard_screen.dart';
import 'package:education_game_app/widgets/custom_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Untuk dummy, kita langsung login saja
        await Future.delayed(const Duration(seconds: 2));

        // Panggil login di provider untuk kondisi API sebenarnya
        // await Provider.of<UserProvider>(context, listen: false).login(
        //   _emailController.text,
        //   _passwordController.text,
        // );

        // Dummy data untuk user
        Provider.of<UserProvider>(context, listen: false).setDummyUser();

        // Navigate to dashboard
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      } catch (e) {
        // Tampilkan pesan error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login gagal: ${e.toString()}')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo dan judul
                  const Icon(
                    Icons.school,
                    size: 80,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Selamat Datang',
                    textAlign: TextAlign.center,
                    style: AppStyles.heading1,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Silahkan login untuk melanjutkan',
                    textAlign: TextAlign.center,
                    style: AppStyles.bodyMedium,
                  ),
                  const SizedBox(height: 32),

                  // Email input
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: AppStyles.inputDecoration('Email'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email tidak boleh kosong';
                      }
                      if (!value.contains('@')) {
                        return 'Email tidak valid';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password input
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: AppStyles.inputDecoration('Password'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password tidak boleh kosong';
                      }
                      if (value.length < 6) {
                        return 'Password minimal 6 karakter';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Login button
                  CustomButton(
                    text: 'Login',
                    isLoading: _isLoading,
                    onPressed: _login,
                  ),
                  const SizedBox(height: 16),

                  // Forgot password
                  TextButton(
                    onPressed: () {
                      // TODO: Implementasi forgot password
                    },
                    child: const Text(
                      'Lupa Password?',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
