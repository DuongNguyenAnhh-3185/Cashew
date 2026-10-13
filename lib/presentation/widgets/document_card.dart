import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../domain/entities/document_entity.dart';
import '../controllers/document_controller.dart';
import 'delete_confirm_dialog.dart';
import 'share_document_dialog.dart';

/// Thẻ hiển thị tài liệu học tập có hỗ trợ phân quyền và tải/mở tệp Firebase Storage
class DocumentCard extends StatefulWidget {
  final DocumentEntity document;
  final DocumentController controller;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final bool isGridMode;

  const DocumentCard({
    super.key,
    required this.document,
    required this.controller,
    required this.onTap,
    required this.onEdit,
    this.isGridMode = false,
  });

  @override
  State<DocumentCard> createState() => _DocumentCardState();
}

class _DocumentCardState extends State<DocumentCard> {
  bool _isDownloading = false;

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

  IconData _getFileIcon(String fmt) {
    switch (fmt.toUpperCase()) {
      case 'PDF':
        return Icons.picture_as_pdf_rounded;
      case 'DOC':
      case 'DOCX':
        return Icons.description_rounded;
      case 'PPT':
        return Icons.slideshow_rounded;
      case 'XLS':
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

  String _formatFileSize(int bytes) {
    if (bytes <= 0) return '0 KB';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Widget _buildRoleBadge(ThemeData theme) {
    final role = widget.document.currentUserRole;
    Color bg;
    Color fg;
    String label;
    IconData icon;

    if (role == 'owner') {
      bg = Colors.blue.withOpacity(0.12);
      fg = Colors.blue.shade700;
      label = 'Chủ sở hữu';
      icon = Icons.verified_user_rounded;
    } else if (role == 'editor') {
      bg = Colors.orange.withOpacity(0.12);
      fg = Colors.deepOrange;
      label = 'Biên tập viên';
      icon = Icons.edit_note_rounded;
    } else {
      bg = Colors.grey.withOpacity(0.15);
      fg = Colors.grey.shade800;
      label = 'Người xem';
      icon = Icons.visibility_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDownloadAndOpen() async {
    setState(() => _isDownloading = true);
    final result = await widget.controller.downloadAndOpenFile(widget.document);
    if (mounted) {
      setState(() => _isDownloading = false);
      if (!result.isSuccess || result.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.errorMessage ?? 'Tải tệp thành công!'),
            backgroundColor: result.isSuccess ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  void _handleShare() {
    if (!widget.document.canShare) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chỉ chủ sở hữu tài liệu mới có quyền chia sẻ.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    ShareDocumentDialog.show(
      context,
      document: widget.document,
      controller: widget.controller,
    );
  }

  Future<void> _handleDelete() async {
    if (!widget.document.canDelete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bạn không có quyền xóa tài liệu này (Chỉ chủ sở hữu mới có quyền xóa).'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final confirm = await DeleteConfirmDialog.show(context, widget.document);

    if (confirm == true && mounted) {
      final success = await widget.controller.deleteDocument(widget.document);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Đã xóa tài liệu và tệp thành công!' : 'Xóa thất bại.'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fileColor = _getFileColor(widget.document.fileType);
    final fileIcon = _getFileIcon(widget.document.fileType);

    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hàng trên: Biểu tượng tệp, Tiêu đề, Badge quyền và Nút Popup Menu
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: fileColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(fileIcon, color: fileColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.document.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _buildRoleBadge(theme),
                            const SizedBox(width: 8),
                            Text(
                              widget.document.subject,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Menu Tùy chọn 3 chấm
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    onSelected: (val) {
                      switch (val) {
                        case 'open':
                          _handleDownloadAndOpen();
                          break;
                        case 'edit':
                          if (widget.document.canEdit) {
                            widget.onEdit();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Bạn chỉ có quyền xem, không được chỉnh sửa.'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          }
                          break;
                        case 'share':
                          _handleShare();
                          break;
                        case 'delete':
                          _handleDelete();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'open',
                        child: Row(
                          children: [
                            Icon(Icons.open_in_new_rounded, size: 18),
                            SizedBox(width: 8),
                            Text('Mở / Tải tệp'),
                          ],
                        ),
                      ),
                      if (widget.document.canEdit)
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, size: 18),
                              SizedBox(width: 8),
                              Text('Chỉnh sửa'),
                            ],
                          ),
                        ),
                      if (widget.document.canShare)
                        const PopupMenuItem(
                          value: 'share',
                          child: Row(
                            children: [
                              Icon(Icons.person_add_alt_outlined, size: 18),
                              SizedBox(width: 8),
                              Text('Chia sẻ'),
                            ],
                          ),
                        ),
                      if (widget.document.canDelete)
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline, size: 18, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Xóa tài liệu', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),

              // Mô tả ngắn nếu có
              if (widget.document.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  widget.document.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodySmall?.color,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 12),
              // Thông tin file và Nút Tải/Mở
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.attachment_rounded, size: 16, color: fileColor),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        widget.document.fileName.isNotEmpty
                            ? widget.document.fileName
                            : 'Đính kèm (${widget.document.fileType})',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      _formatFileSize(widget.document.fileSize),
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Nút Mở / Tải nhanh
                    InkWell(
                      onTap: _isDownloading ? null : _handleDownloadAndOpen,
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: fileColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: _isDownloading
                            ? SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: fileColor,
                                ),
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.download_rounded, size: 13, color: fileColor),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Mở tệp',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: fileColor,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),
              // Ngày tạo và chủ sở hữu nếu được chia sẻ
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Cập nhật: ${DateFormatter.formatRelativeTime(widget.document.updatedAt)}',
                    style: TextStyle(fontSize: 11, color: theme.textTheme.bodySmall?.color),
                  ),
                  if (widget.document.ownerEmail != null && !widget.document.isOwner)
                    Text(
                      'Bởi: ${widget.document.ownerEmail}',
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.primary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}