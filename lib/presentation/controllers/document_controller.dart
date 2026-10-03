import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/document_entity.dart';
import '../../domain/entities/document_type.dart';
import '../../domain/repositories/i_document_repository.dart';
import '../../domain/services/document_filter_service.dart';
import '../../domain/services/document_validation_service.dart';
import '../../usecases/usecases.dart';

/// Controller quản lý trạng thái Presentation Layer theo kiến trúc Cashew
/// Điều phối tương tác giữa UI và Tầng Use Cases (Logic Nghiệp vụ)
/// Áp dụng mô hình Reactive Streams, tự động đồng bộ UI khi dữ liệu biến đổi
class DocumentController extends ChangeNotifier {
  // Tầng Use Cases (Business Logic Layer)
  final WatchDocumentsUseCase _watchUseCase;
  final AddDocumentUseCase _addUseCase;
  final UpdateDocumentUseCase _updateUseCase;
  final DeleteDocumentUseCase _deleteUseCase;
  final SearchDocumentsUseCase _searchUseCase;
  final ToggleFavoriteUseCase _toggleFavoriteUseCase;
  final ResetDefaultDataUseCase _resetDefaultDataUseCase;
  final DocumentValidationService _validationService;
  final DocumentFilterService _filterService;

  StreamSubscription<List<DocumentEntity>>? _streamSubscription;

  // Trạng thái nội tại
  List<DocumentEntity> _allDocuments = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Tiêu chí tìm kiếm & lọc
  String _searchQuery = '';
  String? _selectedSubject;
  DocumentType? _selectedType;
  bool _onlyFavorites = false;
  DocumentSortOption _sortOption = DocumentSortOption.dateDesc;

  DocumentController({
    required IDocumentRepository repository,
    DocumentFilterService? filterService,
    DocumentValidationService? validationService,
    AddDocumentUseCase? addUseCase,
    UpdateDocumentUseCase? updateUseCase,
    DeleteDocumentUseCase? deleteUseCase,
    SearchDocumentsUseCase? searchUseCase,
    WatchDocumentsUseCase? watchUseCase,
    ToggleFavoriteUseCase? toggleFavoriteUseCase,
    ResetDefaultDataUseCase? resetDefaultDataUseCase,
  })  : _filterService = filterService ?? const DocumentFilterService(),
        _validationService = validationService ?? const DocumentValidationService(),
        _watchUseCase = watchUseCase ?? WatchDocumentsUseCase(repository),
        _addUseCase = addUseCase ??
            AddDocumentUseCase(
              repository: repository,
              validationService: validationService ?? const DocumentValidationService(),
            ),
        _updateUseCase = updateUseCase ??
            UpdateDocumentUseCase(
              repository: repository,
              validationService: validationService ?? const DocumentValidationService(),
            ),
        _deleteUseCase = deleteUseCase ?? DeleteDocumentUseCase(repository),
        _searchUseCase = searchUseCase ??
            SearchDocumentsUseCase(filterService ?? const DocumentFilterService()),
        _toggleFavoriteUseCase =
            toggleFavoriteUseCase ?? ToggleFavoriteUseCase(repository),
        _resetDefaultDataUseCase =
            resetDefaultDataUseCase ?? ResetDefaultDataUseCase(repository) {
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
  DocumentFilterService get filterService => _filterService;

  List<DocumentEntity> get allDocuments => List.unmodifiable(_allDocuments);

  /// Danh sách tài liệu đã được lọc và sắp xếp qua SearchDocumentsUseCase
  List<DocumentEntity> get filteredDocuments {
    return _searchUseCase.execute(
      documents: _allDocuments,
      searchQuery: _searchQuery,
      selectedSubject: _selectedSubject,
      selectedType: _selectedType,
      onlyFavorites: _onlyFavorites,
      sortOption: _sortOption,
    );
  }

  // Thống kê (Analytics) phục vụ UI phong cách Cashew
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

    _streamSubscription = _watchUseCase.execute().listen(
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

  // CÁC HÀNH ĐỘNG LỌC VÀ TÌM KIẾM
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

  // CÁC HÀNH ĐỘNG NGHIỆP VỤ QUA TẦNG USE CASES (CRUD)
  Future<bool> addDocument(DocumentEntity document) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _addUseCase.execute(document);
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
      await _updateUseCase.execute(document);
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
      await _deleteUseCase.execute(id);
      return true;
    } catch (e) {
      _errorMessage = 'Xóa tài liệu thất bại: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> toggleFavorite(String id) async {
    try {
      await _toggleFavoriteUseCase.execute(id);
    } catch (e) {
      _errorMessage = 'Cập nhật yêu thích thất bại: $e';
      notifyListeners();
    }
  }

  Future<void> resetToDefaultData() async {
    try {
      _isLoading = true;
      notifyListeners();
      await _resetDefaultDataUseCase.execute();
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