import 'package:flutter/material.dart';
import 'app_design.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF007AFF),
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Colors.black87,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppDesign.borderRadiusMedium,
        ),
        color: Colors.white,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        elevation: 24,
        shape: RoundedRectangleBorder(
          borderRadius: AppDesign.borderRadiusMedium,
        ),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF007AFF),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF007AFF),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF007AFF), width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppDesign.paddingL,
          vertical: AppDesign.paddingM,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFF007AFF);
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      iconTheme: const IconThemeData(color: Colors.black87),
      dividerTheme: DividerThemeData(color: Colors.grey[300], thickness: 1),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Colors.black87,
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: Colors.white,
        headerBackgroundColor: Colors.white,
        headerForegroundColor: Colors.black87,
        weekdayStyle: const TextStyle(color: Colors.black87, fontSize: 12),
        dayStyle: const TextStyle(color: Colors.black87),
        todayForegroundColor: WidgetStateProperty.all(const Color(0xFF007AFF)),
        todayBackgroundColor: WidgetStateProperty.all(Colors.blue[50]),
        dayForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return Colors.black87;
        }),
        dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFF007AFF);
          }
          return Colors.transparent;
        }),
        dayOverlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFF007AFF).withOpacity(0.12);
          }
          if (states.contains(WidgetState.pressed)) {
            return Colors.black.withOpacity(0.08);
          }
          if (states.contains(WidgetState.hovered)) {
            return Colors.black.withOpacity(0.04);
          }
          return null;
        }),
        rangeSelectionBackgroundColor: const Color(0xFF007AFF).withOpacity(0.12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        dividerColor: Colors.grey[300],
        todayBorder: BorderSide(color: const Color(0xFF007AFF), width: 1),
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: Colors.white,
        hourMinuteColor: Colors.blue[50],
        hourMinuteTextColor: const Color(0xFF007AFF),
        dialHandColor: const Color(0xFF007AFF),
        dialBackgroundColor: Colors.transparent,
        dialTextColor: Colors.black87,
        entryModeIconColor: const Color(0xFF007AFF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        dayPeriodColor: Colors.blue[50],
        dayPeriodTextColor: const Color(0xFF007AFF),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        titleMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
        bodyLarge: TextStyle(fontSize: 15, color: Colors.black87, height: 1.5),
        bodyMedium: TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
        bodySmall: TextStyle(fontSize: 13, color: Colors.grey),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF007AFF),
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF1C1C1E),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF2C2C2E),
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        color: Color(0xFF2C2C2E),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: Color(0xFF2C2C2E),
        elevation: 24,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF007AFF),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF0A84FF),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF3A3A3C),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF48484A)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF48484A)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF0A84FF), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFF0A84FF);
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF38383A),
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF2C2C2E),
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: const Color(0xFF2C2C2E),
        headerBackgroundColor: const Color(0xFF2C2C2E),
        headerForegroundColor: Colors.white,
        weekdayStyle: const TextStyle(color: Colors.white, fontSize: 12),
        dayStyle: const TextStyle(color: Colors.white),
        todayForegroundColor: WidgetStateProperty.all(const Color(0xFF0A84FF)),
        todayBackgroundColor: WidgetStateProperty.all(const Color(0xFF0A84FF).withOpacity(0.1)),
        dayForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return Colors.white;
        }),
        dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFF0A84FF);
          }
          return Colors.transparent;
        }),
        dayOverlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFF0A84FF).withOpacity(0.12);
          }
          if (states.contains(WidgetState.pressed)) {
            return Colors.white.withOpacity(0.08);
          }
          if (states.contains(WidgetState.hovered)) {
            return Colors.white.withOpacity(0.04);
          }
          return null;
        }),
        rangeSelectionBackgroundColor: const Color(0xFF0A84FF).withOpacity(0.12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        dividerColor: const Color(0xFF38383A),
        todayBorder: BorderSide(color: const Color(0xFF0A84FF), width: 1),
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: const Color(0xFF2C2C2E),
        hourMinuteColor: const Color(0xFF0A84FF).withOpacity(0.1),
        hourMinuteTextColor: const Color(0xFF0A84FF),
        dialHandColor: const Color(0xFF0A84FF),
        dialBackgroundColor: Colors.transparent,
        dialTextColor: Colors.white,
        entryModeIconColor: const Color(0xFF0A84FF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        dayPeriodColor: const Color(0xFF0A84FF).withOpacity(0.1),
        dayPeriodTextColor: const Color(0xFF0A84FF),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(fontSize: 15, color: Colors.white, height: 1.5),
        bodyMedium: TextStyle(fontSize: 14, color: Colors.white, height: 1.5),
        bodySmall: TextStyle(fontSize: 13, color: Color(0xFF98989D)),
      ),
    );
  }

  // ============ Semantic Color Helpers ============
  // These methods return appropriate colors based on current theme brightness

  /// Light gray background for containers (sidebar, input areas)
  static Color surfaceContainer(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF2C2C2E)
        : Colors.grey[50]!;
  }

  /// Darker container background for disabled states
  static Color surfaceContainerHighest(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF3A3A3C)
        : Colors.grey[200]!;
  }

  /// Secondary text color (hints, placeholders)
  static Color onSurfaceVariant(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF98989D)
        : Colors.grey[600]!;
  }

  /// Tertiary text color (even more subtle)
  static Color onSurfaceSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF8E8E93)
        : Colors.grey[500]!;
  }

  /// Subtle text/icon color
  static Color onSurfaceTertiary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF636366)
        : Colors.grey[400]!;
  }

  /// Divider and border color
  static Color dividerColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF38383A)
        : Colors.grey[300]!;
  }

  /// Card/tile background color
  static Color cardBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF2C2C2E)
        : Colors.white;
  }

  /// Highlight background (hover, selected states)
  static Color highlightBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF3A3A3C)
        : Colors.grey[50]!;
  }

  /// Badge/tag background color
  static Color badgeBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF48484A)
        : const Color(0xFFD1D5DB);
  }

  /// Badge/tag text color
  static Color badgeText(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : const Color(0xFF424242);
  }

  /// Chip background when editing (date/time pickers)
  static Color chipBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF0A84FF).withOpacity(0.15)
        : Colors.blue[50]!;
  }

  /// Chip border when editing
  static Color chipBorder(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF0A84FF).withOpacity(0.3)
        : Colors.blue[200]!;
  }
}
