import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../domain/entities/app_user_entity.dart';

/// Dịch vụ Xác thực người dùng thông qua Firebase Auth và Google Sign-In
class AuthService {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  AuthService({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  /// Luồng theo dõi trạng thái đăng nhập thời gian thực
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Thông tin người dùng hiện tại
  User? get currentUser => _firebaseAuth.currentUser;
  String? get currentUid => _firebaseAuth.currentUser?.uid;
  String? get currentEmail => _firebaseAuth.currentUser?.email;

  /// Lấy Firebase ID Token (JWT) để gửi sang Supabase làm accessToken
  Future<String?> getIdToken([bool forceRefresh = false]) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    return await user.getIdToken(forceRefresh);
  }

  /// Thực hiện đăng nhập bằng tài khoản Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // 1. Kích hoạt quy trình Google Sign-In trên thiết bị
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // Người dùng đã hủy thao tác đăng nhập
        return null;
      }

      // 2. Lấy thông tin xác thực (Access Token & ID Token) từ Google
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 3. Tạo Firebase Credential tương ứng
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Đăng nhập vào Firebase Auth
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  /// Đăng xuất khỏi hệ thống
  Future<void> signOut() async {
    await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  /// Chuyển đổi Firebase User hiện tại thành AppUserEntity
  AppUserEntity? get currentAppUser {
    final user = currentUser;
    if (user == null) return null;
    return AppUserEntity(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
      createdAt: user.metadata.creationTime ?? DateTime.now(),
    );
  }
}
