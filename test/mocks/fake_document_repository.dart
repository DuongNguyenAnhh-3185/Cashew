import 'dart:async';
import 'package:cashew_study_docs/domain/entities/document_entity.dart';
import 'package:cashew_study_docs/domain/repositories/i_document_repository.dart';

/// Fake Repository đóng vai trò Mock kiểm thử tính độc lập giữa Tầng Use Cases và Tầng Data
class FakeDocumentRepository implements IDocumentRepository {
  final List<DocumentEntity> _storage = [];
  final StreamController<List<DocumentEntity>> _controller =
      StreamController<List<DocumentEntity>>.broadcast();

  // Biến cờ ghi nhận lời gọi hàm phục vụ kiểm thử
  bool addDocumentCalled = false;
  bool updateDocumentCalled = false;
  bool deleteDocumentCalled = false;
  bool toggleFavoriteCalled = false;
  bool resetToDefaultDataCalled = false;

  void seedData(List<DocumentEntity> initial) {
    _storage.clear();
    _storage.addAll(initial);
    _controller.add(List.unmodifiable(_storage));
  }

  @override
  Future<List<DocumentEntity>> getAllDocuments() async {
    return List.unmodifiable(_storage);
  }

  @override
  Stream<List<DocumentEntity>> watchAllDocuments() {
    return _controller.stream;
  }

  @override
  Future<DocumentEntity?> getDocumentById(String id) async {
    try {
      return _storage.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> addDocument(DocumentEntity document) async {
    addDocumentCalled = true;
    _storage.removeWhere((d) => d.id == document.id);
    _storage.insert(0, document);
    _controller.add(List.unmodifiable(_storage));
  }

  @override
  Future<void> updateDocument(DocumentEntity document) async {
    updateDocumentCalled = true;
    final index = _storage.indexWhere((d) => d.id == document.id);
    if (index != -1) {
      _storage[index] = document;
      _controller.add(List.unmodifiable(_storage));
    }
  }

  @override
  Future<void> deleteDocument(String id) async {
    deleteDocumentCalled = true;
    _storage.removeWhere((d) => d.id == id);
    _controller.add(List.unmodifiable(_storage));
  }

  @override
  Future<void> toggleFavorite(String id) async {
    toggleFavoriteCalled = true;
    final index = _storage.indexWhere((d) => d.id == id);
    if (index != -1) {
      final doc = _storage[index];
      _storage[index] = doc.copyWith(isFavorite: !doc.isFavorite);
      _controller.add(List.unmodifiable(_storage));
    }
  }

  @override
  Future<void> resetToDefaultData() async {
    resetToDefaultDataCalled = true;
    _storage.clear();
    _controller.add(List.unmodifiable(_storage));
  }

  void dispose() {
    _controller.close();
  }
}
