import 'package:flutter_test/flutter_test.dart';
import 'package:cashew_study_docs/domain/entities/document_entity.dart';
import 'package:cashew_study_docs/domain/entities/document_type.dart';
import 'package:cashew_study_docs/domain/services/document_filter_service.dart';
import 'package:cashew_study_docs/usecases/search_documents_usecase.dart';

void main() {
  late SearchDocumentsUseCase searchUseCase;
  late List<DocumentEntity> testDocuments;

  setUp(() {
    searchUseCase = const SearchDocumentsUseCase();
    testDocuments = [
      DocumentEntity(
        id: '1',
        title: 'Bài giảng Lập trình Flutter Cơ bản',
        description: 'Tổng quan về Widget và State',
        subject: 'Lập trình di động',
        type: DocumentType.lecture,
        fileFormat: 'PDF',
        urlOrPath: 'flutter_slide.pdf',
        fileSizeBytes: 5000000,
        createdAt: DateTime(2026, 1, 10),
        updatedAt: DateTime(2026, 1, 10),
        isFavorite: true,
        tags: const ['flutter', 'mobile'],
      ),
      DocumentEntity(
        id: '2',
        title: 'Bài tập Lớn Cơ sở dữ liệu',
        description: 'Thiết kế lược đồ ERD và viết truy vấn SQL',
        subject: 'Cơ sở dữ liệu',
        type: DocumentType.exercise,
        fileFormat: 'DOCX',
        urlOrPath: 'db_assignment.docx',
        fileSizeBytes: 2000000,
        createdAt: DateTime(2026, 2, 1),
        updatedAt: DateTime(2026, 2, 1),
        isFavorite: false,
        tags: const ['database', 'sql'],
      ),
      DocumentEntity(
        id: '3',
        title: 'Giáo trình Clean Architecture',
        description: 'Hướng dẫn xây dựng kiến trúc phần mềm',
        subject: 'Kiến trúc phần mềm',
        type: DocumentType.reference,
        fileFormat: 'PDF',
        urlOrPath: 'clean_arch.pdf',
        fileSizeBytes: 10000000,
        createdAt: DateTime(2026, 3, 1),
        updatedAt: DateTime(2026, 3, 1),
        isFavorite: true,
        tags: const ['architecture', 'clean-code'],
      ),
    ];
  });

  group('SearchDocumentsUseCase - Kiểm thử tìm kiếm, lọc và sắp xếp', () {
    test('Tìm kiếm theo từ khóa trong tiêu đề hoặc mô tả', () {
      final results = searchUseCase.execute(
        documents: testDocuments,
        searchQuery: 'Flutter',
      );

      expect(results.length, equals(1));
      expect(results.first.title, contains('Flutter'));
    });

    test('Lọc theo loại tài liệu (DocumentType)', () {
      final results = searchUseCase.execute(
        documents: testDocuments,
        selectedType: DocumentType.exercise,
      );

      expect(results.length, equals(1));
      expect(results.first.id, equals('2'));
    });

    test('Lọc theo tài liệu yêu thích (onlyFavorites = true)', () {
      final results = searchUseCase.execute(
        documents: testDocuments,
        onlyFavorites: true,
      );

      expect(results.length, equals(2));
      expect(results.every((d) => d.isFavorite), isTrue);
    });

    test('Lọc theo môn học', () {
      final results = searchUseCase.execute(
        documents: testDocuments,
        selectedSubject: 'Cơ sở dữ liệu',
      );

      expect(results.length, equals(1));
      expect(results.first.subject, equals('Cơ sở dữ liệu'));
    });

    test('Sắp xếp theo dung lượng tệp giảm dần (sizeDesc)', () {
      final results = searchUseCase.execute(
        documents: testDocuments,
        sortOption: DocumentSortOption.sizeDesc,
      );

      expect(results.length, equals(3));
      expect(results.first.fileSizeBytes, equals(10000000));
      expect(results.last.fileSizeBytes, equals(2000000));
    });
  });
}
