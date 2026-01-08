import 'package:flutter/material.dart';
import 'package:education_game_app/constants/app_colors.dart';
import 'package:education_game_app/models/assessment_result_model.dart';
import 'package:education_game_app/services/api_service.dart';
import 'package:education_game_app/widgets/custom_button.dart';
import 'package:education_game_app/screens/dashboard_screen.dart';

class AssessmentResultReviewScreen extends StatefulWidget {
  const AssessmentResultReviewScreen({Key? key}) : super(key: key);

  @override
  _AssessmentResultReviewScreenState createState() =>
      _AssessmentResultReviewScreenState();
}

class _AssessmentResultReviewScreenState
    extends State<AssessmentResultReviewScreen> {
  bool _isLoading = true;
  AssessmentResult? _assessmentResult;

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = ApiService();
      final response = await apiService.getAssessmentSumatifResults();

      if (response.success && response.data != null) {
        setState(() {
          _assessmentResult = response.data!;
          _isLoading = false;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.error ?? 'Gagal memuat hasil assessment'),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.of(context).pop();
        }
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.of(context).pop();
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Colors.blue.shade50,
              Colors.purple.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                )
              : _assessmentResult == null
                  ? const Center(
                      child: Text('Tidak ada data hasil assessment'),
                    )
                  : Column(
                      children: [
                        // Header with Score
                        _buildHeader(),
                        // Results List
                        Expanded(
                          child: _buildResultsList(),
                        ),
                        // Back Button
                        _buildBackButton(),
                      ],
                    ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    if (_assessmentResult == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.quiz,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Review Hasil Assessment',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Score Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, Colors.purple.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Skor',
                  _assessmentResult!.skor.toStringAsFixed(
                      _assessmentResult!.skor % 1 == 0 ? 0 : 2),
                  Colors.white,
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withOpacity(0.3),
                ),
                _buildStatItem(
                  'Benar',
                  '${_assessmentResult!.jawabanBenar}',
                  Colors.green.shade200,
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withOpacity(0.3),
                ),
                _buildStatItem(
                  'Salah',
                  '${_assessmentResult!.jawabanSalah}',
                  Colors.red.shade200,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildResultsList() {
    if (_assessmentResult == null) return const SizedBox.shrink();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _assessmentResult!.results.length,
      itemBuilder: (context, index) {
        final item = _assessmentResult!.results[index];
        return _buildQuestionCard(item, index + 1);
      },
    );
  }

  Widget _buildQuestionCard(AssessmentResultItem item, int questionNumber) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question Header
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color:
                      item.benar ? Colors.green.shade100 : Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item.benar ? Icons.check_circle : Icons.cancel,
                      color: item.benar ? Colors.green : Colors.red,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Soal $questionNumber',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: item.benar
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Question Text
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              item.soal,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Options
          ...item.options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            final letter = String.fromCharCode(65 + index); // A, B, C, D
            final isUserAnswer =
                item.jawabanUser?.toLowerCase() == letter.toLowerCase();
            final isCorrectAnswer =
                item.jawabanBenar.toLowerCase() == letter.toLowerCase();

            Color backgroundColor;
            Color borderColor;
            Color textColor;
            Widget? suffixIcon;

            if (item.benar && isUserAnswer) {
              // Correct answer selected
              backgroundColor = Colors.green.shade50;
              borderColor = Colors.green;
              textColor = Colors.green.shade700;
              suffixIcon =
                  const Icon(Icons.check_circle, color: Colors.green, size: 20);
            } else if (!item.benar && isUserAnswer) {
              // Wrong answer selected
              backgroundColor = Colors.red.shade50;
              borderColor = Colors.red;
              textColor = Colors.red.shade700;
              suffixIcon =
                  const Icon(Icons.cancel, color: Colors.red, size: 20);
            } else if (!item.benar && isCorrectAnswer) {
              // Correct answer (shown when user answered wrong)
              backgroundColor = Colors.green.shade50;
              borderColor = Colors.green;
              textColor = Colors.green.shade700;
              suffixIcon =
                  const Icon(Icons.check_circle, color: Colors.green, size: 20);
            } else {
              // Other options
              backgroundColor = Colors.grey.shade50;
              borderColor = Colors.grey.shade300;
              textColor = Colors.black87;
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: borderColor,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: borderColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        letter,
                        style: TextStyle(
                          color: backgroundColor == Colors.grey.shade50
                              ? Colors.black54
                              : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: 15,
                        color: textColor,
                        fontWeight: (isUserAnswer || isCorrectAnswer)
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (suffixIcon != null) ...[
                    const SizedBox(width: 8),
                    suffixIcon,
                  ],
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: CustomButton(
          text: '🏠 Kembali ke Home',
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const DashboardScreen(),
              ),
              (route) => false,
            );
          },
          color: AppColors.primary,
        ),
      ),
    );
  }
}
