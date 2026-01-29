import 'dart:io';
import 'package:flutter/material.dart';
import 'package:taskly/l10n/app_localizations.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/path_utils.dart';

class AppMenuBar extends StatelessWidget {
  const AppMenuBar({super.key});

  // 统一的菜单项样式
  static final ButtonStyle _menuItemStyle = ButtonStyle(
    minimumSize: WidgetStateProperty.all(const Size(120, 32)),
    padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 12, vertical: 6)),
  );

  // 顶级菜单按钮样式
  static final ButtonStyle _submenuButtonStyle = ButtonStyle(
    minimumSize: WidgetStateProperty.all(const Size(0, 32)),
    padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 10, vertical: 4)),
  );

  // 下拉菜单样式
  static final MenuStyle _dropdownMenuStyle = MenuStyle(
    backgroundColor: WidgetStateProperty.all(Colors.white),
    elevation: WidgetStateProperty.all(4),
    shape: WidgetStateProperty.all(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    ),
    padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 4)),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 4),
          MenuBar(
            style: MenuStyle(
              backgroundColor: WidgetStateProperty.all(Colors.transparent),
              elevation: WidgetStateProperty.all(0),
              padding: WidgetStateProperty.all(EdgeInsets.zero),
            ),
            children: [
              _buildFileMenu(context, l10n),
              _buildSettingsMenu(context, l10n),
              _buildHelpMenu(context, l10n),
            ],
          ),
          const Spacer(),
        ],
      ),
    );
  }

  SubmenuButton _buildFileMenu(BuildContext context, AppLocalizations l10n) {
    return SubmenuButton(
      style: _submenuButtonStyle,
      menuStyle: _dropdownMenuStyle,
      menuChildren: [
        MenuItemButton(
          style: _menuItemStyle,
          onPressed: () => _showNewDatabaseDialog(context),
          child: Text(l10n.menuNewDatabase),
        ),
        MenuItemButton(
          style: _menuItemStyle,
          onPressed: () => _showOpenDatabaseDialog(context),
          child: Text(l10n.menuOpenDatabase),
        ),
        MenuItemButton(
          style: _menuItemStyle,
          onPressed: () => _showCloseDatabaseDialog(context),
          child: Text(l10n.menuCloseDatabase),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Divider(height: 1),
        ),
        MenuItemButton(
          style: _menuItemStyle,
          onPressed: () => exit(0),
          child: Text(l10n.menuExit),
        ),
      ],
      child: Text(l10n.menuFile),
    );
  }

  SubmenuButton _buildSettingsMenu(BuildContext context, AppLocalizations l10n) {
    final appProvider = Provider.of<AppProvider>(context);
    
    return SubmenuButton(
      style: _submenuButtonStyle,
      menuStyle: _dropdownMenuStyle,
      menuChildren: [
        MenuItemButton(
          style: _menuItemStyle,
          onPressed: () => _showLanguageDialog(context, appProvider),
          leadingIcon: const Icon(Icons.translate, size: 16),
          trailingIcon: Text(
            appProvider.language == 'en' ? 'English' : '中文',
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
          child: Text(l10n.menuLanguage),
        ),
      ],
      child: Text(l10n.menuSettings),
    );
  }

  SubmenuButton _buildHelpMenu(BuildContext context, AppLocalizations l10n) {
    return SubmenuButton(
      style: _submenuButtonStyle,
      menuStyle: _dropdownMenuStyle,
      menuChildren: [
        MenuItemButton(
          style: _menuItemStyle,
          onPressed: () => _showAboutDialog(context),
          child: Text(l10n.menuAbout),
        ),
      ],
      child: Text(l10n.menuHelp),
    );
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
      applicationVersion: '0.0.1',
      applicationLegalese: '© 2025 Taskly Team',
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 16.0),
          child: Text(
            '一款专注高效的个人任务管理工具\n帮助您轻松规划、组织和完成各项任务',
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
    final l10n = AppLocalizations.of(context)!;

    final result = await FilePicker.platform.pickFiles(
      dialogTitle: l10n.dialogSelectDbFile,
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
    final l10n = AppLocalizations.of(context)!;

    if (!appProvider.isDatabaseConnected) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.statusDatabaseNotConnected)));
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.dialogConfirmCloseDb),
        content: Text(l10n.dialogConfirmCloseDbContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.dialogCancel),
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
            child: Text(l10n.dialogConfirm),
          ),
        ],
      ),
    );
  }
}
