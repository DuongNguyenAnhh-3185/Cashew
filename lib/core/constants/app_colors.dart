import 'package:flutter/material.dart';

/// Bảng màu sắc thiết kế theo phong cách hiện đại của Cashew
/// Mang lại cảm giác thanh lịch, trực quan, hỗ trợ tương phản tốt cho sinh viên
class AppColors {
  AppColors._();

  // Primary palette (Emerald Green & Teal - đặc trưng phong cách Cashew)
  static const Color primary = Color(0xFF00796B);
  static const Color primaryLight = Color(0xFF48A999);
  static const Color primaryDark = Color(0xFF004C40);
  static const Color secondary = Color(0xFF0097A7);
  static const Color accent = Color(0xFFFFB300);

  // Background & Surfaces - Light
  static const Color backgroundLight = Color(0xFFF7F9FB);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF1E293B);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color borderLight = Color(0xFFE2E8F0);

  // Background & Surfaces - Dark
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color cardDark = Color(0xFF243046);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color borderDark = Color(0xFF334155);

  // Document Type Semantic Colors (phân biệt màu theo loại tài liệu)
  static const Color lectureColor = Color(0xFF2563EB); // Xanh dương - Bài giảng
  static const Color exerciseColor = Color(0xFF059669); // Xanh lá - Bài tập
  static const Color referenceColor = Color(
    0xFF7C3AED,
  ); // Tím - Tài liệu tham khảo
  static const Color examColor = Color(0xFFDC2626); // Đỏ - Đề thi & Đáp án
  static const Color noteColor = Color(0xFFD97706); // Cam - Ghi chú tóm tắt

  // Functional Status
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color favorite = Color(0xFFEF4444);
}
