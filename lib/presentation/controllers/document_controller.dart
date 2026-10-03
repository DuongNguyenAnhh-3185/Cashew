import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/document_entity.dart';
import '../../domain/entities/document_type.dart';
import '../../domain/repositories/i_document_repository.dart';
import '../../domain/services/document_filter_service.dart';
import '../../domain/services/document_validation_service.dart';
import '../../core/constants/app_constants.dart';

/// Controller quan ly trang thai Presentation Layer theo kien truc Cashew
/// Ap dung mo hinh Reactive, tu dong dong bo UI khi du lieu thay doi
class DocumentController extends ChangeNotifier {
  final IDocumentRepository _repository;
  final DocumentFilterService _filterService;
  final DocumentValidationService _validationService;

  StreamSubscription<List<DocumentEntity>>? _streamSubscription;

  // Trang thai noi tai
  List<DocumentEntity> _allDocuments = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Bo loc va tim kiem
  String _searchQuery = '';
  String? _selectedSubject;
  DocumentType? _selectedType;
  bool _onlyFavorites = false;
  DocumentSortOption _sortOption = DocumentSortOption.dateDesc;

  DocumentController({
    required this._repository,
    DocumentFilterService? filterService,
    DocumentValidationService? validationService,
  })  :         _filterService = filterService ?? const DocumentFilterService(),
        _validationService = validationService ?? const DocumentValidationService() {
    _initialize();
  }

  // Getters cho UI
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String? get selectedSubject => _selectedSubject;
  DocumentType? get selectedType => _selectedType;
  bool get onlyFavorites => _onlyFavorites;
  DocumentSortOption get sortOption => _sortOption;
  DocumentValidationService get validationService => _validationService;

  List<DocumentEntity> get allDocuments => List.unmodifiable(_allDocuments);

  /// Danh sach tai lieu da duoc ap dung toan bo bo loc, tim kiem va sap xep
  List<DocumentEntity> get filteredDocuments {
    return _filterService.filterAndSort(
      documents: _allDocuments,
      searchQuery: _searchQuery,
      selectedSubject: _selectedSubject,
      selectedType: _selectedType,
      onlyFavorites: _onlyFavorites,
      sortOption: _sortOption,
    );
  }

  // Thong ke (Analytics) phuc vu UI phong cach Cashew
  int get totalDocumentsCount => _allDocuments.length;
  
  int get favoritesCount => _allDocuments.where((d) => d.isFavorite).length;

  int get totalStorageBytes =>
      _allDocuments.fold(0, (sum, d) => sum + d.fileSizeBytes);

  int getCountByType(DocumentType type) =>
      _allDocuments.where((d) => d.type == type).length;

  List<String> get availableSubjects {
    final Set<String> subjects = {'Tất cả'};
    subjects.addAll(AppConstants.defaultSubjects);
    for (final doc in _allDocuments) {
      if (doc.subject.isNotEmpty) {
        subjects.add(doc.subject);
      }
    }
    return subjects.toList();
  }

  void _initialize() {
    _isLoading = true;
    notifyListeners();

    _streamSubscription = _repository.watchAllDocuments().listen(
      (docs) {
        _allDocuments = docs;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        _isLoading = false;
        _errorMessage = 'Không thể tải danh sách tài liệu: $error';
        notifyListeners();
      },
    );
  }

  // CAC HANH DONG LOC VA TIM KIEM (FILTER ACTIONS)
  void setSearchQuery(String query) {
    if (_searchQuery != query) {
      _searchQuery = query;
      notifyListeners();
    }
  }

  void setSelectedSubject(String? subject) {
    if (_selectedSubject != subject) {
      _selectedSubject = (subject == 'Tất cả' || subject == null) ? null : subject;
      notifyListeners();
    }
  }

  void setSelectedType(DocumentType? type) {
    if (_selectedType != type) {
      _selectedType = type;
      notifyListeners();
    }
  }

  void toggleOnlyFavorites() {
    _onlyFavorites = !_onlyFavorites;
    notifyListeners();
  }

  void setSortOption(DocumentSortOption option) {
    if (_sortOption != option) {
      _sortOption = option;
      notifyListeners();
    }
  }

  void clearAllFilters() {
    _searchQuery = '';
    _selectedSubject = null;
    _selectedType = null;
    _onlyFavorites = false;
    _sortOption = DocumentSortOption.dateDesc;
    notifyListeners();
  }

  // CAC HANH DONG CRUD (BUSINESS OPERATIONS)
  Future<bool> addDocument(DocumentEntity document) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _repository.addDocument(document);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Thêm tài liệu thất bại: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateDocument(DocumentEntity document) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _repository.updateDocument(document);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Cập nhật tài liệu thất bại: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteDocument(String id) async {
    try {
      await _repository.deleteDocument(id);
      return true;
    } catch (e) {
      _errorMessage = 'Xóa tài liệu thất bại: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> toggleFavorite(String id) async {
    try {
      await _repository.toggleFavorite(id);
    } catch (e) {
      _errorMessage = 'Cập nhật yêu thích thất bại: $e';
      notifyListeners();
    }
  }

  Future<void> resetToDefaultData() async {
    try {
      _isLoading = true;
      notifyListeners();
      await _repository.resetToDefaultData();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Khôi phục dữ liệu mẫu thất bại: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }
}