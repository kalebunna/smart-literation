import 'package:flutter/material.dart';
import 'package:education_game_app/constants/app_colors.dart';

class ScoreDisplay extends StatelessWidget {
  final int score;
  final int totalScore;
  final String label;

  const ScoreDisplay({
    Key? key,
    required this.score,
    required this.totalScore,
    this.label = 'Skor',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final percentage = (score / totalScore) * 100;
    final Color color = _getScoreColor(percentage);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              children: [
                CircularProgressIndicator(
                  value: percentage / 100,
                  strokeWidth: 10,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$score/$totalScore',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${percentage.round()}%',
                        style: TextStyle(
                          fontSize: 14,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (index) => Icon(
                index < _getStarCount(percentage)
                    ? Icons.star
                    : Icons.star_border,
                color: Colors.amber,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _getStarCount(double percentage) {
    if (percentage >= 90) return 5;
    if (percentage >= 80) return 4;
    if (percentage >= 70) return 3;
    if (percentage >= 60) return 2;
    return 1;
  }

  Color _getScoreColor(double percentage) {
    if (percentage >= 80) return AppColors.success;
    if (percentage >= 60) return Colors.amber;
    return AppColors.error;
  }
}
