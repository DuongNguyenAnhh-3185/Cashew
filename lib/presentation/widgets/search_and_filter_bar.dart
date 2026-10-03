import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/services/document_filter_service.dart';
import '../controllers/document_controller.dart';

/// Thanh công cụ tìm kiếm và lọc môn học, sắp xếp
class SearchAndFilterBar extends StatefulWidget {
  final DocumentController controller;

  const SearchAndFilterBar({super.key, required this.controller});

  @override
  State<SearchAndFilterBar> createState() => _SearchAndFilterBarState();
}

class _SearchAndFilterBarState extends State<SearchAndFilterBar> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.controller.searchQuery);
  }

  @override
  void didUpdateWidget(covariant SearchAndFilterBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller.searchQuery != _searchController.text) {
      _searchController.text = widget.controller.searchQuery;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        children: [
          // Ô tìm kiếm thời gian thực
          TextField(
            controller: _searchController,
            onChanged: (value) => widget.controller.setSearchQuery(value),
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
            decoration: InputDecoration(
              hintText: 'Tìm kiếm theo tên tài liệu, môn học, tag...',
              prefixIcon: const Icon(Icons.search_rounded, size: 22, color: AppColors.primary),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        widget.controller.setSearchQuery('');
                      },
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 8),
          // Hàng lọc Môn học & Sắp xếp
          Row(
            children: [
              // Chọn Môn học
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: widget.controller.selectedSubject ?? 'Tất cả',
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                      dropdownColor: isDark ? AppColors.surfaceDark : Colors.white,
                      items: widget.controller.availableSubjects.map((subject) {
                        return DropdownMenuItem<String>(
                          value: subject,
                          child: Text(
                            subject,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        widget.controller.setSelectedSubject(value);
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Menu chọn Sắp xếp
              PopupMenuButton<DocumentSortOption>(
                tooltip: 'Sắp xếp tài liệu',
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                color: isDark ? AppColors.surfaceDark : Colors.white,
                initialValue: widget.controller.sortOption,
                onSelected: (option) => widget.controller.setSortOption(option),
                itemBuilder: (context) {
                  return DocumentSortOption.values.map((option) {
                    final isSelected = widget.controller.sortOption == option;
                    return PopupMenuItem<DocumentSortOption>(
                      value: option,
                      child: Row(
                        children: [
                          Icon(
                            isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                            size: 18,
                            color: isSelected ? AppColors.primary : Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            option.displayName,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected
                                  ? AppColors.primary
                                  : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
                  child: const Icon(Icons.sort_rounded, size: 20, color: AppColors.primary),
                ),
              ),
              // Nút xóa bộ lọc nếu đang có bộ lọc hoạt động
              if (widget.controller.searchQuery.isNotEmpty ||
                  widget.controller.selectedSubject != null ||
                  widget.controller.selectedType != null ||
                  widget.controller.onlyFavorites) ...[
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    _searchController.clear();
                    widget.controller.clearAllFilters();
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                    ),
                    child: const Icon(Icons.filter_alt_off_rounded, size: 20, color: AppColors.error),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}