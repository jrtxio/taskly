import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/path_utils.dart';

class NativeMenuBar extends StatelessWidget {
  const NativeMenuBar({super.key});

  @override
  Widget build(BuildContext context) {
    return PlatformMenuBar(
      menus: [
        _isMacOS
            ? _buildMacOSFileMenu(context)
            : _buildWindowsFileMenu(context),
        _buildSettingsMenu(context),
        _buildHelpMenu(context),
      ],
    );
  }

  PlatformMenu _buildMacOSFileMenu(BuildContext context) {
    return PlatformMenu(
      label: '文件',
      menus: [
        PlatformMenuItem(
          label: '新建数据库',
          onSelected: () => _showNewDatabaseDialog(context),
          shortcut: const SingleActivator(LogicalKeyboardKey.keyN, meta: true),
        ),
        PlatformMenuItem(
          label: '打开数据库',
          onSelected: () => _showOpenDatabaseDialog(context),
          shortcut: const SingleActivator(LogicalKeyboardKey.keyO, meta: true),
        ),
        PlatformMenuItem(
          label: '关闭数据库',
          onSelected: () => _showCloseDatabaseDialog(context),
          shortcut: const SingleActivator(LogicalKeyboardKey.keyW, meta: true),
        ),
        PlatformMenuItem(
          label: '退出',
          onSelected: () => _exitApp(context),
          shortcut: const SingleActivator(LogicalKeyboardKey.keyQ, meta: true),
        ),
      ],
    );
  }

  PlatformMenu _buildWindowsFileMenu(BuildContext context) {
    return PlatformMenu(
      label: '文件',
      menus: [
        PlatformMenuItem(
          label: '新建数据库',
          onSelected: () => _showNewDatabaseDialog(context),
          shortcut: const SingleActivator(
            LogicalKeyboardKey.keyN,
            control: true,
          ),
        ),
        PlatformMenuItem(
          label: '打开数据库',
          onSelected: () => _showOpenDatabaseDialog(context),
          shortcut: const SingleActivator(
            LogicalKeyboardKey.keyO,
            control: true,
          ),
        ),
        PlatformMenuItem(
          label: '关闭数据库',
          onSelected: () => _showCloseDatabaseDialog(context),
          shortcut: const SingleActivator(
            LogicalKeyboardKey.keyW,
            control: true,
          ),
        ),
        PlatformMenuItem(
          label: '退出',
          onSelected: () => _exitApp(context),
          shortcut: const SingleActivator(LogicalKeyboardKey.f4, alt: true),
        ),
      ],
    );
  }

  PlatformMenu _buildSettingsMenu(BuildContext context) {
    return PlatformMenu(
      label: '设置',
      menus: [
        PlatformMenuItem(
          label: 'English',
          onSelected: () => _setLanguage(context, 'en'),
        ),
        PlatformMenuItem(
          label: '简体中文',
          onSelected: () => _setLanguage(context, 'zh'),
        ),
      ],
    );
  }

  PlatformMenu _buildHelpMenu(BuildContext context) {
    return PlatformMenu(
      label: '帮助',
      menus: [
        PlatformMenuItem(
          label: '关于 Taskly',
          onSelected: () => _showAboutDialog(context),
        ),
      ],
    );
  }

  bool get _isMacOS => Platform.isMacOS;

  void _showNewDatabaseDialog(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final TextEditingController pathController = TextEditingController(
      text: PathUtils.getDefaultDbPath(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新建数据库'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('请输入新数据库文件的路径和名称'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: pathController,
                    decoration: const InputDecoration(
                      hintText: '数据库文件路径',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    final result = await FilePicker.platform.saveFile(
                      dialogTitle: '保存数据库文件',
                      fileName: 'tasks.db',
                      type: FileType.custom,
                      allowedExtensions: ['db'],
                    );

                    if (result != null) {
                      pathController.text = result;
                    }
                  },
                  child: const Text('浏览...'),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              final path = pathController.text.trim();
              if (path.isEmpty) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('请输入数据库文件路径')));
                return;
              }

              await appProvider.openNewDatabase(path);

              if (context.mounted) {
                Navigator.of(context).pop();
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
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showOpenDatabaseDialog(BuildContext context) async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);

    final result = await FilePicker.platform.pickFiles(
      dialogTitle: '选择数据库文件',
      type: FileType.custom,
      allowedExtensions: ['db'],
    );

    if (result != null && result.files.single.path != null) {
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

  void _showCloseDatabaseDialog(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);

    if (!appProvider.isDatabaseConnected) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('当前没有打开的数据库')));
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认关闭数据库'),
        content: const Text('确定要关闭当前数据库吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              await appProvider.closeDatabase();

              if (context.mounted) {
                Navigator.of(context).pop();
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
                      content: Text('数据库已关闭'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _setLanguage(BuildContext context, String language) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    appProvider.setLanguage(language);
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Taskly',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2025 Taskly Team',
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 16.0),
          child: Text(
            '一个简单优雅的任务管理应用，\n灵感来源于 macOS Reminders。',
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  void _exitApp(BuildContext context) {
    Navigator.of(context).pop();
  }
}
