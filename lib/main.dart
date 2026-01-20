import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'locator/service_locator.dart';
import 'providers/app_provider.dart';
import 'providers/list_provider.dart';
import 'providers/task_provider.dart';
import 'screens/main_screen.dart';
import 'screens/welcome_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  setupLocator();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AppProvider? _appProvider;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Create and initialize AppProvider
      final appProvider = AppProvider();
      await appProvider.init();
      setState(() {
        _appProvider = appProvider;
      });
    } catch (e, stackTrace) {
      setState(() {
        _errorMessage = '初始化失败: $e\n$stackTrace';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_appProvider == null) {
      if (_errorMessage == null) {
        return const MaterialApp(
          home: Scaffold(body: Center(child: CircularProgressIndicator())),
        );
      } else {
        return MaterialApp(
          home: Scaffold(body: Center(child: Text(_errorMessage!))),
        );
      }
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _appProvider!),
        ChangeNotifierProvider(create: (_) => ListProvider()),
        ChangeNotifierProxyProvider2<AppProvider, ListProvider, TaskProvider>(
          create: (context) => TaskProvider(),
          update: (context, appProvider, listProvider, taskProvider) {
            taskProvider?.updateDatabasePath(appProvider.databasePath);
            _updateWindowTitle(appProvider.databasePath);
            return taskProvider ?? TaskProvider();
          },
        ),
      ],
      child: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _updateWindowTitle(appProvider.databasePath);
          });
          return MaterialApp(
            title: 'Taskly',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: appProvider.isDarkMode
                ? ThemeMode.dark
                : ThemeMode.light,
            home: appProvider.isFirstLaunch
                ? const WelcomeScreen()
                : const MainScreen(),
          );
        },
      ),
    );
  }

  void _updateWindowTitle(String? databasePath) {
    // Window title management to be implemented with window_manager package
    // Currently using default app title from MaterialApp
  }
}
