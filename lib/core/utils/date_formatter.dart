import 'package:intl/intl.dart';

/// Tiện ích định dạng ngày giờ theo phong cách tiếng Việt
class DateFormatter {
  DateFormatter._();

  static final DateFormat _vietnameseDateFormat = DateFormat('dd/MM/yyyy', 'vi');
  static final DateFormat _vietnameseDateTimeFormat = DateFormat('dd/MM/yyyy HH:mm', 'vi');

  static String formatDate(DateTime date) {
    try {
      return _vietnameseDateFormat.format(date);
    } catch (_) {
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
  }

  static String formatDateTime(DateTime date) {
    try {
      return _vietnameseDateTimeFormat.format(date);
    } catch (_) {
      final d = formatDate(date);
      final t = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      return '$d $t';
    }
  }

  static String formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return formatDate(date);
    }
  }
}
