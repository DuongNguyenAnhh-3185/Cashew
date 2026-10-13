import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/document_entity.dart';
import '../../services/auth_service.dart';
import '../controllers/document_controller.dart';
import '../widgets/document_card.dart';
import '../widgets/document_stats_header.dart';
import '../widgets/empty_documents_view.dart';
import '../widgets/search_and_filter_bar.dart';
import '../widgets/type_filter_chips.dart';
import 'document_detail_page.dart';
import 'document_form_page.dart';

/// Màn hình chính Cashew StudyDocs: Phân chia 2 Tab "Của tôi" và "Được chia sẻ với tôi"
class HomePage extends StatefulWidget {
  final DocumentController controller;
  final VoidCallback onToggleTheme;
  final bool isDarkMode;
  final AuthService? authService;

  const HomePage({
    super.key,
    required this.controller,
    required this.onToggleTheme,
    required this.isDarkMode,
    this.authService,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.controller.currentTabIndex,
    );
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        widget.controller.setTabIndex(_tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _navigateToForm([DocumentEntity? docToEdit]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DocumentFormPage(
          controller: widget.controller,
          documentToEdit: docToEdit,
        ),
      ),
    );
  }

  void _navigateToDetail(String docId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DocumentDetailPage(
          documentId: docId,
          controller: widget.controller,
        ),
      ),
    );
  }

  Future<void> _handleSignOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất khỏi tài khoản Google?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final auth = widget.authService ?? widget.controller.authService;
      await auth.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final auth = widget.authService ?? widget.controller.authService;
    final currentUser = auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.folder_shared_rounded, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cashew StudyDocs',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                  ),
                  Text(
                    currentUser?.email ?? 'Quản lý tài liệu học tập',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
            tooltip: widget.isDarkMode ? 'Chế độ sáng' : 'Chế độ tối',
            onPressed: widget.onToggleTheme,
          ),
          // User Avatar & Logout Popup Menu
          PopupMenuButton<String>(
            icon: CircleAvatar(
              radius: 15,
              backgroundColor: theme.colorScheme.primaryContainer,
              backgroundImage: currentUser?.photoURL != null
                  ? NetworkImage(currentUser!.photoURL!)
                  : null,
              child: currentUser?.photoURL == null
                  ? Text(
                      (currentUser?.email ?? 'U').substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    )
                  : null,
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            onSelected: (val) {
              if (val == 'refresh') {
                widget.controller.refresh();
              } else if (val == 'signout') {
                _handleSignOut();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentUser?.displayName ?? 'Người dùng',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    Text(
                      currentUser?.email ?? '',
                      style: TextStyle(fontSize: 11, color: theme.textTheme.bodySmall?.color),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh_rounded, size: 18),
                    SizedBox(width: 8),
                    Text('Làm mới dữ liệu'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'signout',
                child: Row(
                  children: [
                    Icon(Icons.logout_rounded, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Đăng xuất', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorWeight: 3,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          tabs: [
            Tab(
              icon: const Icon(Icons.folder_rounded, size: 20),
              child: ListenableBuilder(
                listenable: widget.controller,
                builder: (context, _) => Text(
                  'Của tôi (${widget.controller.myDocsCount})',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Tab(
              icon: const Icon(Icons.people_rounded, size: 20),
              child: ListenableBuilder(
                listenable: widget.controller,
                builder: (context, _) => Text(
                  'Được chia sẻ với tôi (${widget.controller.sharedDocsCount})',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
      body: ListenableBuilder(
        listenable: widget.controller,
        builder: (context, _) {
          return RefreshIndicator(
            onRefresh: () => widget.controller.refresh(),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // 1. Thống kê nhanh
                SliverToBoxAdapter(
                  child: DocumentStatsHeader(controller: widget.controller),
                ),

                // 2. Thanh tìm kiếm có Debounce
                SliverToBoxAdapter(
                  child: SearchAndFilterBar(controller: widget.controller),
                ),

                // 3. Chips lọc theo phân loại
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4, bottom: 8),
                    child: TypeFilterChips(controller: widget.controller),
                  ),
                ),

                // Thông báo trạng thái nếu có
                if (widget.controller.errorMessage != null)
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.controller.errorMessage!,
                              style: const TextStyle(color: Colors.red, fontSize: 13),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 16, color: Colors.red),
                            onPressed: widget.controller.clearMessages,
                          ),
                        ],
                      ),
                    ),
                  ),

                // 4. Danh sách tài liệu
                if (widget.controller.isLoading && widget.controller.currentTabDocuments.isEmpty)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (widget.controller.filteredDocuments.isEmpty)
                  SliverFillRemaining(
                    child: EmptyDocumentsView(
                      searchQuery: widget.controller.searchQuery,
                      onResetFilters: widget.controller.clearAllFilters,
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final doc = widget.controller.filteredDocuments[index];
                        return DocumentCard(
                          document: doc,
                          controller: widget.controller,
                          onTap: () => _navigateToDetail(doc.id),
                          onEdit: () => _navigateToForm(doc),
                        );
                      },
                      childCount: widget.controller.filteredDocuments.length,
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),
          );
        },
      ),
      // Chỉ hiển thị FAB thêm tài liệu ở Tab "Của tôi"
      floatingActionButton: ListenableBuilder(
        listenable: widget.controller,
        builder: (context, _) {
          if (widget.controller.currentTabIndex != 0) {
            return const SizedBox.shrink();
          }
          return FloatingActionButton.extended(
            icon: const Icon(Icons.cloud_upload_rounded),
            label: const Text('Nộp tài liệu', style: TextStyle(fontWeight: FontWeight.w800)),
            onPressed: () => _navigateToForm(),
          );
        },
      ),
    );
  }
}