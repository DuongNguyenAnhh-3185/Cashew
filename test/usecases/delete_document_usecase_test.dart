import 'package:flutter_test/flutter_test.dart';
import 'package:cashew_study_docs/domain/entities/document_entity.dart';
import 'package:cashew_study_docs/domain/entities/document_type.dart';
import 'package:cashew_study_docs/usecases/delete_document_usecase.dart';
import '../mocks/fake_document_repository.dart';

void main() {
  late FakeDocumentRepository mockRepository;
  late DeleteDocumentUseCase deleteUseCase;

  setUp(() {
    mockRepository = FakeDocumentRepository();
    deleteUseCase = DeleteDocumentUseCase(mockRepository);
  });

  tearDown(() {
    mockRepository.dispose();
  });

  group('DeleteDocumentUseCase - Kiểm thử xóa tài liệu học tập', () {
    test('Xóa thành công tài liệu khi truyền id hợp lệ', () async {
      final doc = DocumentEntity(
        id: 'doc-delete-1',
        title: 'Tài liệu cần xóa',
        description: 'Mô tả',
        subject: 'Mạng máy tính',
        type: DocumentType.lecture,
        fileFormat: 'PDF',
        urlOrPath: 'https://example.com/network.pdf',
        fileSizeBytes: 1024,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      mockRepository.seedData([doc]);
      expect((await mockRepository.getAllDocuments()).length, equals(1));

      await deleteUseCase.execute('doc-delete-1');

      expect(mockRepository.deleteDocumentCalled, isTrue);
      expect((await mockRepository.getAllDocuments()).isEmpty, isTrue);
    });

    test('Ném ArgumentError khi truyền id rỗng', () async {
      expect(() => deleteUseCase.execute('   '), throwsA(isA<ArgumentError>()));
      expect(mockRepository.deleteDocumentCalled, isFalse);
    });
  });
}
