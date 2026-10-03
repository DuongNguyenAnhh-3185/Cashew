import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Phân loại tài liệu học tập
enum DocumentType {
  lecture,    // Bài giảng / Slide
  exercise,   // Bài tập / Đồ án
  reference,  // Tài liệu tham khảo / Sách giáo trình
  exam,       // Đề thi & Đáp án
  note;       // Ghi chú & Tóm tắt kiến thức

  String get displayName {
    switch (this) {
      case DocumentType.lecture:
        return 'Bài giảng';
      case DocumentType.exercise:
        return 'Bài tập';
      case DocumentType.reference:
        return 'Tham khảo';
      case DocumentType.exam:
        return 'Đề thi';
      case DocumentType.note:
        return 'Ghi chú';
    }
  }

  IconData get icon {
    switch (this) {
      case DocumentType.lecture:
        return Icons.menu_book_rounded;
      case DocumentType.exercise:
        return Icons.assignment_rounded;
      case DocumentType.reference:
        return Icons.auto_stories_rounded;
      case DocumentType.exam:
        return Icons.quiz_rounded;
      case DocumentType.note:
        return Icons.edit_note_rounded;
    }
  }

  Color get color {
    switch (this) {
      case DocumentType.lecture:
        return AppColors.lectureColor;
      case DocumentType.exercise:
        return AppColors.exerciseColor;
      case DocumentType.reference:
        return AppColors.referenceColor;
      case DocumentType.exam:
        return AppColors.examColor;
      case DocumentType.note:
        return AppColors.noteColor;
    }
  }
}
