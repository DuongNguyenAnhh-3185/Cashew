import '../domain/entities/document_entity.dart';
import '../domain/entities/document_type.dart';
import '../domain/services/document_filter_service.dart';

/// Use Case: Tìm kiếm, lọc đa tiêu chí và sắp xếp danh sách tài liệu
class SearchDocumentsUseCase {
  final DocumentFilterService filterService;

  const SearchDocumentsUseCase([this.filterService = const DocumentFilterService()]);

  List<DocumentEntity> execute({
    required List<DocumentEntity> documents,
    String searchQuery = '',
    String? selectedSubject,
    DocumentType? selectedType,
    bool onlyFavorites = false,
    DocumentSortOption sortOption = DocumentSortOption.dateDesc,
  }) {
    return filterService.filterAndSort(
      documents: documents,
      searchQuery: searchQuery,
      selectedSubject: selectedSubject,
      selectedType: selectedType,
      onlyFavorites: onlyFavorites,
      sortOption: sortOption,
    );
  }
}
