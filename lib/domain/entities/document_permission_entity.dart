/// Entity đại diện cho quyền chia sẻ tài liệu
class DocumentPermissionEntity {
  final String id;
  final String documentId;
  final String userId;
  final String role; // 'viewer' | 'editor'
  final DateTime createdAt;
  
  // Thông tin mở rộng của người nhận quyền (để hiển thị trên UI)
  final String? userEmail;
  final String? userDisplayName;
  final String? userPhotoUrl;

  const DocumentPermissionEntity({
    required this.id,
    required this.documentId,
    required this.userId,
    required this.role,
    required this.createdAt,
    this.userEmail,
    this.userDisplayName,
    this.userPhotoUrl,
  });

  bool get isEditor => role == 'editor';
  bool get isViewer => role == 'viewer';

  DocumentPermissionEntity copyWith({
    String? id,
    String? documentId,
    String? userId,
    String? role,
    DateTime? createdAt,
    String? userEmail,
    String? userDisplayName,
    String? userPhotoUrl,
  }) {
    return DocumentPermissionEntity(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      userEmail: userEmail ?? this.userEmail,
      userDisplayName: userDisplayName ?? this.userDisplayName,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
    );
  }
}
