import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskly/l10n/app_localizations.dart';

/// Sets up a larger screen size before running widget tests to prevent
/// RenderFlex overflow issues in dialogs
void setupTestScreenSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(1280, 1024);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

/// Wraps a widget with MaterialApp and localization support for testing
Widget wrapWithLocalization(Widget child, {String locale = 'zh'}) {
  return MaterialApp(
    locale: Locale(locale),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [
      Locale('en'),
      Locale('zh'),
    ],
    home: child,
  );
}

/// Wraps a widget with MaterialApp, Scaffold and localization support
Widget wrapWithScaffold(Widget child, {String locale = 'zh'}) {
  return MaterialApp(
    locale: Locale(locale),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [
      Locale('en'),
      Locale('zh'),
    ],
    home: Scaffold(body: child),
  );
}
