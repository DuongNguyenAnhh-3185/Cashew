import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/file_size_helper.dart';
import '../../domain/entities/document_entity.dart';
import '../../domain/entities/document_type.dart';
import '../controllers/document_controller.dart';
import '../widgets/document_card.dart';
import '../widgets/document_stats_header.dart';
import '../widgets/empty_documents_view.dart';
import '../widgets/search_and_filter_bar.dart';
import '../widgets/type_filter_chips.dart';
import 'document_detail_page.dart';
import 'document_form_page.dart';

/// Màn hình chính (Dashboard) của Ứng dụng Quản lý Tài liệu Học tập theo kiến trúc Cashew
/// Hỗ trợ 4 tab điều hướng chuẩn Material 3: Tổng quan, Chuyên mục, Yêu thích, Thống kê
class HomePage extends StatefulWidget {
  final DocumentController controller;
  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  const HomePage({
    super.key,
    required this.controller,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentTabIndex = 0;

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
                Text('• UseCases Layer: AddDocumentUseCase, UpdateDocumentUseCase, DeleteDocumentUseCase, SearchDocumentsUseCase, WatchDocumentsUseCase.'),
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
        content: const Text('Toàn bộ tài liệu sẽ được hoàn nguyên về danh sách bài giảng, bài tập mẫu chuẩn ban đầu.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.warning),
            onPressed: () {
              Navigator.of(context).pop();
              widget.controller.resetToDefaultData();
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

  void _navigateToForm({DocumentEntity? docToEdit}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DocumentFormPage(
          controller: widget.controller,
          documentToEdit: docToEdit,
        ),
      ),
    );
  }

  void _navigateToDetail(String docId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DocumentDetailPage(
          documentId: docId,
          controller: widget.controller,
        ),
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
            icon: Icon(widget.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
            tooltip: widget.isDarkMode ? 'Chế độ sáng' : 'Chế độ tối',
            onPressed: widget.onToggleTheme,
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
        listenable: widget.controller,
        builder: (context, _) {
          if (widget.controller.isLoading && widget.controller.allDocuments.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          switch (_currentTabIndex) {
            case 0:
              return _buildDashboardTab(isDark);
            case 1:
              return _buildCategoriesTab(isDark);
            case 2:
              return _buildFavoritesTab(isDark);
            case 3:
              return _buildAnalyticsTab(isDark);
            default:
              return _buildDashboardTab(isDark);
          }
        },
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentTabIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentTabIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded, color: AppColors.primary),
            label: 'Tổng quan',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder_rounded, color: AppColors.primary),
            label: 'Chuyên mục',
          ),
          NavigationDestination(
            icon: Icon(Icons.star_outline_rounded),
            selectedIcon: Icon(Icons.star_rounded, color: AppColors.favorite),
            label: 'Yêu thích',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics_rounded, color: AppColors.primary),
            label: 'Thống kê',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add_rounded),
        label: const Text('Thêm tài liệu', style: TextStyle(fontWeight: FontWeight.w700)),
        onPressed: () => _navigateToForm(),
      ),
    );
  }

  /// TAB 0: TỔNG QUAN (Dashboard chính kèm Thống kê, Tìm kiếm, Lọc và Danh sách)
  Widget _buildDashboardTab(bool isDark) {
    final filteredDocs = widget.controller.filteredDocuments;

    return CustomScrollView(
      slivers: [
        // Thống kê tổng quan phong cách Cashew
        SliverToBoxAdapter(
          child: DocumentStatsHeader(controller: widget.controller),
        ),

        // Thanh tìm kiếm và bộ lọc môn học, sắp xếp
        SliverToBoxAdapter(
          child: SearchAndFilterBar(controller: widget.controller),
        ),

        // Chip chọn loại tài liệu
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 10),
            child: TypeFilterChips(controller: widget.controller),
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
                  'Hiển thị ${filteredDocs.length} / ${widget.controller.totalDocumentsCount} tài liệu',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                if (widget.controller.sortOption.displayName.isNotEmpty)
                  Text(
                    widget.controller.sortOption.displayName,
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
              controller: widget.controller,
              onAddDocument: () => _navigateToForm(),
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
                    controller: widget.controller,
                    onTap: () => _navigateToDetail(doc.id),
                    onEdit: () => _navigateToForm(docToEdit: doc),
                  );
                },
                childCount: filteredDocs.length,
              ),
            ),
          ),
      ],
    );
  }

  /// TAB 1: CHUYÊN MỤC (Duyệt theo 5 nhóm tài liệu chuẩn Cashew)
  Widget _buildCategoriesTab(bool isDark) {
    final types = DocumentType.values;
    final totalCount = widget.controller.totalDocumentsCount;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '5 Nhóm Tài Liệu Học Tập',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                'Phân loại học liệu theo chuyên môn chuẩn kiến trúc Cashew',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
        ...types.map((type) {
          final docsOfType = widget.controller.allDocuments.where((d) => d.type == type).toList();
          final count = docsOfType.length;
          final totalBytes = docsOfType.fold(0, (sum, d) => sum + d.fileSizeBytes);
          final percent = totalCount > 0 ? (count / totalCount) : 0.0;

          return Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            color: isDark ? AppColors.surfaceDark : Colors.white,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                widget.controller.clearAllFilters();
                widget.controller.setSelectedType(type);
                setState(() => _currentTabIndex = 0);
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: type.color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(type.icon, color: type.color, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                type.displayName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$count tài liệu • ${FileSizeHelper.formatBytes(totalBytes)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: isDark ? Colors.white38 : Colors.black26,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percent,
                        backgroundColor: isDark ? Colors.white10 : Colors.black12,
                        valueColor: AlwaysStoppedAnimation<Color>(type.color),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Chiếm ${(percent * 100).toStringAsFixed(1)}% kho lưu trữ',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                        Text(
                          'Khám phá →',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: type.color,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  /// TAB 2: ĐÃ GHIM / YÊU THÍCH (Favorites)
  Widget _buildFavoritesTab(bool isDark) {
    final favDocs = widget.controller.allDocuments.where((d) => d.isFavorite).toList();

    return favDocs.isEmpty
        ? Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.favorite.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.star_outline_rounded,
                        size: 48, color: AppColors.favorite),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Chưa có tài liệu yêu thích',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hãy bấm biểu tượng ngôi sao trên các bài giảng hoặc đề thi quan trọng để ghim nhanh vào danh sách ôn tập!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
          )
        : ListView(
            padding: const EdgeInsets.fromLTRB(0, 16, 0, 90),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded, color: AppColors.favorite, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Tài liệu Đã Ghim (${favDocs.length})',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
              ...favDocs.map(
                (doc) => DocumentCard(
                  document: doc,
                  controller: widget.controller,
                  onTap: () => _navigateToDetail(doc.id),
                  onEdit: () => _navigateToForm(docToEdit: doc),
                ),
              ),
            ],
          );
  }

  /// TAB 3: THỐNG KÊ & DUNG LƯỢNG (Storage Analytics)
  Widget _buildAnalyticsTab(bool isDark) {
    final totalBytes = widget.controller.totalStorageBytes;
    final totalDocs = widget.controller.totalDocumentsCount;
    final favCount = widget.controller.favoritesCount;

    // Phân nhóm theo định dạng tệp
    final Map<String, int> formatCounts = {};
    for (final doc in widget.controller.allDocuments) {
      final fmt = doc.fileFormat.toUpperCase();
      formatCounts[fmt] = (formatCounts[fmt] ?? 0) + 1;
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
      children: [
        const Text(
          'Thống Kê Kho Lưu Trữ',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          'Phân tích chi tiết dung lượng học liệu theo kiến trúc Cashew',
          style: TextStyle(
            fontSize: 13,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 16),

        // Thẻ Tổng dung lượng
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
          ),
          color: isDark ? AppColors.surfaceDark : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tổng dung lượng học liệu',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('Bộ nhớ máy',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  FileSizeHelper.formatBytes(totalBytes),
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.primary),
                ),
                const SizedBox(height: 6),
                Text('$totalDocs tài liệu lưu trữ • $favCount tài liệu đánh dấu sao',
                    style: TextStyle(fontSize: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),
        const Text('Phân Bố Định Dạng Tệp',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),

        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: formatCounts.entries.map((entry) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      entry.key,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${entry.value} tệp',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ],
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 24),
        const Text('Danh Mục Môn Học Đang Quản Lý',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),

        ...widget.controller.availableSubjects
            .where((s) => s != 'Tất cả')
            .map((subject) {
          final countInSubject = widget.controller.allDocuments
              .where((d) => d.subject == subject)
              .length;
          return Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            color: isDark ? AppColors.surfaceDark : Colors.white,
            child: ListTile(
              leading: const Icon(Icons.menu_book_rounded, color: AppColors.primary, size: 20),
              title: Text(subject, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              trailing: Text(
                '$countInSubject tài liệu',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              onTap: () {
                widget.controller.clearAllFilters();
                widget.controller.setSelectedSubject(subject);
                setState(() => _currentTabIndex = 0);
              },
            ),
          );
        }),
      ],
    );
  }
}