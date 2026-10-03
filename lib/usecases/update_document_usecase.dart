import '../domain/entities/document_entity.dart';
import '../domain/repositories/i_document_repository.dart';
import '../domain/services/document_validation_service.dart';

/// Use Case: Cập nhật thông tin một tài liệu học tập
class UpdateDocumentUseCase {
  final IDocumentRepository repository;
  final DocumentValidationService validationService;

  const UpdateDocumentUseCase({
    required this.repository,
    this.validationService = const DocumentValidationService(),
  });

  Future<void> execute(DocumentEntity document) async {
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

    await repository.updateDocument(document);
  }
}
