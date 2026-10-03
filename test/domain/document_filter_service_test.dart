import 'package:flutter_test/flutter_test.dart';
import 'package:cashew_study_docs/domain/entities/document_entity.dart';
import 'package:cashew_study_docs/domain/entities/document_type.dart';
import 'package:cashew_study_docs/domain/services/document_filter_service.dart';

void main() {
  late DocumentFilterService filterService;
  late List<DocumentEntity> testDocuments;

  setUp(() {
    filterService = const DocumentFilterService();
    final now = DateTime.now();

    testDocuments = [
      DocumentEntity(
        id: '1',
        title: 'Giáo trình Kiến trúc Phần mềm',
        description: 'Tổng quan Clean Architecture và Cashew Pattern',
        subject: 'Kiến trúc Phần mềm',
        type: DocumentType.lecture,
        fileFormat: 'PDF',
        urlOrPath: '/docs/ktpm.pdf',
        fileSizeBytes: 2000000,
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
        isFavorite: true,
        tags: const ['Clean', 'Architecture'],
      ),
      DocumentEntity(
        id: '2',
        title: 'Bài tập Lập trình Di động Tuần 1',
        description: 'Xây dựng giao diện Flutter Cashew',
        subject: 'Lập trình Di động',
        type: DocumentType.exercise,
        fileFormat: 'DOCX',
        urlOrPath: '/docs/th1.docx',
        fileSizeBytes: 500000,
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
        isFavorite: false,
        tags: const ['Flutter', 'TH1'],
      ),
      DocumentEntity(
        id: '3',
        title: 'Đề thi Cuối kỳ Cơ sở Dữ liệu',
        description: 'Tối ưu hóa truy vấn SQL',
        subject: 'Cơ sở Dữ liệu',
        type: DocumentType.exam,
        fileFormat: 'PDF',
        urlOrPath: '/docs/dethi.pdf',
        fileSizeBytes: 8000000,
        createdAt: now,
        updatedAt: now,
        isFavorite: true,
        tags: const ['SQL', 'Database'],
      ),
    ];
  });

  group('DocumentFilterService - Kiểm thử thuật toán lọc và tìm kiếm Domain', () {
    test('Lọc theo trạng thái yêu thích (onlyFavorites)', () {
      final results = filterService.filterAndSort(
        documents: testDocuments,
        onlyFavorites: true,
      );
      expect(results.length, equals(2));
      expect(results.every((d) => d.isFavorite), isTrue);
    });

    test('Lọc theo loại tài liệu (selectedType)', () {
      final results = filterService.filterAndSort(
        documents: testDocuments,
        selectedType: DocumentType.exercise,
      );
      expect(results.length, equals(1));
      expect(results.first.type, equals(DocumentType.exercise));
      expect(results.first.id, equals('2'));
    });

    test('Lọc theo môn học (selectedSubject)', () {
      final results = filterService.filterAndSort(
        documents: testDocuments,
        selectedSubject: 'Cơ sở Dữ liệu',
      );
      expect(results.length, equals(1));
      expect(results.first.subject, equals('Cơ sở Dữ liệu'));
    });

    test('Tìm kiếm theo từ khóa trong tiêu đề, mô tả hoặc tag', () {
      // Tìm theo từ khóa trong tiêu đề
      final searchTitle = filterService.filterAndSort(
        documents: testDocuments,
        searchQuery: 'di động',
      );
      expect(searchTitle.length, equals(1));
      expect(searchTitle.first.id, equals('2'));

      // Tìm theo tag
      final searchTag = filterService.filterAndSort(
        documents: testDocuments,
        searchQuery: 'Clean',
      );
      expect(searchTag.length, equals(1));
      expect(searchTag.first.id, equals('1'));
    });

    test('Sắp xếp theo dung lượng tệp (sizeDesc / sizeAsc)', () {
      final sortedDesc = filterService.filterAndSort(
        documents: testDocuments,
        sortOption: DocumentSortOption.sizeDesc,
      );
      expect(sortedDesc.first.id, equals('3')); // 8 MB
      expect(sortedDesc.last.id, equals('2'));  // 0.5 MB

      final sortedAsc = filterService.filterAndSort(
        documents: testDocuments,
        sortOption: DocumentSortOption.sizeAsc,
      );
      expect(sortedAsc.first.id, equals('2'));
      expect(sortedAsc.last.id, equals('3'));
    });
  });
}