import 'package:flutter_test/flutter_test.dart';
import 'package:cashew_study_docs/domain/services/document_validation_service.dart';

void main() {
  late DocumentValidationService validationService;

  setUp(() {
    validationService = const DocumentValidationService();
  });

  group('DocumentValidationService - Kiểm thử tầng Domain độc lập', () {
    test('validateTitle - trả về lỗi khi tiêu đề rỗng hoặc ít hơn 3 ký tự', () {
      expect(validationService.validateTitle(null), isNotNull);
      expect(validationService.validateTitle(''), isNotNull);
      expect(validationService.validateTitle('  '), isNotNull);
      expect(validationService.validateTitle('ab'), isNotNull);
      expect(validationService.validateTitle('Giáo trình Flutter'), isNull);
    });

    test('validateSubject - trả về lỗi khi môn học chưa được chọn hợp lệ', () {
      expect(validationService.validateSubject(null), isNotNull);
      expect(validationService.validateSubject(''), isNotNull);
      expect(validationService.validateSubject('Tất cả'), isNotNull);
      expect(validationService.validateSubject('Kiến trúc Phần mềm'), isNull);
    });

    test('validateUrlOrPath - trả về lỗi khi đường dẫn tệp rỗng', () {
      expect(validationService.validateUrlOrPath(null), isNotNull);
      expect(validationService.validateUrlOrPath('   '), isNotNull);
      expect(validationService.validateUrlOrPath('https://docs.edu.vn/slide.pdf'), isNull);
    });

    test('parseTags - phân tích cú pháp chuỗi thẻ thành danh sách chuẩn hóa', () {
      const rawTags = 'Flutter,  Clean Architecture, Dart, Flutter,  , SOLID ';
      final result = validationService.parseTags(rawTags);

      expect(result.length, equals(4));
      expect(result, containsAll(['Flutter', 'Clean Architecture', 'Dart', 'SOLID']));
      expect(result.contains(''), isFalse);
    });
  });
}