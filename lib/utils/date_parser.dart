import 'package:intl/intl.dart';
import 'package:taskly/l10n/app_localizations.dart';

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
  /// - +1M: next month (30 days)
  /// - +10m: 10 minutes from now
  /// - +2h: 2 hours from now
  static String? _parseRelativeDate(String input) {
    final now = DateTime.now();
    final suffix = input.substring(1);

    final match = RegExp(r'^(\d+)([mhdwM])$').firstMatch(suffix);
    if (match != null) {
      final amount = int.parse(match.group(1)!);
      final unit = match.group(2)!;

      switch (unit) {
        case 'm':
          return _formatDateTime(now.add(Duration(minutes: amount)));
        case 'h':
          return _formatDateTime(now.add(Duration(hours: amount)));
        case 'd':
          return _formatDateTime(now.add(Duration(days: amount)));
        case 'w':
          return _formatDateTime(now.add(Duration(days: amount * 7)));
        case 'M':
          return _formatDateTime(now.add(Duration(days: amount * 30)));
      }
    }

    final lowerSuffix = suffix.toLowerCase();
    if (lowerSuffix == 'd') {
      return _formatDate(now.add(const Duration(days: 1)));
    } else if (lowerSuffix == 'w') {
      return _formatDate(now.add(const Duration(days: 7)));
    } else if (lowerSuffix == 'M') {
      return _formatDate(now.add(const Duration(days: 30)));
    }

    return null;
  }

  /// Parse time-based expressions like:
  /// - @now: current time
  /// - @10am: 10 AM today
  /// - @2pm: 2 PM today
  /// - @10:30am: 10:30 AM today
  /// - @22:30: 22:30 (24-hour format)
  /// - @10am tomorrow: 10 AM tomorrow
  /// - @10am tmw: 10 AM tomorrow (shorthand)
  /// - @8pm mon: 8 PM next Monday
  ///
  /// Converts 12-hour format to 24-hour format.
  /// If time has passed today, automatically moves to next day/week.
  static String? _parseTime(String input) {
    final now = DateTime.now();
    final timeStr = input.substring(1).toLowerCase();

    if (timeStr == 'now') {
      return _formatDateTime(now);
    }

    final parts = timeStr.split(RegExp(r'\s+'));
    if (parts.isEmpty) return null;

    final timePart = parts[0];
    final dayModifier = parts.length > 1 ? parts.sublist(1).join(' ') : null;

    int hour = 0;
    int minute = 0;

    final timeMatch = RegExp(
      r'^(\d{1,2})(?::(\d{2}))?(am|pm)?$',
    ).firstMatch(timePart);
    if (timeMatch == null) return null;

    hour = int.parse(timeMatch.group(1)!);
    final minuteStr = timeMatch.group(2);
    final period = timeMatch.group(3);

    if (minuteStr != null) {
      minute = int.parse(minuteStr);
    }

    int hour24 = hour;
    if (period == 'pm' && hour < 12) {
      hour24 = hour + 12;
    } else if (period == 'am' && hour == 12) {
      hour24 = 0;
    }

    DateTime targetDate = DateTime(
      now.year,
      now.month,
      now.day,
      hour24,
      minute,
      0,
    );

    if (dayModifier != null) {
      targetDate = _applyDayModifier(targetDate, dayModifier);
    } else if (timeStr != 'now' && targetDate.isBefore(now)) {
      targetDate = targetDate.add(const Duration(days: 1));
    }

    return _formatDateTime(targetDate);
  }

  /// Apply day modifier to a date.
  /// Supports: tomorrow, tmw, mon, tue, wed, thu, fri, sat, sun
  static DateTime _applyDayModifier(DateTime date, String modifier) {
    final lowerModifier = modifier.toLowerCase().trim();

    if (lowerModifier == 'tomorrow' || lowerModifier == 'tmw') {
      return date.add(const Duration(days: 1));
    }

    final daysMap = {
      'mon': 1,
      'tue': 2,
      'wed': 3,
      'thu': 4,
      'fri': 5,
      'sat': 6,
      'sun': 7,
    };

    final targetDay = daysMap[lowerModifier];
    if (targetDay != null) {
      final currentDay = date.weekday;
      int daysToAdd = targetDay - currentDay;
      if (daysToAdd <= 0) {
        daysToAdd += 7;
      }
      return date.add(Duration(days: daysToAdd));
    }

    return date;
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
  /// - 'Today HH:mm' for today
  /// - 'Tomorrow HH:mm' for tomorrow
  /// - 'Yesterday HH:mm' for yesterday
  /// - 'yyyy-MM-dd HH:mm' for other dates
  ///
  /// Returns original string if parsing fails.
  static String formatDateForDisplay(String? dateStr, AppLocalizations l10n) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final taskDate = DateTime(date.year, date.month, date.day);

      if (taskDate == today) {
        return '${l10n.navToday} ${DateFormat('HH:mm').format(date)}';
      } else if (taskDate == today.add(const Duration(days: 1))) {
        return '${l10n.dateTomorrow} ${DateFormat('HH:mm').format(date)}';
      } else if (taskDate == today.subtract(const Duration(days: 1))) {
        return '${l10n.dateYesterday} ${DateFormat('HH:mm').format(date)}';
      } else {
        return DateFormat('yyyy-MM-dd HH:mm').format(date);
      }
    } catch (e) {
      return dateStr;
    }
  }

  /// Format date part only for user-friendly display.
  ///
  /// Returns:
  /// - 'Today' for today
  /// - 'Tomorrow' for tomorrow
  /// - 'Yesterday' for yesterday
  /// - 'yyyy-MM-dd' for other dates
  ///
  /// Returns original string if parsing fails.
  static String formatDateOnlyForDisplay(String? dateStr, AppLocalizations l10n) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final taskDate = DateTime(date.year, date.month, date.day);

      if (taskDate == today) {
        return l10n.navToday;
      } else if (taskDate == today.add(const Duration(days: 1))) {
        return l10n.dateTomorrow;
      } else if (taskDate == today.subtract(const Duration(days: 1))) {
        return l10n.dateYesterday;
      } else {
        return DateFormat('yyyy-MM-dd').format(date);
      }
    } catch (e) {
      return dateStr;
    }
  }

  /// Format time part only for display.
  ///
  /// Input format: 'HH:mm' or 'yyyy-MM-dd HH:mm:ss'
  /// Returns: 'HH:mm' format
  ///
  /// Returns empty string if parsing fails.
  static String formatTimeForDisplay(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return '';
    try {
      // If it's a full datetime string, extract time
      if (timeStr.contains('-')) {
        final date = DateTime.parse(timeStr);
        return DateFormat('HH:mm').format(date);
      }
      // If it's already a time string, validate and return
      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        final hour = int.tryParse(parts[0]);
        final minute = int.tryParse(parts[1]);
        if (hour == null || minute == null) return timeStr;
        if (hour >= 0 && hour < 24 && minute >= 0 && minute < 60) {
          return timeStr;
        }
      }
      return timeStr;
    } catch (e) {
      return '';
    }
  }

  /// Combine date and time into a full datetime string.
  ///
  /// Takes separate date (yyyy-MM-dd) and time (HH:mm) strings
  /// and combines them into 'yyyy-MM-dd HH:mm:ss' format.
  static String combineDateTime(String dateStr, String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) {
      return '$dateStr 00:00:00';
    }
    try {
      final date = DateFormat('yyyy-MM-dd').parse(dateStr);
      final parts = timeStr.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final combined = DateTime(date.year, date.month, date.day, hour, minute);
      return DateFormat('yyyy-MM-dd HH:mm:ss').format(combined);
    } catch (e) {
      return '$dateStr 00:00:00';
    }
  }

  /// Extract time command from task text.
  ///
  /// Returns a tuple of (taskText, timeCommand) where:
  /// - taskText: task text without time command
  /// - timeCommand: extracted time command (e.g., '+1d', '@10am', etc.)
  ///
  /// Examples:
  /// - "Buy milk @10am" → ("Buy milk", "@10am")
  /// - "Meeting +2h" → ("Meeting", "+2h")
  /// - "Go to gym @8pm mon" → ("Go to gym", "@8pm mon")
  /// - "Write report" → ("Write report", null)
  ///
  /// Time commands can be:
  /// - Relative: +10m, +2h, +1d, +1w, +6M
  /// - Exact: @now, @10am, @10:30pm, @22:30
  /// - With day modifier: @10am tomorrow, @8pm mon
  static (String, String?) extractTimeCommand(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return ('', null);

    final patterns = [
      r'(?:^|\s)([+]\d+[mhdwM])(?:\s|$)',
      r'(?:^|\s)([@](?:now|\d{1,2}(?::\d{2})?(?:am|pm)?)(?:\s+(?:tomorrow|tmw|mon|tue|wed|thu|fri|sat|sun))?)\s*$',
    ];

    for (final pattern in patterns) {
      final timePattern = RegExp(pattern, caseSensitive: false);
      final match = timePattern.firstMatch(trimmed);
      if (match != null) {
        final timeCommand = match.group(1)!.trim();
        final taskText = trimmed.substring(0, match.start).trim();
        return (taskText, timeCommand);
      }
    }

    return (trimmed, null);
  }
}
