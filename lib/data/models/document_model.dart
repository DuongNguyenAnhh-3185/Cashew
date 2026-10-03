import '../../domain/entities/document_entity.dart';
import '../../domain/entities/document_type.dart';

/// Data Model đại diện cho dữ liệu tài liệu học tập ở tầng Data
/// Kế thừa DocumentEntity và bổ sung năng lực tuần tự hóa JSON (Serialization)
class DocumentModel extends DocumentEntity {
  const DocumentModel({
    required super.id,
    required super.title,
    required super.description,
    required super.subject,
    required super.type,
    required super.fileFormat,
    required super.urlOrPath,
    required super.fileSizeBytes,
    required super.createdAt,
    required super.updatedAt,
    super.isFavorite,
    super.tags,
  });

  /// Chuyển đổi từ JSON Map sang DocumentModel
  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      subject: json['subject'] as String,
      type: DocumentType.values.firstWhere(
        (t) => t.name == (json['type'] as String?),
        orElse: () => DocumentType.lecture,
      ),
      fileFormat: json['fileFormat'] as String? ?? 'PDF',
      urlOrPath: json['urlOrPath'] as String? ?? '',
      fileSizeBytes: (json['fileSizeBytes'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
      isFavorite: json['isFavorite'] as bool? ?? false,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
    );
  }

  /// Chuyển đổi từ DocumentModel sang JSON Map để lưu trữ
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'subject': subject,
      'type': type.name,
      'fileFormat': fileFormat,
      'urlOrPath': urlOrPath,
      'fileSizeBytes': fileSizeBytes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isFavorite': isFavorite,
      'tags': tags,
    };
  }

  /// Chuyển đổi từ DocumentEntity thuần túy sang DocumentModel
  factory DocumentModel.fromEntity(DocumentEntity entity) {
    return DocumentModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      subject: entity.subject,
      type: entity.type,
      fileFormat: entity.fileFormat,
      urlOrPath: entity.urlOrPath,
      fileSizeBytes: entity.fileSizeBytes,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isFavorite: entity.isFavorite,
      tags: entity.tags,
    );
  }
}
