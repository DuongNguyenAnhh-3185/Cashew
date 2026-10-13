import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/supabase_document_repository.dart';
import 'domain/repositories/i_document_repository.dart';
import 'domain/services/document_filter_service.dart';
import 'domain/services/document_validation_service.dart';
import 'presentation/controllers/document_controller.dart';
import 'presentation/pages/auth_gate.dart';
import 'services/auth_service.dart';
import 'services/storage_service.dart';
import 'services/supabase_service.dart';
import 'usecases/usecases.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Nạp các biến môi trường từ tệp .env (Không hardcode thông tin bí mật)
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('⚠️ Lưu ý: Không tìm thấy hoặc không thể đọc tệp .env ($e). Sử dụng cấu hình dự phòng.');
  }

  // 2. Khởi tạo Persistent Storage cục bộ (SharedPreferences cho Theme)
  final prefs = await SharedPreferences.getInstance();

  // 3. Khởi tạo Firebase Core
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('⚠️ Firebase.initializeApp thông báo: $e');
  }

  // 4. Khởi tạo Supabase kết hợp Firebase accessToken
  try {
    await SupabaseService.initialize();
  } catch (e) {
    debugPrint('⚠️ SupabaseService.initialize thông báo: $e');
  }

  // 5. Khởi tạo Tầng Services
  final authService = AuthService();
  final storageService = StorageService();

  // 6. Khởi tạo Tầng Data & Repository
  final IDocumentRepository repository = SupabaseDocumentRepository(
    authService: authService,
    storageService: storageService,
  );

  // 7. Khởi tạo Tầng Domain Services
  const filterService = DocumentFilterService();
  const validationService = DocumentValidationService();

  // 8. Khởi tạo Tầng Use Cases
  final watchUseCase = WatchDocumentsUseCase(repository);
  final addUseCase = AddDocumentUseCase(repository: repository, validationService: validationService);
  final updateUseCase = UpdateDocumentUseCase(repository: repository, validationService: validationService);
  final deleteUseCase = DeleteDocumentUseCase(repository);
  final searchUseCase = SearchDocumentsUseCase(filterService);
  final shareUseCase = ShareDocumentUseCase(repository);
  final getPermissionsUseCase = GetDocumentPermissionsUseCase(repository);
  final updatePermissionRoleUseCase = UpdatePermissionRoleUseCase(repository);
  final revokePermissionUseCase = RevokePermissionUseCase(repository);

  // 9. Khởi tạo Tầng Presentation Controller (ChangeNotifier)
  final documentController = DocumentController(
    repository: repository,
    authService: authService,
    storageService: storageService,
    filterService: filterService,
    validationService: validationService,
    watchUseCase: watchUseCase,
    addUseCase: addUseCase,
    updateUseCase: updateUseCase,
    deleteUseCase: deleteUseCase,
    searchUseCase: searchUseCase,
    shareUseCase: shareUseCase,
    getPermissionsUseCase: getPermissionsUseCase,
    updatePermissionRoleUseCase: updatePermissionRoleUseCase,
    revokePermissionUseCase: revokePermissionUseCase,
  );

  runApp(CashewStudyDocsApp(
    controller: documentController,
    authService: authService,
    repository: repository,
    prefs: prefs,
  ));
}

/// Root Widget của ứng dụng Cashew StudyDocs
class CashewStudyDocsApp extends StatefulWidget {
  final DocumentController controller;
  final AuthService authService;
  final IDocumentRepository repository;
  final SharedPreferences prefs;

  const CashewStudyDocsApp({
    super.key,
    required this.controller,
    required this.authService,
    required this.repository,
    required this.prefs,
  });

  @override
  State<CashewStudyDocsApp> createState() => _CashewStudyDocsAppState();
}

class _CashewStudyDocsAppState extends State<CashewStudyDocsApp> {
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    final savedTheme = widget.prefs.getString(AppConstants.storageKeyTheme);
    if (savedTheme == 'dark') {
      _themeMode = ThemeMode.dark;
    } else if (savedTheme == 'light') {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.system;
    }
  }

  void _toggleTheme() {
    setState(() {
      if (_themeMode == ThemeMode.dark) {
        _themeMode = ThemeMode.light;
        widget.prefs.setString(AppConstants.storageKeyTheme, 'light');
      } else {
        _themeMode = ThemeMode.dark;
        widget.prefs.setString(AppConstants.storageKeyTheme, 'dark');
      }
    });
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      // AuthGate đóng vai trò cổng điều hướng trạng thái đăng nhập
      home: AuthGate(
        authService: widget.authService,
        repository: widget.repository,
        controller: widget.controller,
        onToggleTheme: _toggleTheme,
        isDarkMode: _themeMode == ThemeMode.dark ||
            (_themeMode == ThemeMode.system &&
                MediaQuery.platformBrightnessOf(context) == Brightness.dark),
      ),
    );
  }
}