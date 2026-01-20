import 'package:intl/intl.dart';

/// DateParser provides intelligent date parsing with support for:
/// - Relative dates: +1d (tomorrow), +1w (next week), +1m (next month)
/// - Time-based: @now (now), @10am (10 AM today), @2pm (2 PM today)
/// - Absolute dates: 2024-12-31, 2024/12/31, 12/31/2024, 31/12/2024
///
/// Returns formatted date string in 'yyyy-MM-dd HH:mm:ss' format or null if parsing fails.
class DateParser {
  /// Parse date string with intelligent format detection.
  ///
  /// Supports:
  /// - Relative dates: +1d, +2w, +3m
  /// - Time-based: @now, @10am, @2pm
  /// - Absolute dates: 2024-12-31, 2024/12/31
  ///
  /// Returns null if input is empty or parsing fails.
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

  /// Parse relative date expressions like:
  /// - +1d: tomorrow
  /// - +7d: 7 days from now
  /// - +1w: next week
  /// - +2w: 2 weeks from now
  /// - +1m: next month (30 days)
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

  /// Parse time-based expressions like:
  /// - @now: current time
  /// - @10am: 10 AM today
  /// - @2pm: 2 PM today
  /// - @11pm: 11 PM today
  ///
  /// Converts 12-hour format to 24-hour format.
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

  /// Parse absolute date strings in various formats:
  /// - yyyy-MM-dd: 2024-12-31
  /// - yyyy/MM/dd: 2024/12/31
  /// - MM/dd/yyyy: 12/31/2024
  /// - dd/MM/yyyy: 31/12/2024
  ///
  /// Tries each format in order until one succeeds.
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

  /// Format DateTime to 'yyyy-MM-dd HH:mm:ss' string.
  static String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
  }

  /// Format DateTime to 'yyyy-MM-dd HH:mm:ss' string.
  static String _formatDateTime(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
  }

  /// Format date string for user-friendly display.
  ///
  /// Returns:
  /// - '今天 HH:mm' for today
  /// - '明天 HH:mm' for tomorrow
  /// - '昨天 HH:mm' for yesterday
  /// - 'yyyy-MM-dd HH:mm' for other dates
  ///
  /// Returns original string if parsing fails.
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
