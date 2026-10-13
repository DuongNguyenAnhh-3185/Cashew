import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/services/document_filter_service.dart';
import '../controllers/document_controller.dart';

/// Thanh công cụ tìm kiếm và lọc môn học, sắp xếp theo phong cách hiện đại
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
    final subjects = widget.controller.availableSubjects;
    final selectedSub = widget.controller.selectedSubject ?? 'Tất cả';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Ô Tìm kiếm kết hợp Nút Sắp xếp & Nút Reset
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => widget.controller.setSearchQuery(value),
                  style: TextStyle(
                    fontSize: 13.5,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Tìm theo tên bài giảng, tệp, tag...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.primary),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              widget.controller.setSearchQuery('');
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Menu chọn Sắp xếp
              PopupMenuButton<DocumentSortOption>(
                tooltip: 'Sắp xếp danh sách',
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                color: isDark ? AppColors.surfaceDark : Colors.white,
                initialValue: widget.controller.sortOption,
                onSelected: (option) => widget.controller.setSortOption(option),
                itemBuilder: (context) {
                  return DocumentSortOption.values
                      .where((option) =>
                          option != DocumentSortOption.sizeDesc &&
                          option != DocumentSortOption.sizeAsc)
                      .map((option) {
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
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
                  child: const Icon(Icons.swap_vert_rounded, size: 20, color: AppColors.primary),
                ),
              ),

              // Nút xóa toàn bộ bộ lọc nếu đang hoạt động
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
                    padding: const EdgeInsets.all(12),
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
        ),

        // Hàng Capsule Môn Học cuộn ngang (Subject Filter Pills)
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 4),
          child: SizedBox(
            height: 34,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: subjects.length,
              itemBuilder: (context, index) {
                final subject = subjects[index];
                final isSelected = (subject == selectedSub);
                final docCount = subject == 'Tất cả'
                    ? widget.controller.totalDocumentsCount
                    : widget.controller.allDocuments.where((d) => d.subject == subject).length;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () {
                      if (subject == 'Tất cả') {
                        widget.controller.setSelectedSubject(null);
                      } else {
                        widget.controller.setSelectedSubject(isSelected ? null : subject);
                      }
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark ? AppColors.primary : AppColors.primary)
                            : (isDark ? AppColors.surfaceDark : Colors.white),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : (isDark ? AppColors.borderDark : AppColors.borderLight),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isSelected) ...[
                            const Icon(Icons.check_rounded, size: 14, color: Colors.white),
                            const SizedBox(width: 4),
                          ],
                          Text(
                            subject,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? AppColors.textPrimaryDark : AppColors.textSecondaryLight),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white.withValues(alpha: 0.25)
                                  : (isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.05)),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$docCount',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? Colors.white
                                    : (isDark ? Colors.white60 : Colors.black54),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}