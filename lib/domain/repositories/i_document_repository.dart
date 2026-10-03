import '../entities/document_entity.dart';

/// Hợp đồng Repository của tầng Domain (Dependency Inversion Principle)
/// Cho phép hoán đổi nguồn dữ liệu (Memory, SQLite, SharedPrefs, REST API)
/// mà không làm ảnh hưởng đến tầng Logic Nghiệp vụ và Giao diện
abstract class IDocumentRepository {
  /// Lấy toàn bộ danh sách tài liệu
  Future<List<DocumentEntity>> getAllDocuments();

  /// Luồng dữ liệu phản ứng thời gian thực (Reactive stream - đặc trưng Cashew)
  Stream<List<DocumentEntity>> watchAllDocuments();

  /// Lấy chi tiết một tài liệu theo mã định danh
  Future<DocumentEntity?> getDocumentById(String id);

  /// Thêm mới một tài liệu
  Future<void> addDocument(DocumentEntity document);

  /// Cập nhật thông tin tài liệu
  Future<void> updateDocument(DocumentEntity document);

  /// Xóa tài liệu theo mã định danh
  Future<void> deleteDocument(String id);

  /// Bật/tắt trạng thái yêu thích
  Future<void> toggleFavorite(String id);

  /// Khôi phục dữ liệu mẫu ban đầu
  Future<void> resetToDefaultData();
}
