import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cashew_study_docs/main.dart';
import 'package:cashew_study_docs/data/datasources/document_local_data_source.dart';
import 'package:cashew_study_docs/data/repositories/document_repository_impl.dart';
import 'package:cashew_study_docs/domain/services/document_filter_service.dart';
import 'package:cashew_study_docs/domain/services/document_validation_service.dart';
import 'package:cashew_study_docs/presentation/controllers/document_controller.dart';
import 'package:cashew_study_docs/presentation/widgets/document_stats_header.dart';
import 'package:cashew_study_docs/presentation/widgets/search_and_filter_bar.dart';

void main() {
  testWidgets('Kiểm thử giao diện Widget chính của ứng dụng Cashew StudyDocs', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final localDataSource = DocumentLocalDataSource(prefs);
    final repository = DocumentRepositoryImpl(localDataSource);
    const filterService = DocumentFilterService();
    const validationService = DocumentValidationService();

    final controller = DocumentController(
      repository: repository,
      filterService: filterService,
      validationService: validationService,
    );

    await tester.pumpWidget(CashewStudyDocsApp(
      controller: controller,
      prefs: prefs,
    ));

    // Đợi async load dữ liệu mẫu
    await tester.pumpAndSettle();

    // Xác nhận tiêu đề App hiển thị đúng
    expect(find.text('Cashew StudyDocs'), findsOneWidget);
    expect(find.text('Quản lý tài liệu học tập'), findsOneWidget);

    // Xác nhận Widget thống kê tổng quan (DocumentStatsHeader) xuất hiện
    expect(find.byType(DocumentStatsHeader), findsOneWidget);

    // Xác nhận Thanh tìm kiếm (SearchAndFilterBar) xuất hiện
    expect(find.byType(SearchAndFilterBar), findsOneWidget);

    // Xác nhận nút Thêm tài liệu nổi (FAB)
    expect(find.text('Thêm tài liệu'), findsOneWidget);
  });
}