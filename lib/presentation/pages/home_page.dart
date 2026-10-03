import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../controllers/document_controller.dart';
import '../widgets/document_card.dart';
import '../widgets/document_stats_header.dart';
import '../widgets/empty_documents_view.dart';
import '../widgets/search_and_filter_bar.dart';
import '../widgets/type_filter_chips.dart';
import 'document_detail_page.dart';
import 'document_form_page.dart';

/// Màn hình chính (Dashboard) của Ứng dụng Quản lý Tài liệu Học tập
class HomePage extends StatelessWidget {
  final DocumentController controller;
  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  const HomePage({
    super.key,
    required this.controller,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  void _showArchitectureDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: const [
              Icon(Icons.account_tree_rounded, color: AppColors.primary, size: 26),
              SizedBox(width: 10),
              Text('Kiến trúc Cashew', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'Ứng dụng được thiết kế phân tầng chuẩn hóa:',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                SizedBox(height: 10),
                Text('• Domain Layer: DocumentEntity, IDocumentRepository, DocumentFilterService, DocumentValidationService (Độc lập 100% với UI & Database).'),
                SizedBox(height: 6),
                Text('• Data Layer: DocumentModel (JSON serialization), DocumentLocalDataSource (SharedPreferences), DocumentRepositoryImpl (Reactive Streams).'),
                SizedBox(height: 6),
                Text('• Presentation Layer: DocumentController (ChangeNotifier), Các Pages (Home, Detail, Form) & Widgets mô-đun hóa.'),
                SizedBox(height: 6),
                Text('• Core Layer: AppColors, AppTheme (Material 3), AppConstants, DateFormatter, FileSizeHelper.'),
                SizedBox(height: 12),
                Text(
                  'Đảm bảo nguyên tắc SOLID, Clean Architecture và tính mở rộng cao.',
                  style: TextStyle(fontStyle: FontStyle.italic, color: AppColors.primary, fontSize: 12),
                ),
              ],
            ),
          ),
          actions: [
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }

  void _confirmResetData(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Khôi phục dữ liệu mẫu?'),
        content: const Text('Toàn bộ tài liệu sẽ được hoàn nguyên về danh sách bài giảng, bài tập mẫu ban đầu.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.warning),
            onPressed: () {
              Navigator.of(context).pop();
              controller.resetToDefaultData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã khôi phục dữ liệu học tập mẫu')),
              );
            },
            child: const Text('Khôi phục', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.school_rounded, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cashew StudyDocs',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                Text(
                  'Quản lý tài liệu học tập',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
            tooltip: isDarkMode ? 'Chế độ sáng' : 'Chế độ tối',
            onPressed: onToggleTheme,
          ),
          IconButton(
            icon: const Icon(Icons.restore_page_rounded),
            tooltip: 'Nạp lại dữ liệu mẫu',
            onPressed: () => _confirmResetData(context),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            tooltip: 'Thông tin kiến trúc Cashew',
            onPressed: () => _showArchitectureDialog(context),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          if (controller.isLoading && controller.allDocuments.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final filteredDocs = controller.filteredDocuments;

          return CustomScrollView(
            slivers: [
              // Thống kê tổng quan phong cách Cashew
              SliverToBoxAdapter(
                child: DocumentStatsHeader(controller: controller),
              ),

              // Thanh tìm kiếm và bộ lọc môn học, sắp xếp
              SliverToBoxAdapter(
                child: SearchAndFilterBar(controller: controller),
              ),

              // Chip chọn loại tài liệu
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 10),
                  child: TypeFilterChips(controller: controller),
                ),
              ),

              // Thông tin số lượng hiển thị
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Hiển thị ${filteredDocs.length} / ${controller.totalDocumentsCount} tài liệu',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      if (controller.sortOption.displayName.isNotEmpty)
                        Text(
                          controller.sortOption.displayName,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Danh sách tài liệu hoặc Màn hình rỗng
              if (filteredDocs.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyDocumentsView(
                    controller: controller,
                    onAddDocument: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => DocumentFormPage(controller: controller),
                        ),
                      );
                    },
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.only(bottom: 90),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final doc = filteredDocs[index];
                        return DocumentCard(
                          document: doc,
                          controller: controller,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => DocumentDetailPage(
                                  documentId: doc.id,
                                  controller: controller,
                                ),
                              ),
                            );
                          },
                          onEdit: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => DocumentFormPage(
                                  controller: controller,
                                  documentToEdit: doc,
                                ),
                              ),
                            );
                          },
                        );
                      },
                      childCount: filteredDocs.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add_rounded),
        label: const Text('Thêm tài liệu', style: TextStyle(fontWeight: FontWeight.w700)),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => DocumentFormPage(controller: controller),
            ),
          );
        },
      ),
    );
  }
}