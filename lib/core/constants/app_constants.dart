/// Các hằng số cấu hình của ứng dụng
class AppConstants {
  AppConstants._();

  static const String appName = 'Quản lý Tài liệu Học tập';
  static const String appVersion = '1.0.0';
  static const String storageKeyDocuments = 'cashew_study_documents_v1';
  static const String storageKeyTheme = 'cashew_study_theme_mode';
  static const String storageKeyInitialized = 'cashew_storage_initialized';

  // Danh sách môn học mặc định phong phú cho sinh viên CNTT & các ngành kỹ thuật
  static const List<String> defaultSubjects = [
    'Tất cả',
    'Kiến trúc & Thiết kế Phần mềm',
    'Lập trình Ứng dụng Di động',
    'Cơ sở Dữ liệu Nâng cao',
    'Mạng Máy tính & Truyền thông',
    'Cấu trúc Dữ liệu & Giải thuật',
    'Trí tuệ Nhân tạo',
    'An toàn Thông tin',
    'Toán Rời rạc',
  ];
}
