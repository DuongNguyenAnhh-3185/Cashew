import '../../domain/entities/document_permission_entity.dart';

/// Data Model cho Quyền chia sẻ, ánh xạ với bảng 'permissions' trên Supabase
class DocumentPermissionModel extends DocumentPermissionEntity {
  const DocumentPermissionModel({
    required super.id,
    required super.documentId,
    required super.userId,
    required super.role,
    required super.createdAt,
    super.userEmail,
    super.userDisplayName,
    super.userPhotoUrl,
  });

  factory DocumentPermissionModel.fromJson(Map<String, dynamic> json) {
    // Trường hợp Supabase join với bảng users: user:users(email, display_name, photo_url)
    final userData = json['users'] as Map<String, dynamic>?;

    return DocumentPermissionModel(
      id: json['id'] as String,
      documentId: json['document_id'] as String,
      userId: json['user_id'] as String,
      role: json['role'] as String? ?? 'viewer',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      userEmail: userData?['email'] as String? ?? json['user_email'] as String?,
      userDisplayName: userData?['display_name'] as String? ?? json['user_display_name'] as String?,
      userPhotoUrl: userData?['photo_url'] as String? ?? json['user_photo_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'document_id': documentId,
      'user_id': userId,
      'role': role,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
