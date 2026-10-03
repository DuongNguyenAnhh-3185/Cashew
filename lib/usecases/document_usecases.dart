import '../domain/entities/document_entity.dart';
import '../domain/repositories/i_document_repository.dart';

/// Use Case: Lấy chi tiết tài liệu học tập theo ID
class GetDocumentUseCase {
  final IDocumentRepository repository;

  const GetDocumentUseCase(this.repository);

  Future<DocumentEntity?> execute(String id) {
    return repository.getDocumentById(id);
  }
}

/// Use Case: Theo dõi luồng dữ liệu tài liệu học tập phản ứng thời gian thực (Reactive)
class WatchDocumentsUseCase {
  final IDocumentRepository repository;

  const WatchDocumentsUseCase(this.repository);

  Stream<List<DocumentEntity>> execute() {
    return repository.watchAllDocuments();
  }

  Future<List<DocumentEntity>> getAll() {
    return repository.getAllDocuments();
  }
}

/// Use Case: Bật/Tắt trạng thái tài liệu yêu thích
class ToggleFavoriteUseCase {
  final IDocumentRepository repository;

  const ToggleFavoriteUseCase(this.repository);

  Future<void> execute(String id) {
    return repository.toggleFavorite(id);
  }
}

/// Use Case: Khôi phục danh sách tài liệu mẫu mặc định
class ResetDefaultDataUseCase {
  final IDocumentRepository repository;

  const ResetDefaultDataUseCase(this.repository);

  Future<void> execute() {
    return repository.resetToDefaultData();
  }
}
