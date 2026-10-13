import '../domain/entities/document_permission_entity.dart';
import '../domain/repositories/i_document_repository.dart';

/// Use Case: Chia sẻ tài liệu cho người dùng khác theo email
class ShareDocumentUseCase {
  final IDocumentRepository repository;

  const ShareDocumentUseCase(this.repository);

  Future<void> execute({
    required String documentId,
    required String targetEmail,
    required String role,
  }) {
    if (targetEmail.trim().isEmpty) {
      throw ArgumentError('Vui lòng nhập email người nhận.');
    }
    if (!targetEmail.contains('@') || !targetEmail.contains('.')) {
      throw ArgumentError('Địa chỉ email không hợp lệ.');
    }
    if (role != 'viewer' && role != 'editor') {
      throw ArgumentError('Quyền phân chia phải là viewer hoặc editor.');
    }

    return repository.shareDocument(
      documentId: documentId,
      targetEmail: targetEmail.trim().toLowerCase(),
      role: role,
    );
  }
}

/// Use Case: Lấy danh sách những người được chia sẻ trên tài liệu
class GetDocumentPermissionsUseCase {
  final IDocumentRepository repository;

  const GetDocumentPermissionsUseCase(this.repository);

  Future<List<DocumentPermissionEntity>> execute(String documentId) {
    return repository.getDocumentPermissions(documentId);
  }
}

/// Use Case: Cập nhật vai trò phân quyền (đổi giữa viewer và editor)
class UpdatePermissionRoleUseCase {
  final IDocumentRepository repository;

  const UpdatePermissionRoleUseCase(this.repository);

  Future<void> execute({
    required String permissionId,
    required String role,
  }) {
    return repository.updatePermissionRole(
      permissionId: permissionId,
      role: role,
    );
  }
}

/// Use Case: Thu hồi quyền truy cập tài liệu
class RevokePermissionUseCase {
  final IDocumentRepository repository;

  const RevokePermissionUseCase(this.repository);

  Future<void> execute(String permissionId) {
    return repository.revokePermission(permissionId);
  }
}
