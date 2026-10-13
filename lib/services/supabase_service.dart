import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Dịch vụ kết nối cơ sở dữ liệu Supabase
/// Sử dụng Firebase làm Third-Party Auth provider qua tham số accessToken
class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  /// Khởi tạo Supabase Client với cấu hình Firebase ID Token
  static Future<void> initialize() async {
    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (supabaseUrl == null || supabaseUrl.isEmpty) {
      throw StateError(
        'SUPABASE_URL chưa được cấu hình trong tệp .env! '
        'Vui lòng sao chép .env.example sang .env và điền thông tin Supabase của bạn.',
      );
    }

    if (supabaseAnonKey == null || supabaseAnonKey.isEmpty) {
      throw StateError(
        'SUPABASE_ANON_KEY chưa được cấu hình trong tệp .env! '
        'Vui lòng điền Anon Key trong tệp .env.',
      );
    }

    // Khởi tạo Supabase SDK với callback accessToken truyền Firebase JWT
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      accessToken: () async {
        // Lấy Firebase ID Token hiện hành của user đang đăng nhập
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          return null;
        }
        // Tham số false để dùng cache token nếu còn hạn, tự refresh nếu sắp hết hạn
        return await user.getIdToken();
      },
    );
  }
}
