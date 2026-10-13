import 'package:flutter/material.dart';
import '../../domain/entities/document_entity.dart';
import '../../domain/entities/document_permission_entity.dart';
import '../controllers/document_controller.dart';

/// Hộp thoại Quản lý Chia sẻ Tài liệu (Share & Permissions Management Dialog)
/// Cho phép Chủ sở hữu:
/// 1. Nhập email người nhận và gán vai trò 'viewer' hoặc 'editor'.
/// 2. Xem danh sách những người hiện đang được chia sẻ.
/// 3. Thay đổi vai trò (viewer <-> editor) của người được chia sẻ.
/// 4. Thu hồi quyền truy cập (Revoke permission).
class ShareDocumentDialog extends StatefulWidget {
  final DocumentEntity document;
  final DocumentController controller;

  const ShareDocumentDialog({
    super.key,
    required this.document,
    required this.controller,
  });

  static Future<void> show(
    BuildContext context, {
    required DocumentEntity document,
    required DocumentController controller,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => ShareDocumentDialog(
        document: document,
        controller: controller,
      ),
    );
  }

  @override
  State<ShareDocumentDialog> createState() => _ShareDocumentDialogState();
}

class _ShareDocumentDialogState extends State<ShareDocumentDialog> {
  final _emailController = TextEditingController();
  String _selectedRole = 'viewer';

  bool _isLoadingList = true;
  bool _isSharing = false;
  String? _statusError;
  String? _statusSuccess;

  List<DocumentPermissionEntity> _permissions = [];

  @override
  void initState() {
    super.initState();
    _loadPermissions();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadPermissions() async {
    setState(() {
      _isLoadingList = true;
      _statusError = null;
    });

    try {
      final list = await widget.controller.fetchPermissions(widget.document.id);
      if (mounted) {
        setState(() {
          _permissions = list;
          _isLoadingList = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingList = false;
          _statusError = 'Không thể tải danh sách quyền: $e';
        });
      }
    }
  }

  Future<void> _handleShare() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        _statusError = 'Vui lòng nhập địa chỉ email người nhận.';
      });
      return;
    }

    setState(() {
      _isSharing = true;
      _statusError = null;
      _statusSuccess = null;
    });

    final success = await widget.controller.shareDocument(
      documentId: widget.document.id,
      email: email,
      role: _selectedRole,
    );

    if (mounted) {
      setState(() {
        _isSharing = false;
        if (success) {
          _emailController.clear();
          _statusSuccess = 'Đã chia sẻ thành công cho $email!';
        } else {
          _statusError = widget.controller.errorMessage ?? 'Chia sẻ tài liệu thất bại.';
        }
      });

      if (success) {
        await _loadPermissions();
      }
    }
  }

  Future<void> _handleRoleChange(DocumentPermissionEntity perm, String newRole) async {
    if (perm.role == newRole) return;

    final success = await widget.controller.updatePermissionRole(
      permissionId: perm.id,
      role: newRole,
    );

    if (mounted) {
      if (success) {
        _loadPermissions();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.controller.errorMessage ?? 'Đổi quyền thất bại.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleRevoke(DocumentPermissionEntity perm) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Thu hồi quyền truy cập?'),
        content: Text(
          'Người dùng ${perm.userEmail ?? perm.userId} sẽ không thể truy cập tài liệu này nữa.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Thu hồi'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final success = await widget.controller.revokePermission(perm.id);
      if (mounted) {
        if (success) {
          _loadPermissions();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.controller.errorMessage ?? 'Thu hồi quyền thất bại.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 680),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tiêu đề Dialog
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.share_rounded,
                        color: colorScheme.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Chia sẻ tài liệu',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.document.title,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color?.withOpacity(0.8),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(height: 24),

              // Form nhập Email và chọn quyền
              Text(
                'Thêm người nhận mới',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: 'Nhập email tài khoản Google...',
                        prefixIcon: const Icon(Icons.email_outlined, size: 20),
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: _selectedRole,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'viewer',
                          child: Text('Người xem', style: TextStyle(fontSize: 13)),
                        ),
                        DropdownMenuItem(
                          value: 'editor',
                          child: Text('Người sửa', style: TextStyle(fontSize: 13)),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedRole = val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Nút Chia sẻ
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: _isSharing ? null : _handleShare,
                  icon: _isSharing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.person_add_alt_1_rounded, size: 18),
                  label: Text(_isSharing ? 'Đang chia sẻ...' : 'Chia sẻ'),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),

              // Thông báo trạng thái nếu có
              if (_statusSuccess != null) ...[
                const SizedBox(height: 8),
                Text(
                  _statusSuccess!,
                  style: const TextStyle(color: Colors.green, fontSize: 13),
                ),
              ],
              if (_statusError != null) ...[
                const SizedBox(height: 8),
                Text(
                  _statusError!,
                  style: TextStyle(color: colorScheme.error, fontSize: 13),
                ),
              ],

              const Divider(height: 28),

              // Danh sách người đã được chia sẻ
              Text(
                'Những người có quyền truy cập (${_permissions.length})',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),

              Expanded(
                child: _isLoadingList
                    ? const Center(child: CircularProgressIndicator())
                    : _permissions.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.people_outline_rounded,
                                    size: 40, color: Colors.grey.withOpacity(0.5)),
                                const SizedBox(height: 8),
                                const Text(
                                  'Chưa có người nào được chia sẻ tài liệu này.',
                                  style: TextStyle(color: Colors.grey, fontSize: 13),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: _permissions.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final perm = _permissions[index];
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: CircleAvatar(
                                  radius: 18,
                                  backgroundColor: colorScheme.primaryContainer,
                                  backgroundImage: perm.userPhotoUrl != null
                                      ? NetworkImage(perm.userPhotoUrl!)
                                      : null,
                                  child: perm.userPhotoUrl == null
                                      ? Text(
                                          (perm.userEmail ?? 'U').substring(0, 1).toUpperCase(),
                                          style: TextStyle(
                                            color: colorScheme.onPrimaryContainer,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      : null,
                                ),
                                title: Text(
                                  perm.userDisplayName ?? perm.userEmail ?? perm.userId,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  perm.userEmail ?? perm.userId,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: theme.textTheme.bodySmall?.color,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    DropdownButton<String>(
                                      value: perm.role,
                                      underline: const SizedBox(),
                                      items: const [
                                        DropdownMenuItem(
                                          value: 'viewer',
                                          child: Text('Viewer', style: TextStyle(fontSize: 13)),
                                        ),
                                        DropdownMenuItem(
                                          value: 'editor',
                                          child: Text('Editor', style: TextStyle(fontSize: 13)),
                                        ),
                                      ],
                                      onChanged: (newRole) {
                                        if (newRole != null) {
                                          _handleRoleChange(perm, newRole);
                                        }
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline,
                                          color: Colors.redAccent, size: 20),
                                      tooltip: 'Thu hồi quyền',
                                      onPressed: () => _handleRevoke(perm),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
              ),

              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Đóng'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
