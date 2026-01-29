import 'package:flutter_test/flutter_test.dart';
import 'package:taskly/utils/date_parser.dart';
import 'package:taskly/l10n/app_localizations.dart';
import 'package:mockito/mockito.dart';
import 'package:intl/intl.dart';

// Manual Mock instead of generated one
class MockAppLocalizations extends Mock implements AppLocalizations {
  @override
  String get navToday => super.noSuchMethod(Invocation.getter(#navToday), returnValue: '今天');
  @override
  String get dateTomorrow => super.noSuchMethod(Invocation.getter(#dateTomorrow), returnValue: '明天');
  @override
  String get dateYesterday => super.noSuchMethod(Invocation.getter(#dateYesterday), returnValue: '昨天');
}

void main() {
  group('DateParser Tests', () {
    group('parse method', () {
      test('should parse relative date +10m (10 minutes)', () {
        final now = DateTime.now();
        final result = DateParser.parse('+10m');
        expect(result, isNotNull);
        final parsed = DateTime.parse(result!);
        final diff = parsed.difference(now);
        expect(diff.inMinutes, greaterThanOrEqualTo(9));
        expect(diff.inMinutes, lessThanOrEqualTo(11));
      });

      test('should parse relative date +2h (2 hours)', () {
        final now = DateTime.now();
        final result = DateParser.parse('+2h');
        expect(result, isNotNull);
        final parsed = DateTime.parse(result!);
        final diff = parsed.difference(now);
        expect(diff.inHours, greaterThanOrEqualTo(1));
        expect(diff.inHours, lessThanOrEqualTo(3));
      });

      test('should parse relative date +1d (1 day)', () {
        final now = DateTime.now();
        final result = DateParser.parse('+1d');
        expect(result, isNotNull);
        final parsed = DateTime.parse(result!);
        final diff = parsed.difference(now);
        expect(diff.inDays, greaterThanOrEqualTo(0));
        expect(diff.inDays, lessThanOrEqualTo(2));
      });

      test('should parse relative date +1w (1 week)', () {
        final now = DateTime.now();
        final result = DateParser.parse('+1w');
        expect(result, isNotNull);
        final parsed = DateTime.parse(result!);
        final diff = parsed.difference(now);
        expect(diff.inDays, greaterThanOrEqualTo(6));
        expect(diff.inDays, lessThanOrEqualTo(8));
      });

      test('should parse relative date +6M (6 months)', () {
        final now = DateTime.now();
        final result = DateParser.parse('+6M');
        expect(result, isNotNull);
        final parsed = DateTime.parse(result!);
        final diff = parsed.difference(now);
        expect(diff.inDays, greaterThanOrEqualTo(179));
        expect(diff.inDays, lessThanOrEqualTo(181));
      });

      test('should parse time @now', () {
        final now = DateTime.now();
        final result = DateParser.parse('@now');
        expect(result, isNotNull);
        expect(
          result,
          matches(RegExp(r'^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$')),
        );
      });

      test('should parse time with 12-hour format @10am', () {
        final result = DateParser.parse('@10am');
        expect(result, isNotNull);
        expect(result, matches(RegExp(r'^\d{4}-\d{2}-\d{2} 10:00:00$')));
      });

      test('should parse time with 12-hour format @2pm', () {
        final result = DateParser.parse('@2pm');
        expect(result, isNotNull);
        expect(result, matches(RegExp(r'^\d{4}-\d{2}-\d{2} 14:00:00$')));
      });

      test('should parse time with minutes @10:30am', () {
        final result = DateParser.parse('@10:30am');
        expect(result, isNotNull);
        expect(result, matches(RegExp(r'^\d{4}-\d{2}-\d{2} 10:30:00$')));
      });

      test('should parse time with 24-hour format @22:30', () {
        final result = DateParser.parse('@22:30');
        expect(result, isNotNull);
        expect(result, matches(RegExp(r'^\d{4}-\d{2}-\d{2} 22:30:00$')));
      });

      test('should parse time with tomorrow modifier @10am tomorrow', () {
        final now = DateTime.now();
        final result = DateParser.parse('@10am tomorrow');
        expect(result, isNotNull);
        final parsed = DateTime.parse(result!);
        final tomorrow = now.add(const Duration(days: 1));
        expect(parsed.year, equals(tomorrow.year));
        expect(parsed.month, equals(tomorrow.month));
        expect(parsed.day, equals(tomorrow.day));
      });

      test('should parse time with tmw shorthand @10am tmw', () {
        final now = DateTime.now();
        final result = DateParser.parse('@10am tmw');
        expect(result, isNotNull);
        final parsed = DateTime.parse(result!);
        final tomorrow = now.add(const Duration(days: 1));
        expect(parsed.year, equals(tomorrow.year));
        expect(parsed.month, equals(tomorrow.month));
        expect(parsed.day, equals(tomorrow.day));
      });

      test('should parse time with Monday modifier @8pm mon', () {
        final result = DateParser.parse('@8pm mon');
        expect(result, isNotNull);
        expect(result, matches(RegExp(r'^\d{4}-\d{2}-\d{2} 20:00:00$')));
      });

      test('should parse absolute date yyyy-MM-dd', () {
        final result = DateParser.parse('2024-12-31');
        expect(result, isNotNull);
        expect(result, equals('2024-12-31 00:00:00'));
      });

      test('should parse absolute date yyyy/MM/dd', () {
        final result = DateParser.parse('2024/12/31');
        expect(result, isNotNull);
        expect(result, equals('2024-12-31 00:00:00'));
      });

      test('should parse absolute date MM/dd/yyyy', () {
        final result = DateParser.parse('12/31/2024');
        expect(result, isNotNull);
        expect(result, equals('2024-12-31 00:00:00'));
      });

      test('should parse absolute date dd/MM/yyyy', () {
        final result = DateParser.parse('31/12/2024');
        expect(result, isNotNull);
        expect(result, equals('2024-12-31 00:00:00'));
      });

      test('should return null for empty string', () {
        final result = DateParser.parse('');
        expect(result, isNull);
      });

      test('should return null for invalid format', () {
        final result = DateParser.parse('invalid');
        expect(result, isNull);
      });

      test('should handle edge case @12am', () {
        final result = DateParser.parse('@12am');
        expect(result, isNotNull);
        expect(result, matches(RegExp(r'^\d{4}-\d{2}-\d{2} 00:00:00$')));
      });

      test('should handle edge case @12pm', () {
        final result = DateParser.parse('@12pm');
        expect(result, isNotNull);
        expect(result, matches(RegExp(r'^\d{4}-\d{2}-\d{2} 12:00:00$')));
      });
    });

    group('formatDateForDisplay method', () {
      test('should display today with HH:mm format', () {
        final now = DateTime.now();
        final todayString =
            '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} 10:30:00';

        final mockL10n = MockAppLocalizations();
        when(mockL10n.navToday).thenReturn('今天');

        final result = DateParser.formatDateForDisplay(todayString, mockL10n);
        expect(result, contains('今天'));
        expect(result, contains('10:30'));
      });

      test('should display tomorrow with HH:mm format', () {
        final now = DateTime.now();
        final tomorrow = now.add(const Duration(days: 1));
        final tomorrowString =
            '${tomorrow.year}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')} 14:00:00';

        final mockL10n = MockAppLocalizations();
        when(mockL10n.dateTomorrow).thenReturn('明天');

        final result = DateParser.formatDateForDisplay(tomorrowString, mockL10n);
        expect(result, contains('明天'));
        expect(result, contains('14:00'));
      });

      test('should display yesterday with HH:mm format', () {
        final now = DateTime.now();
        final yesterday = now.subtract(const Duration(days: 1));
        final yesterdayString =
            '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')} 09:00:00';

        final mockL10n = MockAppLocalizations();
        when(mockL10n.dateYesterday).thenReturn('昨天');

        final result = DateParser.formatDateForDisplay(yesterdayString, mockL10n);
        expect(result, contains('昨天'));
        expect(result, contains('09:00'));
      });

      test('should display other dates with full format', () {
        final dateString = '2024-12-25 10:30:00';

        final mockL10n = MockAppLocalizations();
        final result = DateParser.formatDateForDisplay(dateString, mockL10n);
        expect(result, equals('2024-12-25 10:30'));
      });

      test('should return empty string for null input', () {
        final mockL10n = MockAppLocalizations();
        final result = DateParser.formatDateForDisplay(null, mockL10n);
        expect(result, equals(''));
      });

      test('should return empty string for empty input', () {
        final mockL10n = MockAppLocalizations();
        final result = DateParser.formatDateForDisplay('', mockL10n);
        expect(result, equals(''));
      });

      test('should return original string for invalid date', () {
        final invalidString = 'invalid-date';
        final mockL10n = MockAppLocalizations();
        final result = DateParser.formatDateForDisplay(invalidString, mockL10n);
        expect(result, equals(invalidString));
      });
    });

    group('extractTimeCommand method', () {
      test('should extract time command with @ symbol', () {
        final (text, command) = DateParser.extractTimeCommand('买牛奶 @10am');
        expect(text, equals('买牛奶'));
        expect(command, equals('@10am'));
      });

      test('should extract time command with + symbol', () {
        final (text, command) = DateParser.extractTimeCommand('会议 +2h');
        expect(text, equals('会议'));
        expect(command, equals('+2h'));
      });

      test('should extract time command with day modifier', () {
        final (text, command) = DateParser.extractTimeCommand('去健身房 @8pm mon');
        expect(text, equals('去健身房'));
        expect(command, equals('@8pm mon'));
      });

      test('should extract time command with tmw shorthand', () {
        final (text, command) = DateParser.extractTimeCommand('会议 @10am tmw');
        expect(text, equals('会议'));
        expect(command, equals('@10am tmw'));
      });

      test('should extract time command with minutes', () {
        final (text, command) = DateParser.extractTimeCommand('写代码 +30m');
        expect(text, equals('写代码'));
        expect(command, equals('+30m'));
      });

      test('should return null command when no time command found', () {
        final (text, command) = DateParser.extractTimeCommand('写报告');
        expect(text, equals('写报告'));
        expect(command, isNull);
      });

      test('should handle empty input', () {
        final (text, command) = DateParser.extractTimeCommand('');
        expect(text, equals(''));
        expect(command, isNull);
      });

      test('should handle whitespace correctly', () {
        final (text, command) = DateParser.extractTimeCommand('  买牛奶  @10am  ');
        expect(text, equals('买牛奶'));
        expect(command, equals('@10am'));
      });

      test('should extract time command from end of text', () {
        final (text, command) = DateParser.extractTimeCommand('准备演讲材料 +1d');
        expect(text, equals('准备演讲材料'));
        expect(command, equals('+1d'));
      });

      test('should extract time command with 24-hour format', () {
        final (text, command) = DateParser.extractTimeCommand('开会 @14:30');
        expect(text, equals('开会'));
        expect(command, equals('@14:30'));
      });
    });
  });
}
