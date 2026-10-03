import 'package:flutter_test/flutter_test.dart';
import 'package:cashew_study_docs/domain/entities/document_entity.dart';
import 'package:cashew_study_docs/domain/entities/document_type.dart';
import 'package:cashew_study_docs/domain/services/document_validation_service.dart';
import 'package:cashew_study_docs/usecases/update_document_usecase.dart';
import '../mocks/fake_document_repository.dart';

void main() {
  late FakeDocumentRepository mockRepository;
  late UpdateDocumentUseCase updateUseCase;

  setUp(() {
    mockRepository = FakeDocumentRepository();
    updateUseCase = UpdateDocumentUseCase(
      repository: mockRepository,
      validationService: const DocumentValidationService(),
    );
  });

  tearDown(() {
    mockRepository.dispose();
  });

  group('UpdateDocumentUseCase - Kiểm thử cập nhật thông tin tài liệu', () {
    test('Cập nhật tài liệu hợp lệ thành công', () async {
      final original = DocumentEntity(
        id: 'doc-update-1',
        title: 'Tiêu đề cũ',
        description: 'Mô tả cũ',
        subject: 'Hệ điều hành',
        type: DocumentType.lecture,
        fileFormat: 'PDF',
        urlOrPath: 'https://example.com/os.pdf',
        fileSizeBytes: 1024,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      mockRepository.seedData([original]);

      final updated = original.copyWith(
        title: 'Tiêu đề mới đã chỉnh sửa',
        description: 'Mô tả mới',
      );

      await updateUseCase.execute(updated);

      expect(mockRepository.updateDocumentCalled, isTrue);
      final stored = await mockRepository.getDocumentById('doc-update-1');
      expect(stored?.title, equals('Tiêu đề mới đã chỉnh sửa'));
      expect(stored?.description, equals('Mô tả mới'));
    });

    test('Ném ngoại lệ ArgumentError khi tiêu đề cập nhật không hợp lệ', () async {
      final invalidUpdated = DocumentEntity(
        id: 'doc-update-1',
        title: '', // Rỗng
        description: '',
        subject: 'Hệ điều hành',
        type: DocumentType.lecture,
        fileFormat: 'PDF',
        urlOrPath: 'https://example.com/os.pdf',
        fileSizeBytes: 1024,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(() => updateUseCase.execute(invalidUpdated), throwsA(isA<ArgumentError>()));
      expect(mockRepository.updateDocumentCalled, isFalse);
    });
  });
}
