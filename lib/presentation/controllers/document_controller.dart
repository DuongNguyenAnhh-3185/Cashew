import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/document_entity.dart';
import '../../domain/entities/document_permission_entity.dart';
import '../../domain/entities/document_type.dart';
import '../../domain/repositories/i_document_repository.dart';
import '../../domain/services/document_filter_service.dart';
import '../../domain/services/document_validation_service.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';
import '../../usecases/usecases.dart';

/// Controller quản lý trạng thái giao diện theo kiến trúc Cashew & Clean Architecture
/// Hỗ trợ phân tab "Của tôi" & "Được chia sẻ với tôi", tìm kiếm Debounce, và phân quyền RLS
class DocumentController extends ChangeNotifier {
  final IDocumentRepository _repository;
  final AuthService _authService;
  final StorageService _storageService;

  // Tầng Use Cases
  final AddDocumentUseCase _addUseCase;
  final UpdateDocumentUseCase _updateUseCase;
  final DeleteDocumentUseCase _deleteUseCase;
  final SearchDocumentsUseCase _searchUseCase;
  final ShareDocumentUseCase _shareUseCase;
  final GetDocumentPermissionsUseCase _getPermissionsUseCase;
  final UpdatePermissionRoleUseCase _updatePermissionRoleUseCase;
  final RevokePermissionUseCase _revokePermissionUseCase;
  final DocumentValidationService _validationService;
  final DocumentFilterService _filterService;

  // Luồng theo dõi dữ liệu
  StreamSubscription<List<DocumentEntity>>? _myDocsSubscription;
  StreamSubscription<List<DocumentEntity>>? _sharedDocsSubscription;

  // Bộ hẹn giờ Debounce tìm kiếm
  Timer? _debounceTimer;

  // Trạng thái nội tại
  List<DocumentEntity> _myDocuments = [];
  List<DocumentEntity> _sharedDocuments = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  // Tab hiện hành: 0 = "Của tôi", 1 = "Được chia sẻ với tôi"
  int _currentTabIndex = 0;

  // Tiêu chí tìm kiếm & lọc
  String _searchQuery = '';
  String? _selectedSubject;
  DocumentType? _selectedType;
  bool _onlyFavorites = false;
  DocumentSortOption _sortOption = DocumentSortOption.dateDesc;

  DocumentController({
    required IDocumentRepository repository,
    AuthService? authService,
    StorageService? storageService,
    DocumentFilterService? filterService,
    DocumentValidationService? validationService,
    AddDocumentUseCase? addUseCase,
    UpdateDocumentUseCase? updateUseCase,
    DeleteDocumentUseCase? deleteUseCase,
    SearchDocumentsUseCase? searchUseCase,
    ShareDocumentUseCase? shareUseCase,
    GetDocumentPermissionsUseCase? getPermissionsUseCase,
    UpdatePermissionRoleUseCase? updatePermissionRoleUseCase,
    RevokePermissionUseCase? revokePermissionUseCase,
    WatchDocumentsUseCase? watchUseCase,
    ToggleFavoriteUseCase? toggleFavoriteUseCase,
    ResetDefaultDataUseCase? resetDefaultDataUseCase,
  })  : _repository = repository,
        _authService = authService ?? AuthService(),
        _storageService = storageService ?? StorageService(),
        _filterService = filterService ?? const DocumentFilterService(),
        _validationService = validationService ?? const DocumentValidationService(),
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
        _shareUseCase = shareUseCase ?? ShareDocumentUseCase(repository),
        _getPermissionsUseCase =
            getPermissionsUseCase ?? GetDocumentPermissionsUseCase(repository),
        _updatePermissionRoleUseCase = updatePermissionRoleUseCase ??
            UpdatePermissionRoleUseCase(repository),
        _revokePermissionUseCase =
            revokePermissionUseCase ?? RevokePermissionUseCase(repository) {
    _initializeStreams();
  }

  // Getters cho UI
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  int get currentTabIndex => _currentTabIndex;
  String get searchQuery => _searchQuery;
  String? get selectedSubject => _selectedSubject;
  DocumentType? get selectedType => _selectedType;
  bool get onlyFavorites => _onlyFavorites;
  DocumentSortOption get sortOption => _sortOption;
  DocumentValidationService get validationService => _validationService;
  DocumentFilterService get filterService => _filterService;
  AuthService get authService => _authService;
  StorageService get storageService => _storageService;

  List<DocumentEntity> get myDocuments => List.unmodifiable(_myDocuments);
  List<DocumentEntity> get sharedDocuments => List.unmodifiable(_sharedDocuments);

  /// Danh sách tài liệu của tab hiện hành
  List<DocumentEntity> get currentTabDocuments =>
      _currentTabIndex == 0 ? _myDocuments : _sharedDocuments;

  /// Toàn bộ tài liệu người dùng có quyền tiếp cận
  List<DocumentEntity> get allDocuments =>
      List.unmodifiable([..._myDocuments, ..._sharedDocuments]);

  /// Danh sách tài liệu hiển thị sau khi lọc và tìm kiếm
  List<DocumentEntity> get filteredDocuments {
    return _searchUseCase.execute(
      documents: currentTabDocuments,
      searchQuery: _searchQuery,
      selectedSubject: _selectedSubject,
      selectedType: _selectedType,
      onlyFavorites: _onlyFavorites,
      sortOption: _sortOption,
    );
  }

  // Thống kê nhanh
  int get totalDocumentsCount => currentTabDocuments.length;
  int get myDocsCount => _myDocuments.length;
  int get sharedDocsCount => _sharedDocuments.length;
  int get favoritesCount =>
      currentTabDocuments.where((d) => d.isFavorite).length;

  int get totalStorageBytes =>
      currentTabDocuments.fold(0, (sum, d) => sum + d.fileSizeBytes);

  int getCountByType(DocumentType type) =>
      currentTabDocuments.where((d) => d.type == type).length;

  List<String> get availableSubjects {
    final Set<String> subjects = {'Tất cả'};
    subjects.addAll(AppConstants.defaultSubjects);
    for (final doc in currentTabDocuments) {
      if (doc.subject.isNotEmpty) {
        subjects.add(doc.subject);
      }
    }
    return subjects.toList();
  }

  // ==============================================================================
  // KHỞI TẠO & LẮNG NGHE LUỒNG DỮ LIỆU
  // ==============================================================================
  void _initializeStreams() {
    _isLoading = true;
    notifyListeners();

    _myDocsSubscription = _repository.watchMyDocuments().listen(
      (docs) {
        _myDocuments = docs;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (err) {
        _isLoading = false;
        _errorMessage = 'Lỗi tải tài liệu của tôi: $err';
        notifyListeners();
      },
    );

    _sharedDocsSubscription = _repository.watchSharedDocuments().listen(
      (docs) {
        _sharedDocuments = docs;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (err) {
        _isLoading = false;
        _errorMessage = 'Lỗi tải tài liệu được chia sẻ: $err';
        notifyListeners();
      },
    );
  }

  /// Làm mới thủ công dữ liệu từ server
  Future<void> refresh() async {
    try {
      _isLoading = true;
      notifyListeners();
      _myDocuments = await _repository.getMyDocuments();
      _sharedDocuments = await _repository.getSharedDocuments();
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Không thể làm mới danh sách: $e';
      notifyListeners();
    }
  }

  // ==============================================================================
  // ĐIỀU HƯỚNG TAB & TÌM KIẾM CÓ DEBOUNCE
  // ==============================================================================
  void setTabIndex(int index) {
    if (_currentTabIndex != index) {
      _currentTabIndex = index;
      _errorMessage = null;
      _successMessage = null;
      notifyListeners();
    }
  }

  /// Tìm kiếm có Debounce (mặc định trễ 350ms)
  void setSearchQuery(String query, {Duration delay = const Duration(milliseconds: 350)}) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, () {
      if (_searchQuery != query) {
        _searchQuery = query;
        notifyListeners();
      }
    });
  }

  /// Tìm kiếm tức thì không cần delay (ví dụ khi nhấn nút tìm kiếm hoặc xóa)
  void setSearchQueryImmediate(String query) {
    _debounceTimer?.cancel();
    _searchQuery = query;
    notifyListeners();
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

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  // ==============================================================================
  // CÁC HÀNH ĐỘNG NGHIỆP VỤ CRUD & FILE STORAGE
  // ==============================================================================

  /// Tải tệp lên Firebase Storage và lưu metadata vào Supabase
  Future<bool> uploadAndAddDocument({
    required String title,
    required String description,
    required String subject,
    required DocumentType type,
    required String fileName,
    required String fileType,
    required int fileSize,
    required String filePath,
    Uint8List? fileBytes,
    List<String> tags = const [],
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
      notifyListeners();

      final currentUid = _authService.currentUid;
      if (currentUid == null) {
        throw StateError('Bạn cần đăng nhập để tải lên tài liệu.');
      }

      // Tạo UUID mới cho tài liệu
      final documentId = const Uuid().v4();

      // 1. Upload file lên Firebase Storage theo cấu trúc documents/{uid}/{documentId}/{fileName}
      String storagePath;
      if (fileBytes != null && fileBytes.isNotEmpty) {
        storagePath = await _storageService.uploadFileFromBytes(
          uid: currentUid,
          documentId: documentId,
          fileName: fileName,
          bytes: fileBytes,
        );
      } else {
        storagePath = await _storageService.uploadFileFromPath(
          uid: currentUid,
          documentId: documentId,
          fileName: fileName,
          filePath: filePath,
        );
      }

      // 2. Tạo DocumentEntity lưu vào cơ sở dữ liệu Supabase
      final documentEntity = DocumentEntity(
        id: documentId,
        ownerId: currentUid,
        title: title,
        description: description,
        fileName: fileName,
        fileType: fileType,
        fileSize: fileSize,
        storagePath: storagePath,
        subject: subject,
        type: type,
        tags: tags,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        currentUserRole: 'owner',
      );

      // 3. Thực thi qua UseCase
      await _addUseCase.execute(documentEntity);

      _isLoading = false;
      _successMessage = 'Tải lên tài liệu thành công!';
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Thêm tài liệu thất bại: $e';
      notifyListeners();
      return false;
    }
  }

  /// Cập nhật thông tin tiêu đề và mô tả tài liệu (Chỉ Owner hoặc Editor)
  Future<bool> updateDocument({
    required String id,
    required String title,
    required String description,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
      notifyListeners();

      // Kiểm tra quyền hạn
      final currentDoc = allDocuments.firstWhere((d) => d.id == id);
      if (!currentDoc.canEdit) {
        throw StateError('Bạn không có quyền chỉnh sửa tài liệu này (Cần quyền Owner hoặc Editor).');
      }

      final updatedDoc = currentDoc.copyWith(
        title: title,
        description: description,
        updatedAt: DateTime.now(),
      );

      await _updateUseCase.execute(updatedDoc);

      _isLoading = false;
      _successMessage = 'Cập nhật tài liệu thành công!';
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Cập nhật tài liệu thất bại: $e';
      notifyListeners();
      return false;
    }
  }

  /// Xóa tài liệu (Xóa cả file trên Storage và bản ghi trong Supabase - Chỉ Owner)
  Future<bool> deleteDocument(DocumentEntity document) async {
    try {
      if (!document.canDelete) {
        _errorMessage = 'Bạn không có quyền xóa tài liệu này. Chỉ chủ sở hữu mới có quyền xóa.';
        notifyListeners();
        return false;
      }

      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _deleteUseCase.execute(document.id);

      _isLoading = false;
      _successMessage = 'Đã xóa tài liệu và tệp đính kèm thành công!';
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Xóa tài liệu thất bại: $e';
      notifyListeners();
      return false;
    }
  }

  /// Tải tệp xuống thiết bị và mở bằng ứng dụng mặc định
  Future<FileDownloadResult> downloadAndOpenFile(DocumentEntity document) async {
    if (document.storagePath.isEmpty) {
      return const FileDownloadResult(
        isSuccess: false,
        errorMessage: 'Tài liệu không có đường dẫn tệp đính kèm hợp lệ.',
      );
    }
    return await _storageService.downloadAndOpenFile(
      storagePath: document.storagePath,
      fileName: document.fileName.isNotEmpty ? document.fileName : 'document_${document.id}.${document.fileType.toLowerCase()}',
    );
  }

  // ==============================================================================
  // CÁC HÀNH ĐỘNG PHÂN QUYỀN & CHIA SẺ (PERMISSIONS)
  // ==============================================================================

  /// Lấy danh sách người được chia sẻ
  Future<List<DocumentPermissionEntity>> fetchPermissions(String documentId) async {
    try {
      return await _getPermissionsUseCase.execute(documentId);
    } catch (e) {
      _errorMessage = 'Không thể lấy danh sách quyền: $e';
      notifyListeners();
      return [];
    }
  }

  /// Chia sẻ tài liệu cho người khác theo email
  Future<bool> shareDocument({
    required String documentId,
    required String email,
    required String role,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _shareUseCase.execute(
        documentId: documentId,
        targetEmail: email,
        role: role,
      );

      _isLoading = false;
      _successMessage = 'Đã chia sẻ tài liệu thành công cho $email ($role)!';
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Chia sẻ thất bại: $e';
      notifyListeners();
      return false;
    }
  }

  /// Cập nhật vai trò phân quyền (đổi giữa viewer và editor)
  Future<bool> updatePermissionRole({
    required String permissionId,
    required String role,
  }) async {
    try {
      await _updatePermissionRoleUseCase.execute(
        permissionId: permissionId,
        role: role,
      );
      _successMessage = 'Đã cập nhật quyền thành công!';
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Cập nhật quyền thất bại: $e';
      notifyListeners();
      return false;
    }
  }

  /// Thu hồi quyền truy cập của một người dùng
  Future<bool> revokePermission(String permissionId) async {
    try {
      await _revokePermissionUseCase.execute(permissionId);
      _successMessage = 'Đã thu hồi quyền truy cập thành công!';
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Thu hồi quyền thất bại: $e';
      notifyListeners();
      return false;
    }
  }

  // Tương thích cũ
  Future<void> toggleFavorite(String id) async {
    try {
      await _repository.toggleFavorite(id);
    } catch (e) {
      _errorMessage = 'Lỗi yêu thích: $e';
      notifyListeners();
    }
  }

  Future<void> resetToDefaultData() async {
    await refresh();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _myDocsSubscription?.cancel();
    _sharedDocsSubscription?.cancel();
    super.dispose();
  }
}