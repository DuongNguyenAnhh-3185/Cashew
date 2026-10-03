import '../domain/repositories/i_document_repository.dart';

/// Use Case: Xóa tài liệu học tập theo ID
class DeleteDocumentUseCase {
  final IDocumentRepository repository;

  const DeleteDocumentUseCase(this.repository);

  Future<void> execute(String id) async {
    if (id.trim().isEmpty) {
      throw ArgumentError('Mã tài liệu không được để trống');
    }
    await repository.deleteDocument(id);
  }
}
