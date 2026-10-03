import 'dart:async';
import '../../domain/entities/document_entity.dart';
import '../../domain/repositories/i_document_repository.dart';
import '../datasources/document_local_data_source.dart';
import '../models/document_model.dart';

/// Trien khai Repository theo kien truc Cashew
/// Dong vai tro cau noi giua Domain va Nguon du lieu (Data Source)
/// Cung cap luong phan ung (Reactive Stream) cap nhat realtime den Presentation Layer
class DocumentRepositoryImpl implements IDocumentRepository {
  final IDocumentLocalDataSource _localDataSource;
  
  // Bo nho dem in-memory
  List<DocumentModel> _cachedDocuments = [];
  bool _isInitialized = false;

  // StreamController phat broadcast cac thay doi cua danh sach tai lieu
  final StreamController<List<DocumentEntity>> _documentsStreamController =
      StreamController<List<DocumentEntity>>.broadcast();

  DocumentRepositoryImpl(this._localDataSource);

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      _cachedDocuments = await _localDataSource.getDocuments();
      _isInitialized = true;
      _emitCurrentState();
    }
  }

  void _emitCurrentState() {
    _documentsStreamController.add(List.unmodifiable(_cachedDocuments));
  }

  Future<void> _persist() async {
    await _localDataSource.saveDocuments(_cachedDocuments);
    _emitCurrentState();
  }

  @override
  Future<List<DocumentEntity>> getAllDocuments() async {
    await _ensureInitialized();
    return List.unmodifiable(_cachedDocuments);
  }

  @override
  Stream<List<DocumentEntity>> watchAllDocuments() async* {
    await _ensureInitialized();
    yield List.unmodifiable(_cachedDocuments);
    yield* _documentsStreamController.stream;
  }

  @override
  Future<DocumentEntity?> getDocumentById(String id) async {
    await _ensureInitialized();
    try {
      return _cachedDocuments.firstWhere((doc) => doc.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> addDocument(DocumentEntity document) async {
    await _ensureInitialized();
    final model = DocumentModel.fromEntity(document);
    _cachedDocuments.insert(0, model);
    await _persist();
  }

  @override
  Future<void> updateDocument(DocumentEntity document) async {
    await _ensureInitialized();
    final index = _cachedDocuments.indexWhere((doc) => doc.id == document.id);
    if (index != -1) {
      _cachedDocuments[index] = DocumentModel.fromEntity(document);
      await _persist();
    }
  }

  @override
  Future<void> deleteDocument(String id) async {
    await _ensureInitialized();
    _cachedDocuments.removeWhere((doc) => doc.id == id);
    await _persist();
  }

  @override
  Future<void> toggleFavorite(String id) async {
    await _ensureInitialized();
    final index = _cachedDocuments.indexWhere((doc) => doc.id == id);
    if (index != -1) {
      final doc = _cachedDocuments[index];
      final updated = doc.copyWith(
        isFavorite: !doc.isFavorite,
        updatedAt: DateTime.now(),
      );
      _cachedDocuments[index] = DocumentModel.fromEntity(updated);
      await _persist();
    }
  }

  @override
  Future<void> resetToDefaultData() async {
    final sampleDocs = await _localDataSource.getInitialSampleDocuments();
    _cachedDocuments = List.from(sampleDocs);
    await _persist();
  }

  void dispose() {
    _documentsStreamController.close();
  }
}