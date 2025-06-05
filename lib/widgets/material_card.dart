// lib/widgets/material_card.dart
import 'package:flutter/material.dart';
import 'package:education_game_app/constants/app_colors.dart';
import 'package:education_game_app/models/material_model.dart' as model;

class MaterialCard extends StatelessWidget {
  final model.Material material;
  final VoidCallback onTap;

  const MaterialCard({
    Key? key,
    required this.material,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: material.isLocked ? AppColors.disabledItem : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon berdasarkan tipe materi dan statusnya
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _getBackgroundColor(),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      _getIcon(),
                      size: 32,
                      color: _getIconColor(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        material.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: material.isLocked
                              ? Colors.grey
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        material.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: material.isLocked
                              ? Colors.grey
                              : AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (material.isCompleted)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: AppColors.success,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'Selesai',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                if (material.isLocked)
                  const Icon(
                    Icons.lock,
                    color: Colors.grey,
                  )
                else if (material.isCompleted)
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                  )
                else
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.primary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (material.isLocked) {
      return Colors.grey.shade300;
    }
    if (material.isCompleted) {
      return AppColors.success.withOpacity(0.1);
    }
    if (material.type == model.MaterialType.PDF) {
      return Colors.red.withOpacity(0.1);
    }
    return Colors.blue.withOpacity(0.1); // Video
  }

  IconData _getIcon() {
    if (material.isLocked) {
      return Icons.lock;
    }
    if (material.isCompleted) {
      return Icons.check_circle;
    }
    if (material.type == model.MaterialType.PDF) {
      return Icons.picture_as_pdf;
    }
    return Icons.video_library; // Video
  }

  Color _getIconColor() {
    if (material.isLocked) {
      return Colors.grey;
    }
    if (material.isCompleted) {
      return AppColors.success;
    }
    if (material.type == model.MaterialType.PDF) {
      return Colors.red;
    }
    return Colors.blue; // Video
  }
}
