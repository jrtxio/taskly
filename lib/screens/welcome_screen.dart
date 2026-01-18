import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/app_provider.dart';
import '../services/database_service.dart';

class WelcomeScreen extends StatefulWidget {
  final AppProvider appProvider;

  const WelcomeScreen({super.key, required this.appProvider});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final TextEditingController _dbPathController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDefaultDbPath();
  }

  // Load default database path
  Future<void> _loadDefaultDbPath() async {
    final dbService = DatabaseService();
    final defaultPath = await dbService.getDatabasePath();
    _dbPathController.text = defaultPath;
  }

  // Browse for database file
  Future<void> _browseDbFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['db'],
      dialogTitle: '选择或创建任务数据库',
      allowMultiple: false,
      allowCompression: false,
    );

    if (result != null && result.files.isNotEmpty) {
      _dbPathController.text = result.files.single.path!;
    }
  }

  // Create database file
  Future<void> _createDbFile() async {
    final result = await FilePicker.platform.saveFile(
      dialogTitle: '创建新任务数据库',
      fileName: 'tasks.db',
      type: FileType.custom,
      allowedExtensions: ['db'],
    );

    if (result != null) {
      _dbPathController.text = result;
    }
  }

  // Handle confirm button press
  Future<void> _handleConfirm() async {
    final path = _dbPathController.text.trim();
    if (path.isEmpty) {
      _showErrorDialog('请选择或输入数据库路径');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Ensure the directory exists
      final file = File(path);
      final dir = file.parent;
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      // Save database path to config
      await widget.appProvider.saveDbPath(path);

      // Navigate to main screen
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/main');
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('创建或打开数据库失败：$e');
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Handle cancel button press
  void _handleCancel() {
    // Exit the app
    exit(0);
  }

  // Show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('错误'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          width: 600,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                '欢迎来到 Taskly',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Prompt message
              Text(
                '请选择或创建任务数据库',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // File path input area
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _dbPathController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                      onTap: _createDbFile,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _browseDbFile,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(80, 40),
                    ),
                    child: const Text('浏览...'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleConfirm,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(100, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('确定'),
                  ),
                  const SizedBox(width: 24),
                  OutlinedButton(
                    onPressed: _isLoading ? null : _handleCancel,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(100, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: const Text('取消'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
