import 'package:flutter/material.dart';
import 'package:education_game_app/constants/app_colors.dart';

class QuizOption extends StatelessWidget {
  final String option;
  final int index;
  final bool isSelected;
  final bool isCorrect;
  final bool isWrong;
  final VoidCallback? onTap;

  const QuizOption({
    Key? key,
    required this.option,
    required this.index,
    required this.isSelected,
    required this.isCorrect,
    required this.isWrong,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Menentukan warna latar belakang berdasarkan status
    Color backgroundColor;
    Color borderColor;
    Color textColor;
    IconData? trailingIcon;

    if (isCorrect) {
      backgroundColor = AppColors.success.withOpacity(0.1);
      borderColor = AppColors.success;
      textColor = AppColors.success;
      trailingIcon = Icons.check_circle;
    } else if (isWrong) {
      backgroundColor = AppColors.error.withOpacity(0.1);
      borderColor = AppColors.error;
      textColor = AppColors.error;
      trailingIcon = Icons.cancel;
    } else if (isSelected) {
      backgroundColor = AppColors.primary.withOpacity(0.1);
      borderColor = AppColors.primary;
      textColor = AppColors.primary;
      trailingIcon = null;
    } else {
      backgroundColor = Colors.transparent;
      borderColor = Colors.grey.shade300;
      textColor = AppColors.textPrimary;
      trailingIcon = null;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: borderColor,
              ),
            ),
            child: Row(
              children: [
                // Indikator pilihan (A, B, C, D)
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isSelected || isCorrect || isWrong
                        ? borderColor
                        : Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      String.fromCharCode(65 + index), // A, B, C, D, ...
                      style: TextStyle(
                        color: isSelected || isCorrect || isWrong
                            ? Colors.white
                            : Colors.grey.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Teks pilihan
                Expanded(
                  child: Text(
                    option,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: isSelected || isCorrect || isWrong
                          ? FontWeight.w500
                          : FontWeight.normal,
                    ),
                  ),
                ),
                // Icon status (jika ada)
                if (trailingIcon != null)
                  Icon(
                    trailingIcon,
                    color: borderColor,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
