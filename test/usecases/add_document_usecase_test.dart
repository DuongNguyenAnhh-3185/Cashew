import 'package:flutter_test/flutter_test.dart';
import 'package:cashew_study_docs/domain/entities/document_entity.dart';
import 'package:cashew_study_docs/domain/entities/document_type.dart';
import 'package:cashew_study_docs/domain/services/document_validation_service.dart';
import 'package:cashew_study_docs/usecases/add_document_usecase.dart';
import '../mocks/fake_document_repository.dart';

void main() {
  late FakeDocumentRepository mockRepository;
  late AddDocumentUseCase addUseCase;

  setUp(() {
    mockRepository = FakeDocumentRepository();
    addUseCase = AddDocumentUseCase(
      repository: mockRepository,
      validationService: const DocumentValidationService(),
    );
  });

  tearDown(() {
    mockRepository.dispose();
  });

  group('AddDocumentUseCase - Kiểm thử độc lập Use Case với Data Layer', () {
    test('Thêm tài liệu hợp lệ thành công và lưu vào repository', () async {
      final doc = DocumentEntity(
        id: 'doc-001',
        title: 'Bài giảng Kiến trúc Phần mềm',
        description: 'Tổng quan về Clean Architecture',
        subject: 'Kiến trúc phần mềm',
        type: DocumentType.lecture,
        fileFormat: 'PDF',
        urlOrPath: 'https://example.com/lecture.pdf',
        fileSizeBytes: 2048576,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        tags: const ['architecture', 'lecture'],
      );

      await addUseCase.execute(doc);

      expect(mockRepository.addDocumentCalled, isTrue);
      final storedDocs = await mockRepository.getAllDocuments();
      expect(storedDocs.length, equals(1));
      expect(storedDocs.first.id, equals('doc-001'));
      expect(storedDocs.first.title, equals('Bài giảng Kiến trúc Phần mềm'));
    });

    test('Ném ngoại lệ ArgumentError khi tiêu đề tài liệu quá ngắn', () async {
      final invalidDoc = DocumentEntity(
        id: 'doc-002',
        title: 'AB', // Ít hơn 3 ký tự
        description: '',
        subject: 'Cơ sở dữ liệu',
        type: DocumentType.exercise,
        fileFormat: 'PDF',
        urlOrPath: 'https://example.com/ex.pdf',
        fileSizeBytes: 1024,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(() => addUseCase.execute(invalidDoc), throwsA(isA<ArgumentError>()));
      expect(mockRepository.addDocumentCalled, isFalse);
    });

    test('Ném ngoại lệ ArgumentError khi môn học không hợp lệ', () async {
      final invalidDoc = DocumentEntity(
        id: 'doc-003',
        title: 'Bài tập SQL',
        description: '',
        subject: 'Tất cả', // 'Tất cả' không phải tên môn học hợp lệ
        type: DocumentType.exercise,
        fileFormat: 'PDF',
        urlOrPath: 'https://example.com/sql.pdf',
        fileSizeBytes: 1024,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(() => addUseCase.execute(invalidDoc), throwsA(isA<ArgumentError>()));
      expect(mockRepository.addDocumentCalled, isFalse);
    });

    test('Ném ngoại lệ ArgumentError khi đường dẫn URL/Path rỗng', () async {
      final invalidDoc = DocumentEntity(
        id: 'doc-004',
        title: 'Sách giáo trình Lập trình',
        description: '',
        subject: 'Lập trình di động',
        type: DocumentType.reference,
        fileFormat: 'PDF',
        urlOrPath: '   ', // Rỗng
        fileSizeBytes: 1024,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(() => addUseCase.execute(invalidDoc), throwsA(isA<ArgumentError>()));
      expect(mockRepository.addDocumentCalled, isFalse);
    });
  });
}
