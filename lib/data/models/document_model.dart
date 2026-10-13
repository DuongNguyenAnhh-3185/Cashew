import '../../domain/entities/document_entity.dart';
import '../../domain/entities/document_type.dart';

/// Data Model đại diện cho dữ liệu tài liệu trên Supabase
class DocumentModel extends DocumentEntity {
  const DocumentModel({
    required super.id,
    super.ownerId = '',
    required super.title,
    super.description = '',
    super.fileName = '',
    super.fileType = 'PDF',
    super.fileSize = 0,
    super.storagePath = '',
    required super.createdAt,
    required super.updatedAt,
    super.subject = 'Chung',
    super.type = DocumentType.lecture,
    super.isFavorite = false,
    super.tags = const [],
    super.currentUserRole = 'owner',
    super.ownerEmail,
    super.ownerDisplayName,
  });

  /// Chuyển đổi từ dữ liệu dòng Supabase PostgreSQL (hoặc SharedPreferences cũ) sang DocumentModel
  factory DocumentModel.fromJson(Map<String, dynamic> json, {String? currentUid}) {
    // Nhận diện dữ liệu liên kết bảng users (nếu có join)
    final ownerData = json['owner'] as Map<String, dynamic>? ?? json['users'] as Map<String, dynamic>?;

    final ownerId = json['owner_id'] as String? ?? json['ownerId'] as String? ?? '';
    final roleFromData = json['user_role'] as String? ?? json['currentUserRole'] as String?;
    
    // Tự động xác định vai trò nếu có currentUid
    String role = 'viewer';
    if (roleFromData != null) {
      role = roleFromData;
    } else if (currentUid != null && currentUid.isNotEmpty) {
      if (ownerId == currentUid) {
        role = 'owner';
      }
    }

    final fName = json['file_name'] as String? ?? json['fileName'] as String? ?? '';
    final fType = json['file_type'] as String? ?? json['fileType'] as String? ?? json['fileFormat'] as String? ?? 'PDF';
    final fSize = (json['file_size'] as num?)?.toInt() ?? 
                  (json['fileSize'] as num?)?.toInt() ?? 
                  (json['fileSizeBytes'] as num?)?.toInt() ?? 0;
    final sPath = json['storage_path'] as String? ?? json['storagePath'] as String? ?? json['urlOrPath'] as String? ?? '';

    return DocumentModel(
      id: json['id'] as String,
      ownerId: ownerId,
      title: json['title'] as String? ?? 'Không có tiêu đề',
      description: json['description'] as String? ?? '',
      fileName: fName,
      fileType: fType,
      fileSize: fSize,
      storagePath: sPath,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? json['createdAt'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? json['updatedAt'] as String? ?? '') ?? DateTime.now(),
      subject: json['subject'] as String? ?? 'Chung',
      type: DocumentType.values.firstWhere(
        (t) => t.name == (json['type'] as String?),
        orElse: () => DocumentType.lecture,
      ),
      isFavorite: json['isFavorite'] as bool? ?? false,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      currentUserRole: role,
      ownerEmail: ownerData?['email'] as String? ?? json['owner_email'] as String?,
      ownerDisplayName: ownerData?['display_name'] as String? ?? json['owner_display_name'] as String?,
    );
  }

  /// Chuyển đổi sang JSON Map cho việc ghi vào Supabase
  Map<String, dynamic> toSupabaseJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'title': title,
      'description': description,
      'file_name': fileName,
      'file_type': fileType,
      'file_size': fileSize,
      'storage_path': storagePath,
      // Không cần gửi created_at, updated_at nếu tạo mới vì Postgres có default và trigger
    };
  }

  /// Tuần tự hóa JSON tương thích lưu trữ
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'title': title,
      'description': description,
      'file_name': fileName,
      'file_type': fileType,
      'file_size': fileSize,
      'storage_path': storagePath,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'subject': subject,
      'type': type.name,
      'isFavorite': isFavorite,
      'tags': tags,
      'currentUserRole': currentUserRole,
    };
  }

  /// Chuyển đổi từ DocumentEntity thuần túy sang DocumentModel
  factory DocumentModel.fromEntity(DocumentEntity entity) {
    return DocumentModel(
      id: entity.id,
      ownerId: entity.ownerId,
      title: entity.title,
      description: entity.description,
      fileName: entity.fileName,
      fileType: entity.fileType,
      fileSize: entity.fileSize,
      storagePath: entity.storagePath,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      subject: entity.subject,
      type: entity.type,
      isFavorite: entity.isFavorite,
      tags: entity.tags,
      currentUserRole: entity.currentUserRole,
      ownerEmail: entity.ownerEmail,
      ownerDisplayName: entity.ownerDisplayName,
    );
  }
}
