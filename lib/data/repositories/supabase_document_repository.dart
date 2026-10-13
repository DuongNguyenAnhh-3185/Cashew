import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/app_user_entity.dart';
import '../../domain/entities/document_entity.dart';
import '../../domain/entities/document_permission_entity.dart';
import '../../domain/repositories/i_document_repository.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';
import '../../services/supabase_service.dart';
import '../models/app_user_model.dart';
import '../models/document_model.dart';
import '../models/document_permission_model.dart';

/// Triển khai IDocumentRepository kết nối trực tiếp với Supabase PostgreSQL và Firebase Storage
class SupabaseDocumentRepository implements IDocumentRepository {
  final SupabaseClient _client;
  final AuthService _authService;
  final StorageService _storageService;

  // StreamControllers cho kiến trúc Reactive Data Streams
  final _myDocsController = StreamController<List<DocumentEntity>>.broadcast();
  final _sharedDocsController = StreamController<List<DocumentEntity>>.broadcast();
  final _allDocsController = StreamController<List<DocumentEntity>>.broadcast();

  SupabaseDocumentRepository({
    SupabaseClient? client,
    AuthService? authService,
    StorageService? storageService,
  })  : _client = client ?? SupabaseService.client,
        _authService = authService ?? AuthService(),
        _storageService = storageService ?? StorageService() {
    // Tự động tải dữ liệu ban đầu
    refreshData();
  }

  /// Cập nhật lại các luồng dữ liệu phản ứng
  Future<void> refreshData() async {
    try {
      final myDocs = await getMyDocuments();
      if (!_myDocsController.isClosed) {
        _myDocsController.add(myDocs);
      }

      final sharedDocs = await getSharedDocuments();
      if (!_sharedDocsController.isClosed) {
        _sharedDocsController.add(sharedDocs);
      }

      if (!_allDocsController.isClosed) {
        _allDocsController.add([...myDocs, ...sharedDocs]);
      }
    } catch (e) {
      // Khi user chưa đăng nhập hoặc mạng lỗi, không làm sập controller
    }
  }

  @override
  Stream<List<DocumentEntity>> watchMyDocuments() => _myDocsController.stream;

  @override
  Stream<List<DocumentEntity>> watchSharedDocuments() => _sharedDocsController.stream;

  @override
  Stream<List<DocumentEntity>> watchAllDocuments() => _allDocsController.stream;

  // ==============================================================================
  // USER OPERATIONS
  // ==============================================================================
  @override
  Future<void> upsertUser(AppUserEntity user) async {
    await _client.from('users').upsert({
      'id': user.id,
      'email': user.email.toLowerCase().trim(),
      'display_name': user.displayName,
      'photo_url': user.photoUrl,
    });
  }

  @override
  Future<AppUserEntity?> getUserByEmail(String email) async {
    final cleanEmail = email.toLowerCase().trim();
    final response = await _client
        .from('users')
        .select()
        .eq('email', cleanEmail)
        .maybeSingle();

    if (response == null) return null;
    return AppUserModel.fromJson(response);
  }

  // ==============================================================================
  // DOCUMENT QUERIES
  // ==============================================================================
  @override
  Future<List<DocumentEntity>> getMyDocuments() async {
    final uid = _authService.currentUid;
    if (uid == null) return [];

    final response = await _client
        .from('documents')
        .select('*, users:owner_id(email, display_name, photo_url)')
        .eq('owner_id', uid)
        .order('created_at', ascending: false);

    final list = (response as List<dynamic>)
        .map((json) => DocumentModel.fromJson(
              json as Map<String, dynamic>,
              currentUid: uid,
            ))
        .toList();

    return list;
  }

  @override
  Future<List<DocumentEntity>> getSharedDocuments() async {
    final uid = _authService.currentUid;
    if (uid == null) return [];

    // Truy vấn các bản ghi phân quyền của người dùng hiện tại kèm thông tin documents và chủ sở hữu
    final response = await _client
        .from('permissions')
        .select('role, documents(*, users:owner_id(email, display_name, photo_url))')
        .eq('user_id', uid)
        .order('created_at', ascending: false);

    final list = <DocumentEntity>[];
    for (final item in response as List<dynamic>) {
      final docJson = item['documents'] as Map<String, dynamic>?;
      if (docJson != null) {
        final assignedRole = item['role'] as String? ?? 'viewer';
        final model = DocumentModel.fromJson({
          ...docJson,
          'user_role': assignedRole,
        }, currentUid: uid);
        list.add(model);
      }
    }

    return list;
  }

  @override
  Future<List<DocumentEntity>> getAllDocuments() async {
    final myDocs = await getMyDocuments();
    final sharedDocs = await getSharedDocuments();
    return [...myDocs, ...sharedDocs];
  }

  @override
  Future<DocumentEntity?> getDocumentById(String id) async {
    final uid = _authService.currentUid;
    final response = await _client
        .from('documents')
        .select('*, users:owner_id(email, display_name, photo_url)')
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;

    // Xác định quyền hạn của người dùng đối với tài liệu này
    String role = 'viewer';
    if (response['owner_id'] == uid) {
      role = 'owner';
    } else if (uid != null) {
      final perm = await _client
          .from('permissions')
          .select('role')
          .eq('document_id', id)
          .eq('user_id', uid)
          .maybeSingle();
      if (perm != null) {
        role = perm['role'] as String? ?? 'viewer';
      }
    }

    return DocumentModel.fromJson({
      ...response,
      'user_role': role,
    }, currentUid: uid);
  }

  @override
  Future<List<DocumentEntity>> searchDocuments({
    required String query,
    required bool isSharedOnly,
  }) async {
    final uid = _authService.currentUid;
    if (uid == null) return [];

    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) {
      return isSharedOnly ? await getSharedDocuments() : await getMyDocuments();
    }

    if (!isSharedOnly) {
      // Tìm kiếm trong tài liệu của tôi bằng toán tử ILIKE
      final response = await _client
          .from('documents')
          .select('*, users:owner_id(email, display_name, photo_url)')
          .eq('owner_id', uid)
          .or('title.ilike.%$cleanQuery%,description.ilike.%$cleanQuery%')
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map((json) => DocumentModel.fromJson(
                json as Map<String, dynamic>,
                currentUid: uid,
              ))
          .toList();
    } else {
      // Tìm kiếm trong danh sách được chia sẻ
      final response = await _client
          .from('permissions')
          .select('role, documents!inner(*, users:owner_id(email, display_name, photo_url))')
          .eq('user_id', uid)
          .or('title.ilike.%$cleanQuery%,description.ilike.%$cleanQuery%',
              referencedTable: 'documents')
          .order('created_at', ascending: false);

      final list = <DocumentEntity>[];
      for (final item in response as List<dynamic>) {
        final docJson = item['documents'] as Map<String, dynamic>?;
        if (docJson != null) {
          final assignedRole = item['role'] as String? ?? 'viewer';
          final model = DocumentModel.fromJson({
            ...docJson,
            'user_role': assignedRole,
          }, currentUid: uid);
          list.add(model);
        }
      }
      return list;
    }
  }

  // ==============================================================================
  // C-U-D OPERATIONS
  // ==============================================================================
  @override
  Future<void> addDocument(DocumentEntity document) async {
    final uid = _authService.currentUid;
    if (uid == null) {
      throw StateError('Người dùng chưa đăng nhập. Vui lòng đăng nhập để nộp tài liệu.');
    }

    final entityWithUid = document.copyWith(ownerId: uid);
    final model = DocumentModel.fromEntity(entityWithUid);

    await _client.from('documents').insert(model.toSupabaseJson());
    await refreshData();
  }

  @override
  Future<void> updateDocument(DocumentEntity document) async {
    // Chỉ cập nhật tiêu đề và mô tả theo yêu cầu đặc tả
    await _client.from('documents').update({
      'title': document.title,
      'description': document.description,
    }).eq('id', document.id);

    await refreshData();
  }

  @override
  Future<void> deleteDocument(String id) async {
    // 1. Lấy thông tin tài liệu để trích xuất đường dẫn file trên Storage
    final doc = await getDocumentById(id);
    if (doc != null && doc.storagePath.isNotEmpty) {
      // 2. Xóa file vật lý trên Firebase Storage
      try {
        await _storageService.deleteFile(doc.storagePath);
      } catch (e) {
        // Ghi nhận lỗi nhưng vẫn tiếp tục xóa bản ghi nếu người dùng muốn dọn dẹp
      }
    }

    // 3. Xóa bản ghi trong Supabase (permissions liên quan sẽ tự động xóa nhờ ON DELETE CASCADE)
    await _client.from('documents').delete().eq('id', id);
    await refreshData();
  }

  // ==============================================================================
  // PERMISSIONS & SHARING OPERATIONS
  // ==============================================================================
  @override
  Future<List<DocumentPermissionEntity>> getDocumentPermissions(String documentId) async {
    final response = await _client
        .from('permissions')
        .select('*, users:user_id(email, display_name, photo_url)')
        .eq('document_id', documentId)
        .order('created_at', ascending: true);

    return (response as List<dynamic>)
        .map((json) => DocumentPermissionModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> shareDocument({
    required String documentId,
    required String targetEmail,
    required String role,
  }) async {
    final uid = _authService.currentUid;
    if (uid == null) throw StateError('Bạn chưa đăng nhập.');

    // 1. Kiểm tra tài khoản người nhận trong bảng users
    final targetUser = await getUserByEmail(targetEmail);
    if (targetUser == null) {
      throw StateError(
        'Không tìm thấy người dùng với email: $targetEmail.\n'
        'Người nhận cần phải đăng nhập vào ứng dụng ít nhất một lần để khởi tạo hồ sơ.',
      );
    }

    if (targetUser.id == uid) {
      throw ArgumentError('Bạn là chủ sở hữu, không thể tự chia sẻ tài liệu cho chính mình.');
    }

    // 2. Upsert quyền vào bảng permissions (nếu đã chia sẻ trước đó thì cập nhật vai trò mới)
    await _client.from('permissions').upsert(
      {
        'document_id': documentId,
        'user_id': targetUser.id,
        'role': role,
      },
      onConflict: 'document_id,user_id',
    );
  }

  @override
  Future<void> updatePermissionRole({
    required String permissionId,
    required String role,
  }) async {
    await _client.from('permissions').update({'role': role}).eq('id', permissionId);
  }

  @override
  Future<void> revokePermission(String permissionId) async {
    await _client.from('permissions').delete().eq('id', permissionId);
  }

  // ==============================================================================
  // BACKWARD COMPATIBILITY
  // ==============================================================================
  @override
  Future<void> toggleFavorite(String id) async {
    // Triển khai tương thích giao diện
  }

  @override
  Future<void> resetToDefaultData() async {
    await refreshData();
  }

  void dispose() {
    _myDocsController.close();
    _sharedDocsController.close();
    _allDocsController.close();
  }
}
