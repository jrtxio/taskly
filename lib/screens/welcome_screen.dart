import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/app_provider.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(48.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  size: 120,
                  color: Colors.blue,
                ),
                const SizedBox(height: 32),
                Text(
                  '欢迎使用 Taskly',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  '一个简单优雅的任务管理应用\n灵感来源于 macOS Reminders',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                const Divider(),
                const SizedBox(height: 32),
                Text(
                  '开始使用',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: appProvider.isLoading
                      ? null
                      : () => _createNewDatabase(context, appProvider),
                  icon: const Icon(Icons.add),
                  label: const Text('创建新数据库'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: appProvider.isLoading
                      ? null
                      : () => _openExistingDatabase(context, appProvider),
                  icon: const Icon(Icons.folder_open),
                  label: const Text('打开已有数据库'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  '选择数据库后，您的任务数据将保存在指定位置，方便跨设备同步',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                      ),
                  textAlign: TextAlign.center,
                ),
                if (appProvider.isLoading) ...[
                  const SizedBox(height: 24),
                  const Center(child: CircularProgressIndicator()),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _createNewDatabase(
    BuildContext context,
    AppProvider appProvider,
  ) async {
    final result = await FilePicker.platform.saveFile(
      dialogTitle: '创建新数据库文件',
      fileName: 'tasks.db',
      type: FileType.custom,
      allowedExtensions: ['db'],
    );

    if (result != null && context.mounted) {
      await appProvider.openNewDatabase(result);

      if (context.mounted) {
        if (appProvider.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(appProvider.error!.message),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('数据库创建成功'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    }
  }

  Future<void> _openExistingDatabase(
    BuildContext context,
    AppProvider appProvider,
  ) async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: '选择数据库文件',
      type: FileType.custom,
      allowedExtensions: ['db'],
    );

    if (result != null && result.files.single.path != null && context.mounted) {
      final path = result.files.single.path!;
      await appProvider.openExistingDatabase(path);

      if (context.mounted) {
        if (appProvider.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(appProvider.error!.message),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('数据库打开成功'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    }
  }
}
