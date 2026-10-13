import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/app_user_entity.dart';
import '../../domain/repositories/i_document_repository.dart';
import '../../services/auth_service.dart';
import '../controllers/document_controller.dart';
import 'home_page.dart';
import 'login_page.dart';

/// Cổng điều hướng trạng thái Xác thực (AuthGate)
/// Điều hướng người dùng tới LoginPage hoặc HomePage dựa trên trạng thái Firebase Auth.
/// Tự động Upsert hồ sơ người dùng vào bảng 'users' của Supabase sau khi đăng nhập.
class AuthGate extends StatefulWidget {
  final AuthService authService;
  final IDocumentRepository repository;
  final DocumentController controller;
  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  const AuthGate({
    super.key,
    required this.authService,
    required this.repository,
    required this.controller,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  String? _lastSyncedUid;

  /// Đồng bộ thông tin người dùng lên bảng users của Supabase
  Future<void> _syncUserToSupabase(User user) async {
    if (_lastSyncedUid == user.uid) return;
    _lastSyncedUid = user.uid;

    try {
      final appUser = AppUserEntity(
        id: user.uid,
        email: user.email ?? '',
        displayName: user.displayName,
        photoUrl: user.photoURL,
        createdAt: user.metadata.creationTime ?? DateTime.now(),
      );

      await widget.repository.upsertUser(appUser);
      // Làm mới dữ liệu tài liệu sau khi xác thực thành công
      await widget.controller.refresh();
    } catch (e) {
      // Khi vừa đăng nhập, nếu chưa có custom claims hoặc mạng chậm có thể phát sinh log
      debugPrint('Lỗi upsert user vào Supabase: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: widget.authService.authStateChanges,
      builder: (context, snapshot) {
        // Trạng thái đang tải kết nối ban đầu
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final user = snapshot.data;

        // Nếu chưa đăng nhập: Điều hướng tới LoginPage
        if (user == null) {
          _lastSyncedUid = null;
          return LoginPage(authService: widget.authService);
        }

        // Nếu đã đăng nhập: Đồng bộ hồ sơ vào Supabase và chuyển vào HomePage
        _syncUserToSupabase(user);

        return HomePage(
          controller: widget.controller,
          onToggleTheme: widget.onToggleTheme,
          isDarkMode: widget.isDarkMode,
          authService: widget.authService,
        );
      },
    );
  }
}
