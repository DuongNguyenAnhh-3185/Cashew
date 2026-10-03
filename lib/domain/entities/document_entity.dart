import 'document_type.dart';

/// Thực thể Tài liệu Học tập trong tầng Domain của kiến trúc Cashew
/// Hoàn toàn độc lập với UI Framework và Cơ sở Dữ liệu
class DocumentEntity {
  final String id;
  final String title;
  final String description;
  final String subject;
  final DocumentType type;
  final String fileFormat; // PDF, DOCX, PPTX, MP4, ZIP, LINK,...
  final String urlOrPath;
  final int fileSizeBytes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isFavorite;
  final List<String> tags;

  const DocumentEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.type,
    required this.fileFormat,
    required this.urlOrPath,
    required this.fileSizeBytes,
    required this.createdAt,
    required this.updatedAt,
    this.isFavorite = false,
    this.tags = const [],
  });

  /// Tạo bản sao với các thuộc tính được cập nhật (Immutability pattern)
  DocumentEntity copyWith({
    String? id,
    String? title,
    String? description,
    String? subject,
    DocumentType? type,
    String? fileFormat,
    String? urlOrPath,
    int? fileSizeBytes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFavorite,
    List<String>? tags,
  }) {
    return DocumentEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      subject: subject ?? this.subject,
      type: type ?? this.type,
      fileFormat: fileFormat ?? this.fileFormat,
      urlOrPath: urlOrPath ?? this.urlOrPath,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFavorite: isFavorite ?? this.isFavorite,
      tags: tags ?? this.tags,
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
    return 'DocumentEntity(id: $id, title: $title, subject: $subject, type: ${type.name})';
  }
}
