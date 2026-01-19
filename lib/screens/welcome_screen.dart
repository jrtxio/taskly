import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/app_provider.dart';
import '../services/database_service.dart';
import '../utils/path_utils.dart';
import 'main_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

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

  Future<void> _loadDefaultDbPath() async {
    final defaultPath = PathUtils.getDefaultAppDirPath();
    _dbPathController.text = defaultPath;
  }

  Future<void> _browseDbFile() async {
    final result = await FilePicker.platform.getDirectoryPath(
      dialogTitle: '选择数据库文件夹',
    );

    if (result != null) {
      _dbPathController.text = result;
    }
  }

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

  Future<void> _handleConfirm() async {
    final dirPath = _dbPathController.text.trim();
    if (dirPath.isEmpty) {
      _showErrorDialog('请选择或输入数据库文件夹路径');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Convert directory path to database file path
      final dbPath = '${Directory(dirPath).path}${Platform.pathSeparator}tasks.db';
      final dir = Directory(dirPath);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      // Save database file path (not directory path)
      if (!mounted) return;
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      await appProvider.saveDbPath(dbPath);

      // Set database path for database service
      final dbService = DatabaseService();
      dbService.setDatabasePath(dbPath);

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
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

  void _handleCancel() {
    exit(0);
  }

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
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[300]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.task_alt,
                size: 64,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 24),
              Text(
                '欢迎使用 Taskly',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '请选择或创建任务数据库',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _dbPathController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        hintText: '数据库路径',
                      ),
                      readOnly: true,
                      onTap: _createDbFile,
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _browseDbFile,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(100, 48),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                    ),
                    child: const Text('浏览...'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleConfirm,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(120, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('确定'),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton(
                    onPressed: _isLoading ? null : _handleCancel,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(120, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
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
