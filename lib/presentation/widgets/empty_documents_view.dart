import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../controllers/document_controller.dart';

/// Giao diện trạng thái rỗng khi không có tài liệu hoặc không khớp kết quả tìm kiếm
class EmptyDocumentsView extends StatelessWidget {
  final DocumentController controller;
  final VoidCallback onAddDocument;

  const EmptyDocumentsView({
    super.key,
    required this.controller,
    required this.onAddDocument,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasActiveFilter = controller.searchQuery.isNotEmpty ||
        controller.selectedSubject != null ||
        controller.selectedType != null ||
        controller.onlyFavorites;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.surfaceDark : Colors.white),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                hasActiveFilter ? Icons.search_off_rounded : Icons.folder_open_rounded,
                size: 56,
                color: hasActiveFilter ? AppColors.warning : AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              hasActiveFilter
                  ? 'Không tìm thấy tài liệu phù hợp'
                  : 'Chưa có tài liệu học tập nào',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              hasActiveFilter
                  ? 'Thử thay đổi từ khóa tìm kiếm hoặc đặt lại các bộ lọc môn học, loại tài liệu.'
                  : 'Hãy bắt đầu tạo tài liệu đầu tiên hoặc khôi phục dữ liệu mẫu để trải nghiệm.',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                if (hasActiveFilter) ...[
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Đặt lại bộ lọc'),
                    onPressed: () => controller.clearAllFilters(),
                  ),
                ] else ...[
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.add_rounded, size: 20),
                    label: const Text('Thêm tài liệu mới'),
                    onPressed: onAddDocument,
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.restore_page_rounded, size: 18),
                    label: const Text('Nạp dữ liệu mẫu'),
                    onPressed: () => controller.resetToDefaultData(),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}