import '../domain/entities/document_entity.dart';
import '../domain/repositories/i_document_repository.dart';
import '../domain/services/document_validation_service.dart';

/// Use Case: Thêm mới một tài liệu học tập vào hệ thống
/// Đảm bảo tính hợp lệ của nghiệp vụ trước khi lưu vào tầng Data
class AddDocumentUseCase {
  final IDocumentRepository repository;
  final DocumentValidationService validationService;

  const AddDocumentUseCase({
    required this.repository,
    this.validationService = const DocumentValidationService(),
  });

  Future<void> execute(DocumentEntity document) async {
    // 1. Kiểm tra nghiệp vụ (Validation)
    final titleError = validationService.validateTitle(document.title);
    if (titleError != null) {
      throw ArgumentError(titleError);
    }

    final subjectError = validationService.validateSubject(document.subject);
    if (subjectError != null) {
      throw ArgumentError(subjectError);
    }

    final urlError = validationService.validateUrlOrPath(document.urlOrPath);
    if (urlError != null) {
      throw ArgumentError(urlError);
    }

    // 2. Chuyển tiếp xuống Repository thực thi lưu trữ
    await repository.addDocument(document);
  }
}
