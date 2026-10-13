import 'document_type.dart';

/// Thực thể Tài liệu trong hệ thống Cashew StudyDocs
/// Kết hợp Metadata cơ sở dữ liệu Supabase và tệp vật lý Firebase Storage
class DocumentEntity {
  final String id;
  final String ownerId;
  final String title;
  final String description;
  final String fileName;
  final String fileType; // PDF, DOCX, ZIP, v.v.
  final int fileSize; // Dung lượng bytes
  final String storagePath; // documents/{owner_id}/{doc_id}/{fileName}
  final DateTime createdAt;
  final DateTime updatedAt;

  // Thuộc tính tương thích giao diện Cashew StudyDocs
  final String subject;
  final DocumentType type;
  final bool isFavorite;
  final List<String> tags;

  // Quyền hạn của người dùng hiện tại đối với tài liệu này ('owner', 'editor', 'viewer')
  final String currentUserRole;
  final String? ownerEmail;
  final String? ownerDisplayName;

  const DocumentEntity({
    required this.id,
    this.ownerId = '',
    required this.title,
    this.description = '',
    this.fileName = '',
    this.fileType = 'PDF',
    this.fileSize = 0,
    this.storagePath = '',
    required this.createdAt,
    required this.updatedAt,
    this.subject = 'Chung',
    this.type = DocumentType.lecture,
    this.isFavorite = false,
    this.tags = const [],
    this.currentUserRole = 'owner',
    this.ownerEmail,
    this.ownerDisplayName,
  });

  // Getter tương thích ngược cho các màn hình cũ
  int get fileSizeBytes => fileSize;
  String get fileFormat => fileType;
  String get urlOrPath => storagePath;

  // Tiện ích kiểm tra quyền hạn
  bool get isOwner => currentUserRole == 'owner';
  bool get isEditor => currentUserRole == 'editor';
  bool get isViewer => currentUserRole == 'viewer';
  bool get canEdit => isOwner || isEditor;
  bool get canDelete => isOwner;
  bool get canShare => isOwner;

  DocumentEntity copyWith({
    String? id,
    String? ownerId,
    String? title,
    String? description,
    String? fileName,
    String? fileType,
    int? fileSize,
    String? storagePath,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? subject,
    DocumentType? type,
    bool? isFavorite,
    List<String>? tags,
    String? currentUserRole,
    String? ownerEmail,
    String? ownerDisplayName,
    // Thuộc tính tương thích
    String? fileFormat,
    String? urlOrPath,
    int? fileSizeBytes,
  }) {
    return DocumentEntity(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      description: description ?? this.description,
      fileName: fileName ?? this.fileName,
      fileType: fileType ?? fileFormat ?? this.fileType,
      fileSize: fileSize ?? fileSizeBytes ?? this.fileSize,
      storagePath: storagePath ?? urlOrPath ?? this.storagePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      subject: subject ?? this.subject,
      type: type ?? this.type,
      isFavorite: isFavorite ?? this.isFavorite,
      tags: tags ?? this.tags,
      currentUserRole: currentUserRole ?? this.currentUserRole,
      ownerEmail: ownerEmail ?? this.ownerEmail,
      ownerDisplayName: ownerDisplayName ?? this.ownerDisplayName,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DocumentEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'DocumentEntity(id: $id, title: $title, owner: $ownerId, role: $currentUserRole)';
  }
}
