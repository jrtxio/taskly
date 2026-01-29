import 'package:flutter/material.dart';
import 'app_design.dart';

// macOS Reminders-inspired color palette
class RemindersColors {
  // Light mode - Apple system colors
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSidebar = Color(0xFFF5F5F7); // Apple's signature gray
  static const Color lightSurface = Color(0xFFFAFAFA);
  static const Color lightDivider = Color(0xFFE5E5EA);
  static const Color lightSecondaryText = Color(0xFF8E8E93);
  static const Color lightTertiaryText = Color(0xFFC7C7CC);
  
  // Dark mode - Apple system dark colors
  static const Color darkBackground = Color(0xFF1C1C1E);
  static const Color darkSidebar = Color(0xFF2C2C2E);
  static const Color darkSurface = Color(0xFF3A3A3C);
  static const Color darkDivider = Color(0xFF38383A);
  static const Color darkSecondaryText = Color(0xFF8E8E93);
  static const Color darkTertiaryText = Color(0xFF636366);
  
  // macOS Reminders smart list colors
  static const Color today = Color(0xFF007AFF);      // Blue
  static const Color scheduled = Color(0xFFFF3B30);  // Red
  static const Color all = Color(0xFF636366);        // Gray (slightly darker)
  static const Color completed = Color(0xFFFF9500);  // Orange
  static const Color flagged = Color(0xFFFF9F0A);    // Amber
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: RemindersColors.today,
        brightness: Brightness.light,
      ).copyWith(
        surface: RemindersColors.lightBackground,
        onSurface: const Color(0xFF1D1D1F),
        onSurfaceVariant: RemindersColors.lightSecondaryText,
      ),
      scaffoldBackgroundColor: RemindersColors.lightBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: RemindersColors.lightBackground,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Color(0xFF1D1D1F),
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: Color(0xFF1D1D1F)),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppDesign.borderRadiusMedium,
        ),
        color: RemindersColors.lightBackground,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: RemindersColors.lightBackground,
        elevation: 24,
        shape: RoundedRectangleBorder(
          borderRadius: AppDesign.borderRadiusMedium,
        ),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1D1D1F),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: RemindersColors.today,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: RemindersColors.today,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: RemindersColors.lightSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: RemindersColors.lightDivider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: RemindersColors.lightDivider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: RemindersColors.today, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppDesign.paddingL,
          vertical: AppDesign.paddingM,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return RemindersColors.today;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      iconTheme: const IconThemeData(color: Color(0xFF1D1D1F)),
      dividerTheme: const DividerThemeData(color: RemindersColors.lightDivider, thickness: 0.5),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF1D1D1F),
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: RemindersColors.lightBackground,
        headerBackgroundColor: RemindersColors.lightBackground,
        headerForegroundColor: const Color(0xFF1D1D1F),
        weekdayStyle: const TextStyle(color: Color(0xFF1D1D1F), fontSize: 12),
        dayStyle: const TextStyle(color: Color(0xFF1D1D1F)),
        todayForegroundColor: WidgetStateProperty.all(RemindersColors.today),
        todayBackgroundColor: WidgetStateProperty.all(RemindersColors.today.withOpacity(0.1)),
        dayForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return const Color(0xFF1D1D1F);
        }),
        dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return RemindersColors.today;
          }
          return Colors.transparent;
        }),
        dayOverlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return RemindersColors.today.withOpacity(0.12);
          }
          if (states.contains(WidgetState.pressed)) {
            return const Color(0xFF1D1D1F).withOpacity(0.08);
          }
          if (states.contains(WidgetState.hovered)) {
            return const Color(0xFF1D1D1F).withOpacity(0.04);
          }
          return null;
        }),
        rangeSelectionBackgroundColor: RemindersColors.today.withOpacity(0.12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        dividerColor: RemindersColors.lightDivider,
        todayBorder: BorderSide(color: RemindersColors.today, width: 1),
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: RemindersColors.lightBackground,
        hourMinuteColor: RemindersColors.today.withOpacity(0.1),
        hourMinuteTextColor: RemindersColors.today,
        dialHandColor: RemindersColors.today,
        dialBackgroundColor: Colors.transparent,
        dialTextColor: const Color(0xFF1D1D1F),
        entryModeIconColor: RemindersColors.today,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        dayPeriodColor: RemindersColors.today.withOpacity(0.1),
        dayPeriodTextColor: RemindersColors.today,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1D1D1F),
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1D1D1F),
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1D1D1F),
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1D1D1F),
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1D1D1F),
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1D1D1F),
        ),
        titleMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Color(0xFF1D1D1F),
        ),
        bodyLarge: TextStyle(fontSize: 15, color: Color(0xFF1D1D1F), height: 1.5),
        bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF1D1D1F), height: 1.5),
        bodySmall: TextStyle(fontSize: 13, color: RemindersColors.lightSecondaryText),
      ),
    );
  }

  static ThemeData get darkTheme {
    // Dark mode uses slightly brighter blue for better visibility
    const Color darkBlue = Color(0xFF0A84FF);
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: darkBlue,
        brightness: Brightness.dark,
      ).copyWith(
        surface: RemindersColors.darkBackground,
        onSurface: Colors.white,
        onSurfaceVariant: RemindersColors.darkSecondaryText,
      ),
      scaffoldBackgroundColor: RemindersColors.darkBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: RemindersColors.darkSidebar,
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
        color: RemindersColors.darkSidebar,
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: RemindersColors.darkSidebar,
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
          backgroundColor: darkBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: darkBlue,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: RemindersColors.darkSurface,
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
          borderSide: BorderSide(color: darkBlue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return darkBlue;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      dividerTheme: const DividerThemeData(
        color: RemindersColors.darkDivider,
        thickness: 0.5,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: RemindersColors.darkSidebar,
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: RemindersColors.darkSidebar,
        headerBackgroundColor: RemindersColors.darkSidebar,
        headerForegroundColor: Colors.white,
        weekdayStyle: const TextStyle(color: Colors.white, fontSize: 12),
        dayStyle: const TextStyle(color: Colors.white),
        todayForegroundColor: WidgetStateProperty.all(darkBlue),
        todayBackgroundColor: WidgetStateProperty.all(darkBlue.withOpacity(0.1)),
        dayForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return Colors.white;
        }),
        dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return darkBlue;
          }
          return Colors.transparent;
        }),
        dayOverlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return darkBlue.withOpacity(0.12);
          }
          if (states.contains(WidgetState.pressed)) {
            return Colors.white.withOpacity(0.08);
          }
          if (states.contains(WidgetState.hovered)) {
            return Colors.white.withOpacity(0.04);
          }
          return null;
        }),
        rangeSelectionBackgroundColor: darkBlue.withOpacity(0.12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        dividerColor: RemindersColors.darkDivider,
        todayBorder: BorderSide(color: darkBlue, width: 1),
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: RemindersColors.darkSidebar,
        hourMinuteColor: darkBlue.withOpacity(0.1),
        hourMinuteTextColor: darkBlue,
        dialHandColor: darkBlue,
        dialBackgroundColor: Colors.transparent,
        dialTextColor: Colors.white,
        entryModeIconColor: darkBlue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        dayPeriodColor: darkBlue.withOpacity(0.1),
        dayPeriodTextColor: darkBlue,
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
        bodySmall: TextStyle(fontSize: 13, color: RemindersColors.darkSecondaryText),
      ),
    );
  }

  // ============ Semantic Color Helpers ============
  // These methods return appropriate colors based on current theme brightness

  /// Light gray background for containers (sidebar, input areas)
  static Color surfaceContainer(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? RemindersColors.darkSidebar
        : RemindersColors.lightSidebar;
  }

  /// Darker container background for disabled states
  static Color surfaceContainerHighest(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? RemindersColors.darkSurface
        : const Color(0xFFE5E5EA);
  }

  /// Secondary text color (hints, placeholders)
  static Color onSurfaceVariant(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? RemindersColors.darkSecondaryText
        : RemindersColors.lightSecondaryText;
  }

  /// Tertiary text color (even more subtle)
  static Color onSurfaceSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? RemindersColors.darkSecondaryText
        : const Color(0xFFAEAEB2);
  }

  /// Subtle text/icon color
  static Color onSurfaceTertiary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? RemindersColors.darkTertiaryText
        : RemindersColors.lightTertiaryText;
  }

  /// Divider and border color
  static Color dividerColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? RemindersColors.darkDivider
        : RemindersColors.lightDivider;
  }

  /// Card/tile background color
  static Color cardBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? RemindersColors.darkSidebar
        : RemindersColors.lightBackground;
  }

  /// Highlight background (hover, selected states)
  static Color highlightBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? RemindersColors.darkSurface
        : RemindersColors.lightSurface;
  }

  /// Badge/tag background color
  static Color badgeBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF48484A)
        : const Color(0xFFE5E5EA);
  }

  /// Badge/tag text color
  static Color badgeText(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : const Color(0xFF3C3C43);
  }

  /// Chip background when editing (date/time pickers)
  static Color chipBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF0A84FF).withOpacity(0.15)
        : RemindersColors.today.withOpacity(0.1);
  }

  /// Chip border when editing
  static Color chipBorder(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF0A84FF).withOpacity(0.3)
        : RemindersColors.today.withOpacity(0.3);
  }
}
