import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'data/datasources/document_local_data_source.dart';
import 'data/repositories/document_repository_impl.dart';
import 'domain/repositories/i_document_repository.dart';
import 'domain/services/document_filter_service.dart';
import 'domain/services/document_validation_service.dart';
import 'presentation/controllers/document_controller.dart';
import 'presentation/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Khoi tao SharedPreferences cho Data Layer
  final prefs = await SharedPreferences.getInstance();

  // Khoi tao cac thanh phan theo dung kien truc Cashew (Dependency Injection)
  final IDocumentLocalDataSource localDataSource = DocumentLocalDataSource(prefs);
  final IDocumentRepository repository = DocumentRepositoryImpl(localDataSource);
  const filterService = DocumentFilterService();
  const validationService = DocumentValidationService();

  // Khoi tao Controller cho Presentation Layer
  final documentController = DocumentController(
    repository: repository,
    filterService: filterService,
    validationService: validationService,
  );

  runApp(CashewStudyDocsApp(
    controller: documentController,
    prefs: prefs,
  ));
}

/// Root Widget cua ung dung
class CashewStudyDocsApp extends StatefulWidget {
  final DocumentController controller;
  final SharedPreferences prefs;

  const CashewStudyDocsApp({
    super.key,
    required this.controller,
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
      home: HomePage(
        controller: widget.controller,
        onToggleTheme: _toggleTheme,
        isDarkMode: _themeMode == ThemeMode.dark ||
            (_themeMode == ThemeMode.system &&
                MediaQuery.platformBrightnessOf(context) == Brightness.dark),
      ),
    );
  }
}