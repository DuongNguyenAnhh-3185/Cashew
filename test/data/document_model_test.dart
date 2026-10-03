import 'package:flutter_test/flutter_test.dart';
import 'package:cashew_study_docs/data/models/document_model.dart';
import 'package:cashew_study_docs/domain/entities/document_type.dart';

void main() {
  group('DocumentModel - Kiểm thử tầng Data (Serialization / Deserialization)', () {
    final testDate = DateTime.parse('2026-10-01T10:00:00.000Z');

    final testJson = {
      'id': 'doc-123',
      'title': 'Slide Lập trình Flutter Chuyên Sâu',
      'description': 'Tài liệu hướng dẫn Clean Architecture',
      'subject': 'Lập trình Di động',
      'type': 'lecture',
      'fileFormat': 'PPTX',
      'urlOrPath': 'https://storage.edu.vn/flutter.pptx',
      'fileSizeBytes': 10485760,
      'createdAt': testDate.toIso8601String(),
      'updatedAt': testDate.toIso8601String(),
      'isFavorite': true,
      'tags': ['Flutter', 'Cashew'],
    };

    test('fromJson - chuyển đổi chính xác từ Map JSON sang DocumentModel', () {
      final model = DocumentModel.fromJson(testJson);

      expect(model.id, equals('doc-123'));
      expect(model.title, equals('Slide Lập trình Flutter Chuyên Sâu'));
      expect(model.type, equals(DocumentType.lecture));
      expect(model.fileSizeBytes, equals(10485760));
      expect(model.isFavorite, isTrue);
      expect(model.tags, equals(['Flutter', 'Cashew']));
    });

    test('toJson - chuyển đổi chính xác từ DocumentModel sang Map JSON để lưu trữ', () {
      final model = DocumentModel(
        id: 'doc-123',
        title: 'Slide Lập trình Flutter Chuyên Sâu',
        description: 'Tài liệu hướng dẫn Clean Architecture',
        subject: 'Lập trình Di động',
        type: DocumentType.lecture,
        fileFormat: 'PPTX',
        urlOrPath: 'https://storage.edu.vn/flutter.pptx',
        fileSizeBytes: 10485760,
        createdAt: testDate,
        updatedAt: testDate,
        isFavorite: true,
        tags: const ['Flutter', 'Cashew'],
      );

      final json = model.toJson();

      expect(json['id'], equals('doc-123'));
      expect(json['type'], equals('lecture'));
      expect(json['fileFormat'], equals('PPTX'));
      expect(json['isFavorite'], isTrue);
      expect(json['tags'], equals(['Flutter', 'Cashew']));
    });
  });
}