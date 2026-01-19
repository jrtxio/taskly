import 'package:flutter_test/flutter_test.dart';
import 'package:taskly/utils/date_parser.dart';

void main() {
  group('DateParser Tests', () {
    group('parse method', () {
      test('should parse relative date +d', () {
        final result = DateParser.parse('+d');
        expect(result, isNotNull);
        expect(result, matches(RegExp(r'^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$')));
      });

      test('should parse relative date +w', () {
        final result = DateParser.parse('+w');
        expect(result, isNotNull);
        expect(result, matches(RegExp(r'^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$')));
      });

      test('should parse relative date +m', () {
        final result = DateParser.parse('+m');
        expect(result, isNotNull);
        expect(result, matches(RegExp(r'^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$')));
      });

      test('should return null for unsupported relative date formats', () {
        expect(DateParser.parse('+3d'), isNull);
        expect(DateParser.parse('+2w'), isNull);
        expect(DateParser.parse('+5m'), isNull);
      });

      test('should parse time @now', () {
        final result = DateParser.parse('@now');
        expect(result, isNotNull);
        expect(result, matches(RegExp(r'^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$')));
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
        final todayString = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} 10:30:00';
        
        final result = DateParser.formatDateForDisplay(todayString);
        expect(result, contains('今天'));
        expect(result, contains('10:30'));
      });

      test('should display tomorrow with HH:mm format', () {
        final now = DateTime.now();
        final tomorrow = now.add(const Duration(days: 1));
        final tomorrowString = '${tomorrow.year}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')} 14:00:00';
        
        final result = DateParser.formatDateForDisplay(tomorrowString);
        expect(result, contains('明天'));
        expect(result, contains('14:00'));
      });

      test('should display yesterday with HH:mm format', () {
        final now = DateTime.now();
        final yesterday = now.subtract(const Duration(days: 1));
        final yesterdayString = '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')} 09:00:00';
        
        final result = DateParser.formatDateForDisplay(yesterdayString);
        expect(result, contains('昨天'));
        expect(result, contains('09:00'));
      });

      test('should display other dates with full format', () {
        final dateString = '2024-12-25 10:30:00';
        
        final result = DateParser.formatDateForDisplay(dateString);
        expect(result, equals('2024-12-25 10:30'));
      });

      test('should return empty string for null input', () {
        final result = DateParser.formatDateForDisplay(null);
        expect(result, equals(''));
      });

      test('should return empty string for empty input', () {
        final result = DateParser.formatDateForDisplay('');
        expect(result, equals(''));
      });

      test('should return original string for invalid date', () {
        final invalidString = 'invalid-date';
        final result = DateParser.formatDateForDisplay(invalidString);
        expect(result, equals(invalidString));
      });
    });
  });
}
