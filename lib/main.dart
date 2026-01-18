import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'locator/service_locator.dart';
import 'providers/app_provider.dart';
import 'providers/list_provider.dart';
import 'providers/task_provider.dart';
import 'screens/welcome_screen.dart';
import 'screens/main_screen.dart';

void main() {
  // Initialize sqflite for Windows
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  // Setup dependency injection
  setupLocator();

  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool _isInitialized = false;
  AppProvider? _appProvider;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  // Initialize app
  Future<void> _initializeApp() async {
    final appProvider = AppProvider();
    await appProvider.init();

    setState(() {
      _appProvider = appProvider;
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _appProvider == null) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _appProvider!),
        ChangeNotifierProvider(create: (_) => ListProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
      ],
      child: MaterialApp(
        title: 'Taskly',
        theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
        initialRoute: '/',
        routes: {
          '/': (context) {
            final appProvider = Provider.of<AppProvider>(context);
            if (appProvider.dbPath != null) {
              return const MainScreen();
            } else {
              return WelcomeScreen(appProvider: appProvider);
            }
          },
          '/main': (context) => const MainScreen(),
        },
      ),
    );
  }
}
