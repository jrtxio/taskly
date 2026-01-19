import 'package:intl/intl.dart';

class DateParser {
  static String? parse(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;

    try {
      if (trimmed.startsWith('+')) {
        return _parseRelativeDate(trimmed);
      } else if (trimmed.startsWith('@')) {
        return _parseTime(trimmed);
      } else {
        return _parseAbsoluteDate(trimmed);
      }
    } catch (e) {
      return null;
    }
  }

  static String? _parseRelativeDate(String input) {
    final now = DateTime.now();
    final suffix = input.substring(1).toLowerCase();

    if (suffix == 'd') {
      return _formatDate(now.add(const Duration(days: 1)));
    } else if (suffix == 'w') {
      return _formatDate(now.add(const Duration(days: 7)));
    } else if (suffix == 'm') {
      return _formatDate(now.add(const Duration(days: 30)));
    } else if (suffix.startsWith('d') && suffix.length > 1) {
      final days = int.tryParse(suffix.substring(1));
      if (days != null) {
        return _formatDate(now.add(Duration(days: days)));
      }
    } else if (suffix.startsWith('w') && suffix.length > 1) {
      final weeks = int.tryParse(suffix.substring(1));
      if (weeks != null) {
        return _formatDate(now.add(Duration(days: weeks * 7)));
      }
    }

    return null;
  }

  static String? _parseTime(String input) {
    final now = DateTime.now();
    final timeStr = input.substring(1).toLowerCase();

    if (timeStr == 'now') {
      return _formatDateTime(now);
    }

    final timeFormat = RegExp(r'^(\d{1,2})(am|pm)?$');
    final match = timeFormat.firstMatch(timeStr);
    if (match != null) {
      final hour = int.parse(match.group(1)!);
      final period = match.group(2);
      int hour24 = hour;
      if (period == 'pm' && hour < 12) {
        hour24 = hour + 12;
      } else if (period == 'am' && hour == 12) {
        hour24 = 0;
      }
      return _formatDateTime(
        DateTime(now.year, now.month, now.day, hour24, 0, 0),
      );
    }

    return null;
  }

  static String? _parseAbsoluteDate(String input) {
    final formats = ['yyyy-MM-dd', 'yyyy/MM/dd', 'MM/dd/yyyy', 'dd/MM/yyyy'];

    for (final format in formats) {
      try {
        final date = DateFormat(format).parseStrict(input);
        return _formatDate(date);
      } catch (e) {
        continue;
      }
    }

    return null;
  }

  static String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
  }

  static String _formatDateTime(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
  }

  static String formatDateForDisplay(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';

    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final taskDate = DateTime(date.year, date.month, date.day);

      if (taskDate == today) {
        return '今天 ${DateFormat('HH:mm').format(date)}';
      } else if (taskDate == today.add(const Duration(days: 1))) {
        return '明天 ${DateFormat('HH:mm').format(date)}';
      } else if (taskDate == today.subtract(const Duration(days: 1))) {
        return '昨天 ${DateFormat('HH:mm').format(date)}';
      } else {
        return DateFormat('yyyy-MM-dd HH:mm').format(date);
      }
    } catch (e) {
      return dateStr;
    }
  }
}
