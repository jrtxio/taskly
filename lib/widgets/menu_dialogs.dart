import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/path_utils.dart';

class AppMenuBar extends StatelessWidget {
  const AppMenuBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          _buildMenuButton(context, '文件', _buildFileMenu(context)),
          _buildMenuButton(context, '设置', _buildSettingsMenu(context)),
          _buildMenuButton(context, '帮助', _buildHelpMenu(context)),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context,
    String label,
    List<PopupMenuEntry<dynamic>> menuItems,
  ) {
    return PopupMenuButton<dynamic>(
      tooltip: label,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Text(label),
      ),
      itemBuilder: (context) => menuItems,
    );
  }

  List<PopupMenuEntry<dynamic>> _buildFileMenu(BuildContext context) {
    return [
      PopupMenuItem(
        value: 'new_database',
        onTap: () {
          Future.delayed(
            const Duration(milliseconds: 100),
            () => _showNewDatabaseDialog(context),
          );
        },
        child: const Text('新建数据库'),
      ),
      PopupMenuItem(
        value: 'open_database',
        onTap: () {
          Future.delayed(
            const Duration(milliseconds: 100),
            () => _showOpenDatabaseDialog(context),
          );
        },
        child: const Text('打开数据库'),
      ),
      PopupMenuItem(
        value: 'close_database',
        onTap: () {
          Future.delayed(
            const Duration(milliseconds: 100),
            () => _showCloseDatabaseDialog(context),
          );
        },
        child: const Text('关闭数据库'),
      ),
      const PopupMenuDivider(),
      const PopupMenuItem(value: 'close', child: Text('退出')),
    ];
  }

  List<PopupMenuEntry<dynamic>> _buildSettingsMenu(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);

    return [
      PopupMenuItem(
        value: 'language',
        onTap: () {
          Future.delayed(
            const Duration(milliseconds: 100),
            () => _showLanguageDialog(context, appProvider),
          );
        },
        child: Row(
          children: [
            const Icon(Icons.translate, size: 18),
            const SizedBox(width: 8),
            const Text('语言'),
            const Spacer(),
            Text(
              appProvider.language == 'en' ? 'English' : '简体中文',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    ];
  }

  List<PopupMenuEntry<dynamic>> _buildHelpMenu(BuildContext context) {
    return [
      PopupMenuItem(
        value: 'about',
        onTap: () {
          Future.delayed(
            const Duration(milliseconds: 100),
            () => _showAboutDialog(context),
          );
        },
        child: const Text('关于 Taskly'),
      ),
    ];
  }

  void _showLanguageDialog(BuildContext context, AppProvider appProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择语言'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: appProvider.language,
              onChanged: (value) {
                appProvider.setLanguage(value!);
                Navigator.of(context).pop();
              },
            ),
            RadioListTile<String>(
              title: const Text('简体中文'),
              value: 'zh',
              groupValue: appProvider.language,
              onChanged: (value) {
                appProvider.setLanguage(value!);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
        ],
      ),
    );
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
                }
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
