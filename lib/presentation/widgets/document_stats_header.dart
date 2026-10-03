import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/file_size_helper.dart';
import '../../domain/entities/document_type.dart';
import '../controllers/document_controller.dart';

/// Khối thống kê tổng quan theo phong cách thiết kế đặc trưng của Cashew
class DocumentStatsHeader extends StatelessWidget {
  final DocumentController controller;

  const DocumentStatsHeader({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kho Tài Liệu Học Tập',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${controller.totalDocumentsCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'tài liệu',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Nút lọc nhanh tài liệu yêu thích
              InkWell(
                onTap: () => controller.toggleOnlyFavorites(),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: controller.onlyFavorites
                        ? AppColors.accent
                        : Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: controller.onlyFavorites
                          ? AppColors.accent
                          : Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        controller.onlyFavorites
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: controller.onlyFavorites
                            ? Colors.black87
                            : Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${controller.favoritesCount} Yêu thích',
                        style: TextStyle(
                          color: controller.onlyFavorites
                              ? Colors.black87
                              : Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Các thẻ chỉ số nhanh: Dung lượng + Từng loại tài liệu
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildMetricChip(
                  icon: Icons.storage_rounded,
                  label: 'Dung lượng',
                  value: FileSizeHelper.formatBytes(controller.totalStorageBytes),
                ),
                const SizedBox(width: 8),
                _buildMetricChip(
                  icon: Icons.menu_book_rounded,
                  label: 'Bài giảng',
                  value: '${controller.getCountByType(DocumentType.lecture)}',
                ),
                const SizedBox(width: 8),
                _buildMetricChip(
                  icon: Icons.assignment_rounded,
                  label: 'Bài tập',
                  value: '${controller.getCountByType(DocumentType.exercise)}',
                ),
                const SizedBox(width: 8),
                _buildMetricChip(
                  icon: Icons.quiz_rounded,
                  label: 'Đề thi',
                  value: '${controller.getCountByType(DocumentType.exam)}',
                ),
                const SizedBox(width: 8),
                _buildMetricChip(
                  icon: Icons.auto_stories_rounded,
                  label: 'Tham khảo',
                  value: '${controller.getCountByType(DocumentType.reference)}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white70),
          const SizedBox(width: 5),
          Text(
            '$label: ',
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}