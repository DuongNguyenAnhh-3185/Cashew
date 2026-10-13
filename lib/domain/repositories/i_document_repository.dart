import '../entities/app_user_entity.dart';
import '../entities/document_entity.dart';
import '../entities/document_permission_entity.dart';

/// Hợp đồng Repository của tầng Domain (Dependency Inversion Principle)
/// Kết nối Supabase PostgreSQL với Firebase Storage
abstract class IDocumentRepository {
  // --- Quản lý thông tin User ---
  /// Lưu hoặc cập nhật thông tin người dùng vào bảng users khi đăng nhập
  Future<void> upsertUser(AppUserEntity user);

  /// Tìm kiếm người dùng theo email để phục vụ tính năng chia sẻ
  Future<AppUserEntity?> getUserByEmail(String email);

  // --- Luồng dữ liệu thời gian thực (Reactive Streams) ---
  /// Luồng tài liệu do chính người dùng sở hữu (Tab "Của tôi")
  Stream<List<DocumentEntity>> watchMyDocuments();

  /// Luồng tài liệu được chia sẻ với người dùng (Tab "Được chia sẻ với tôi")
  Stream<List<DocumentEntity>> watchSharedDocuments();

  /// Luồng toàn bộ tài liệu (Tương thích ngược)
  Stream<List<DocumentEntity>> watchAllDocuments();

  // --- Truy vấn dữ liệu ---
  /// Lấy danh sách tài liệu của chính mình
  Future<List<DocumentEntity>> getMyDocuments();

  /// Lấy danh sách tài liệu được chia sẻ với mình
  Future<List<DocumentEntity>> getSharedDocuments();

  /// Lấy toàn bộ tài liệu có quyền truy cập
  Future<List<DocumentEntity>> getAllDocuments();

  /// Lấy chi tiết một tài liệu theo mã định danh
  Future<DocumentEntity?> getDocumentById(String id);

  /// Tìm kiếm tài liệu theo từ khóa trong tiêu đề/mô tả (sử dụng ILIKE)
  Future<List<DocumentEntity>> searchDocuments({
    required String query,
    required bool isSharedOnly,
  });

  // --- Thao tác Cập nhật / Xóa (C-U-D) ---
  /// Thêm mới tài liệu (Lưu metadata vào Supabase)
  Future<void> addDocument(DocumentEntity document);

  /// Cập nhật thông tin tài liệu (Chỉ Owner hoặc Editor)
  Future<void> updateDocument(DocumentEntity document);

  /// Xóa tài liệu (Xóa cả file trên Storage và bản ghi trong Supabase)
  Future<void> deleteDocument(String id);

  // --- Quản lý Phân quyền chia sẻ (Permissions) ---
  /// Lấy danh sách người dùng được chia sẻ của một tài liệu
  Future<List<DocumentPermissionEntity>> getDocumentPermissions(String documentId);

  /// Chia sẻ tài liệu cho người dùng theo email với vai trò 'viewer' hoặc 'editor'
  Future<void> shareDocument({
    required String documentId,
    required String targetEmail,
    required String role,
  });

  /// Cập nhật vai trò phân quyền (đổi giữa viewer và editor)
  Future<void> updatePermissionRole({
    required String permissionId,
    required String role,
  });

  /// Thu hồi quyền truy cập của một người dùng
  Future<void> revokePermission(String permissionId);

  // --- Tiện ích tương thích Cashew cũ ---
  Future<void> toggleFavorite(String id);
  Future<void> resetToDefaultData();
}
