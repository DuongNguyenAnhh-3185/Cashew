import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:cashew_study_docs/domain/entities/document_entity.dart';
import 'package:cashew_study_docs/domain/entities/document_type.dart';
import 'package:cashew_study_docs/domain/repositories/i_document_repository.dart';
import 'package:cashew_study_docs/presentation/controllers/document_controller.dart';

/// Fake Repository mo phong phan phoi du lieu thoi gian thuc ma khong can dependency nang
class FakeDocumentRepository implements IDocumentRepository {
  final List<DocumentEntity> _docs = [];
  final StreamController<List<DocumentEntity>> _controller =
      StreamController<List<DocumentEntity>>.broadcast();

  FakeDocumentRepository(List<DocumentEntity> initial) {
    _docs.addAll(initial);
  }

  @override
  Future<List<DocumentEntity>> getAllDocuments() async => List.unmodifiable(_docs);

  @override
  Stream<List<DocumentEntity>> watchAllDocuments() async* {
    yield List.unmodifiable(_docs);
    yield* _controller.stream;
  }

  @override
  Future<DocumentEntity?> getDocumentById(String id) async {
    try {
      return _docs.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> addDocument(DocumentEntity document) async {
    _docs.insert(0, document);
    _controller.add(List.unmodifiable(_docs));
  }

  @override
  Future<void> updateDocument(DocumentEntity document) async {
    final idx = _docs.indexWhere((d) => d.id == document.id);
    if (idx != -1) {
      _docs[idx] = document;
      _controller.add(List.unmodifiable(_docs));
    }
  }

  @override
  Future<void> deleteDocument(String id) async {
    _docs.removeWhere((d) => d.id == id);
    _controller.add(List.unmodifiable(_docs));
  }

  @override
  Future<void> toggleFavorite(String id) async {
    final idx = _docs.indexWhere((d) => d.id == id);
    if (idx != -1) {
      final doc = _docs[idx];
      _docs[idx] = doc.copyWith(isFavorite: !doc.isFavorite);
      _controller.add(List.unmodifiable(_docs));
    }
  }

  @override
  Future<void> resetToDefaultData() async {
    _controller.add(List.unmodifiable(_docs));
  }
}

void main() {
  group('DocumentController - Kiểm thử tầng Presentation theo kiến trúc Cashew', () {
    late FakeDocumentRepository fakeRepo;
    late DocumentController controller;
    final now = DateTime.now();

    final sampleDoc = DocumentEntity(
      id: 'doc-1',
      title: 'Tài liệu Thực hành Kiến trúc Cashew',
      description: 'Phân tách 4 tầng rõ ràng',
      subject: 'Kiến trúc Phần mềm',
      type: DocumentType.exercise,
      fileFormat: 'PDF',
      urlOrPath: '/path/test.pdf',
      fileSizeBytes: 1024,
      createdAt: now,
      updatedAt: now,
      isFavorite: false,
      tags: const ['Cashew', 'Flutter'],
    );

    setUp(() {
      fakeRepo = FakeDocumentRepository([sampleDoc]);
      controller = DocumentController(repository: fakeRepo);
    });

    tearDown(() {
      controller.dispose();
    });

    test('Khởi tạo - lắng nghe luồng dữ liệu phản ứng từ Repository', () async {
      await Future.delayed(const Duration(milliseconds: 50));
      expect(controller.totalDocumentsCount, equals(1));
      expect(controller.filteredDocuments.first.title, equals('Tài liệu Thực hành Kiến trúc Cashew'));
    });

    test('Thêm mới tài liệu (addDocument) - cập nhật trạng thái phản ứng thời gian thực', () async {
      await Future.delayed(const Duration(milliseconds: 50));

      final newDoc = DocumentEntity(
        id: 'doc-2',
        title: 'Slide Bài giảng OOP',
        description: 'Lập trình Hướng đối tượng',
        subject: 'Lập trình Di động',
        type: DocumentType.lecture,
        fileFormat: 'PPTX',
        urlOrPath: '/path/oop.pptx',
        fileSizeBytes: 2048,
        createdAt: now,
        updatedAt: now,
        isFavorite: true,
      );

      final result = await controller.addDocument(newDoc);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(result, isTrue);
      expect(controller.totalDocumentsCount, equals(2));
      expect(controller.favoritesCount, equals(1));
    });

    test('Bật/tắt trạng thái yêu thích (toggleFavorite)', () async {
      await Future.delayed(const Duration(milliseconds: 50));
      expect(controller.filteredDocuments.first.isFavorite, isFalse);

      await controller.toggleFavorite('doc-1');
      await Future.delayed(const Duration(milliseconds: 50));

      expect(controller.filteredDocuments.first.isFavorite, isTrue);
      expect(controller.favoritesCount, equals(1));
    });

    test('Xóa tài liệu (deleteDocument)', () async {
      await Future.delayed(const Duration(milliseconds: 50));
      expect(controller.totalDocumentsCount, equals(1));

      final success = await controller.deleteDocument('doc-1');
      await Future.delayed(const Duration(milliseconds: 50));

      expect(success, isTrue);
      expect(controller.totalDocumentsCount, equals(0));
    });

    test('Bộ lọc tìm kiếm (setSearchQuery) - cập nhật danh sách hiển thị', () async {
      await Future.delayed(const Duration(milliseconds: 50));

      controller.setSearchQuery('không tồn tại');
      expect(controller.filteredDocuments.isEmpty, isTrue);

      controller.setSearchQuery('Cashew');
      expect(controller.filteredDocuments.length, equals(1));
    });
  });
}