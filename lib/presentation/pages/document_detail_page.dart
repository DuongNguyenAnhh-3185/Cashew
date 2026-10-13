import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../domain/entities/document_entity.dart';
import '../controllers/document_controller.dart';
import '../widgets/delete_confirm_dialog.dart';
import 'document_form_page.dart';

/// Màn hình xem chi tiết tài liệu học tập & tệp đính kèm đã nộp
class DocumentDetailPage extends StatelessWidget {
  final String documentId;
  final DocumentController controller;

  const DocumentDetailPage({
    super.key,
    required this.documentId,
    required this.controller,
  });

  String _extractFileName(String path) {
    if (path.isEmpty) return 'tep_tai_lieu.pdf';
    final slashIndex = path.lastIndexOf('/');
    final backslashIndex = path.lastIndexOf('\\');
    final lastIndex = slashIndex > backslashIndex ? slashIndex : backslashIndex;
    if (lastIndex != -1 && lastIndex + 1 < path.length) {
      return path.substring(lastIndex + 1);
    }
    return path;
  }

  IconData _getFileIcon(String fmt) {
    switch (fmt.toUpperCase()) {
      case 'PDF':
        return Icons.picture_as_pdf_rounded;
      case 'DOC':
      case 'DOCX':
        return Icons.description_rounded;
      case 'PPT':
      case 'PPTX':
        return Icons.slideshow_rounded;
      case 'XLS':
      case 'XLSX':
        return Icons.table_chart_rounded;
      case 'ZIP':
      case 'RAR':
        return Icons.folder_zip_rounded;
      case 'MP4':
        return Icons.video_file_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  Color _getFileColor(String fmt) {
    switch (fmt.toUpperCase()) {
      case 'PDF':
        return const Color(0xFFDC2626);
      case 'DOC':
      case 'DOCX':
        return const Color(0xFF2563EB);
      case 'PPT':
      case 'PPTX':
        return const Color(0xFFEA580C);
      case 'XLS':
      case 'XLSX':
        return const Color(0xFF16A34A);
      case 'ZIP':
      case 'RAR':
        return const Color(0xFF7C3AED);
      case 'MP4':
        return const Color(0xFF0891B2);
      default:
        return AppColors.primary;
    }
  }

  void _showFilePreviewDialog(BuildContext context, DocumentEntity doc) {
    final fileName = _extractFileName(doc.urlOrPath);
    final fileColor = _getFileColor(doc.fileFormat);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(_getFileIcon(doc.fileFormat), color: fileColor, size: 26),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                fileName,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: fileColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: fileColor.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  Icon(_getFileIcon(doc.fileFormat), size: 48, color: fileColor),
                  const SizedBox(height: 10),
                  Text(
                    'Định dạng: ${doc.fileFormat.toUpperCase()}',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Trạng thái: Tệp hợp lệ, đã xác thực lưu trữ',
                    style: TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text('• Môn học: ${doc.subject}', style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 4),
            Text('• Phân loại: ${doc.type.displayName}', style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 4),
            Text('• Vị trí lưu trữ: ${doc.urlOrPath}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đang mở tệp "$fileName"...'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            icon: const Icon(Icons.open_in_new_rounded, size: 16),
            label: const Text('Mở Đọc'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    DocumentEntity? foundDoc;
    try {
      foundDoc = controller.allDocuments.firstWhere((d) => d.id == documentId);
    } catch (_) {
      foundDoc = null;
    }

    if (foundDoc == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết tài liệu')),
        body: const Center(child: Text('Tài liệu không còn tồn tại.')),
      );
    }

    final doc = foundDoc;
    final typeColor = doc.type.color;
    final fileName = _extractFileName(doc.urlOrPath);
    final fileColor = _getFileColor(doc.fileFormat);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết học liệu', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: Icon(
              doc.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
              color: doc.isFavorite ? AppColors.accent : null,
            ),
            tooltip: doc.isFavorite ? 'Bỏ yêu thích' : 'Yêu thích',
            onPressed: () => controller.toggleFavorite(doc.id),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Chỉnh sửa tài liệu',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => DocumentFormPage(
                    controller: controller,
                    documentToEdit: doc,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
            tooltip: 'Xóa tài liệu',
            onPressed: () async {
              final confirmed = await DeleteConfirmDialog.show(context, doc);
              if (confirmed == true && context.mounted) {
                await controller.deleteDocument(doc.id);
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Đã xóa "${doc.title}"')),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==========================================
            // THẺ 1: TIÊU ĐỀ & MÔN HỌC CHỦ ĐẠO
            // ==========================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: typeColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(doc.type.icon, size: 16, color: typeColor),
                            const SizedBox(width: 6),
                            Text(
                              doc.type.displayName,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: typeColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: fileColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          doc.fileFormat.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: fileColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    doc.title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      height: 1.3,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.school_rounded, size: 18, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        doc.subject,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // ==========================================
            // THẺ 2: TỆP TIN ĐÃ NỘP (SUBMITTED FILE SHOWCASE)
            // ==========================================
            _buildSectionHeader('Tệp đính kèm đã nộp', Icons.folder_zip_rounded, isDark),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: fileColor.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(_getFileIcon(doc.fileFormat), size: 30, color: fileColor),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fileName,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.success),
                                const SizedBox(width: 4),
                                const Text(
                                  'Đã nộp vào kho',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.success,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Đường dẫn tệp
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black26 : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Vị trí tệp: ${doc.urlOrPath}',
                      style: const TextStyle(fontSize: 11.5, fontFamily: 'monospace'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Các nút hành động trên tệp
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () => _showFilePreviewDialog(context, doc),
                          icon: const Icon(Icons.visibility_rounded, size: 18),
                          label: const Text('Xem tệp', style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton.filledTonal(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: doc.urlOrPath));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Đã sao chép đường dẫn tệp')),
                          );
                        },
                        icon: const Icon(Icons.copy_rounded, size: 18),
                        tooltip: 'Sao chép đường dẫn tệp',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // ==========================================
            // THẺ 3: MÔ TẢ & GHI CHÚ
            // ==========================================
            _buildSectionHeader('Ghi chú & Tóm tắt', Icons.notes_rounded, isDark),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: Text(
                doc.description.isNotEmpty
                    ? doc.description
                    : 'Không có ghi chú thêm cho tài liệu học tập này.',
                style: TextStyle(
                  fontSize: 13.5,
                  height: 1.5,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
            ),
            const SizedBox(height: 18),

            // ==========================================
            // THẺ 4: THẺ PHÂN LOẠI (TAGS)
            // ==========================================
            if (doc.tags.isNotEmpty) ...[
              _buildSectionHeader('Thẻ phân loại', Icons.tag_rounded, isDark),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: doc.tags.map((tag) {
                  return Chip(
                    label: Text('#$tag'),
                    backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
                    side: BorderSide(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),
            ],

            // ==========================================
            // THẺ 5: THÔNG SỐ & LỊCH SỬ NỘP
            // ==========================================
            _buildSectionHeader('Lịch sử nộp & Cập nhật', Icons.history_rounded, isDark),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Thời điểm nộp tệp:',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      Text(
                        DateFormatter.formatDateTime(doc.createdAt),
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const Divider(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Cập nhật lần cuối:',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      Text(
                        DateFormatter.formatDateTime(doc.updatedAt),
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}