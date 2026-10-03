/// Dịch vụ nghiệp vụ kiểm tra tính hợp lệ của tài liệu học tập
class DocumentValidationService {
  const DocumentValidationService();

  /// Kiểm tra tiêu đề tài liệu
  String? validateTitle(String? title) {
    if (title == null || title.trim().isEmpty) {
      return 'Vui lòng nhập tiêu đề tài liệu';
    }
    if (title.trim().length < 3) {
      return 'Tiêu đề tài liệu phải có ít nhất 3 ký tự';
    }
    if (title.trim().length > 150) {
      return 'Tiêu đề không được vượt quá 150 ký tự';
    }
    return null;
  }

  /// Kiểm tra môn học
  String? validateSubject(String? subject) {
    if (subject == null || subject.trim().isEmpty || subject == 'Tất cả') {
      return 'Vui lòng chọn môn học phù hợp';
    }
    return null;
  }

  /// Kiểm tra đường dẫn hoặc liên kết tài liệu
  String? validateUrlOrPath(String? urlOrPath) {
    if (urlOrPath == null || urlOrPath.trim().isEmpty) {
      return 'Vui lòng cung cấp đường dẫn hoặc URL của tài liệu';
    }
    return null;
  }

  /// Phân tách chuỗi thẻ (tags) cách nhau bằng dấu phẩy
  List<String> parseTags(String rawTags) {
    return rawTags
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toSet()
        .toList();
  }
}
