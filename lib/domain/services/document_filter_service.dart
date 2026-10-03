import '../entities/document_entity.dart';
import '../entities/document_type.dart';

enum DocumentSortOption {
  dateDesc,
  dateAsc,
  titleAsc,
  titleDesc,
  sizeDesc,
  sizeAsc;

  String get displayName {
    switch (this) {
      case DocumentSortOption.dateDesc:
        return 'Ngày tạo: Mới nhất';
      case DocumentSortOption.dateAsc:
        return 'Ngày tạo: Cũ nhất';
      case DocumentSortOption.titleAsc:
        return 'Tiêu đề: A - Z';
      case DocumentSortOption.titleDesc:
        return 'Tiêu đề: Z - A';
      case DocumentSortOption.sizeDesc:
        return 'Dung lượng: Lớn nhất';
      case DocumentSortOption.sizeAsc:
        return 'Dung lượng: Nhỏ nhất';
    }
  }
}

/// Dịch vụ nghiệp vụ độc lập xử lý lọc, tìm kiếm và sắp xếp tài liệu
class DocumentFilterService {
  const DocumentFilterService();

  /// Lọc và sắp xếp danh sách tài liệu theo các tiêu chí
  List<DocumentEntity> filterAndSort({
    required List<DocumentEntity> documents,
    String searchQuery = '',
    String? selectedSubject,
    DocumentType? selectedType,
    bool onlyFavorites = false,
    DocumentSortOption sortOption = DocumentSortOption.dateDesc,
  }) {
    final cleanQuery = searchQuery.trim().toLowerCase();

    final filtered = documents.where((doc) {
      // 1. Lọc theo trạng thái yêu thích
      if (onlyFavorites && !doc.isFavorite) {
        return false;
      }

      // 2. Lọc theo môn học
      if (selectedSubject != null &&
          selectedSubject.isNotEmpty &&
          selectedSubject != 'Tất cả' &&
          doc.subject != selectedSubject) {
        return false;
      }

      // 3. Lọc theo loại tài liệu
      if (selectedType != null && doc.type != selectedType) {
        return false;
      }

      // 4. Lọc theo từ khóa tìm kiếm (tiêu đề, mô tả, môn học, tag)
      if (cleanQuery.isNotEmpty) {
        final matchTitle = doc.title.toLowerCase().contains(cleanQuery);
        final matchDesc = doc.description.toLowerCase().contains(cleanQuery);
        final matchSubject = doc.subject.toLowerCase().contains(cleanQuery);
        final matchTag = doc.tags.any((tag) => tag.toLowerCase().contains(cleanQuery));
        final matchFormat = doc.fileFormat.toLowerCase().contains(cleanQuery);

        if (!matchTitle && !matchDesc && !matchSubject && !matchTag && !matchFormat) {
          return false;
        }
      }

      return true;
    }).toList();

    // Sắp xếp
    filtered.sort((a, b) {
      switch (sortOption) {
        case DocumentSortOption.dateDesc:
          return b.createdAt.compareTo(a.createdAt);
        case DocumentSortOption.dateAsc:
          return a.createdAt.compareTo(b.createdAt);
        case DocumentSortOption.titleAsc:
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        case DocumentSortOption.titleDesc:
          return b.title.toLowerCase().compareTo(a.title.toLowerCase());
        case DocumentSortOption.sizeDesc:
          return b.fileSizeBytes.compareTo(a.fileSizeBytes);
        case DocumentSortOption.sizeAsc:
          return a.fileSizeBytes.compareTo(b.fileSizeBytes);
      }
    });

    return filtered;
  }

  /// Tính toán số liệu thống kê từ danh sách tài liệu
  Map<DocumentType, int> calculateCountByType(List<DocumentEntity> documents) {
    final map = <DocumentType, int>{
      for (final type in DocumentType.values) type: 0,
    };
    for (final doc in documents) {
      map[doc.type] = (map[doc.type] ?? 0) + 1;
    }
    return map;
  }

  /// Thống kê số lượng theo môn học
  Map<String, int> calculateCountBySubject(List<DocumentEntity> documents) {
    final map = <String, int>{};
    for (final doc in documents) {
      map[doc.subject] = (map[doc.subject] ?? 0) + 1;
    }
    return map;
  }
}
