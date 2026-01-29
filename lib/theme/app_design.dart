/// Design constants for consistent UI appearance across the app
/// Following macOS Reminders design language with cross-platform considerations
library;

import 'package:flutter/material.dart';

class AppDesign {
  // Prevent instantiation
  AppDesign._();

  // ============ Border Radius ============
  /// Standard border radius for cards, list items, dialogs
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;

  static BorderRadius get borderRadiusSmall => BorderRadius.circular(radiusSmall);
  static BorderRadius get borderRadiusMedium => BorderRadius.circular(radiusMedium);
  static BorderRadius get borderRadiusLarge => BorderRadius.circular(radiusLarge);

  // ============ Spacing / Padding ============
  /// Horizontal padding for content areas
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 12.0;
  static const double paddingL = 16.0;
  static const double paddingXL = 20.0;
  static const double paddingXXL = 24.0;

  /// Standard content padding (used for task items, list items)
  static const EdgeInsets contentPadding = EdgeInsets.symmetric(
    horizontal: paddingL,
    vertical: paddingS,
  );

  /// Sidebar item padding
  static const EdgeInsets sidebarItemPadding = EdgeInsets.symmetric(
    horizontal: paddingM,
    vertical: paddingS + 2,
  );

  /// Card/tile margins
  static const EdgeInsets tileMargin = EdgeInsets.symmetric(
    horizontal: paddingM,
    vertical: paddingXS,
  );

  // ============ Icon Sizes ============
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 20.0;
  static const double iconSizeLarge = 24.0;

  // ============ Component Sizes ============
  /// Checkbox/circle indicator size
  static const double checkboxSize = 22.0;
  
  /// List icon circle size
  static const double listIconSize = 32.0;

  // ============ Shadows ============
  static List<BoxShadow> get subtleShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 2,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];
}
