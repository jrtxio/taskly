import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:taskly/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    return PlatformMenu(
      label: l10n.menuFile,
      menus: [
        PlatformMenuItem(
          label: l10n.menuNewDatabase,
          onSelected: () => _showNewDatabaseDialog(context),
          shortcut: const SingleActivator(LogicalKeyboardKey.keyN, meta: true),
        ),
        PlatformMenuItem(
          label: l10n.menuOpenDatabase,
          onSelected: () => _showOpenDatabaseDialog(context),
          shortcut: const SingleActivator(LogicalKeyboardKey.keyO, meta: true),
        ),
        PlatformMenuItem(
          label: l10n.menuCloseDatabase,
          onSelected: () => _showCloseDatabaseDialog(context),
          shortcut: const SingleActivator(LogicalKeyboardKey.keyW, meta: true),
        ),
        PlatformMenuItem(
          label: l10n.menuExit,
          onSelected: () => _exitApp(context),
          shortcut: const SingleActivator(LogicalKeyboardKey.keyQ, meta: true),
        ),
      ],
    );
  }

  PlatformMenu _buildWindowsFileMenu(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PlatformMenu(
      label: l10n.menuFile,
      menus: [
        PlatformMenuItem(
          label: l10n.menuNewDatabase,
          onSelected: () => _showNewDatabaseDialog(context),
          shortcut: const SingleActivator(
            LogicalKeyboardKey.keyN,
            control: true,
          ),
        ),
        PlatformMenuItem(
          label: l10n.menuOpenDatabase,
          onSelected: () => _showOpenDatabaseDialog(context),
          shortcut: const SingleActivator(
            LogicalKeyboardKey.keyO,
            control: true,
          ),
        ),
        PlatformMenuItem(
          label: l10n.menuCloseDatabase,
          onSelected: () => _showCloseDatabaseDialog(context),
          shortcut: const SingleActivator(
            LogicalKeyboardKey.keyW,
            control: true,
          ),
        ),
        PlatformMenuItem(
          label: l10n.menuExit,
          onSelected: () => _exitApp(context),
          shortcut: const SingleActivator(LogicalKeyboardKey.f4, alt: true),
        ),
      ],
    );
  }

  PlatformMenu _buildSettingsMenu(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PlatformMenu(
      label: l10n.menuSettings,
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
    final l10n = AppLocalizations.of(context)!;
    return PlatformMenu(
      label: l10n.menuHelp,
      menus: [
        PlatformMenuItem(
          label: l10n.menuAbout,
          onSelected: () => _showAboutDialog(context),
        ),
      ],
    );
  }

  bool get _isMacOS => Platform.isMacOS;

  void _showNewDatabaseDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final TextEditingController pathController = TextEditingController(
      text: PathUtils.getDefaultDbPath(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.dialogNewDatabase),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.dialogEnterDbPath),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: pathController,
                    decoration: InputDecoration(
                      hintText: l10n.dialogDbPathHint,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    final result = await FilePicker.platform.saveFile(
                      dialogTitle: l10n.dialogSaveDbTitle,
                      fileName: 'tasks.db',
                      type: FileType.custom,
                      allowedExtensions: ['db'],
                    );

                    if (result != null) {
                      pathController.text = result;
                    }
                  },
                  child: Text(l10n.dialogBrowse),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.dialogCancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final path = pathController.text.trim();
              if (path.isEmpty) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(l10n.dialogInputDbPath)));
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
            child: Text(l10n.dialogConfirm),
          ),
        ],
      ),
    );
  }

  void _showOpenDatabaseDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final appProvider = Provider.of<AppProvider>(context, listen: false);

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
    final l10n = AppLocalizations.of(context)!;
    final appProvider = Provider.of<AppProvider>(context, listen: false);

    if (!appProvider.isDatabaseConnected) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.dialogNoDbOpened)));
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

  void _setLanguage(BuildContext context, String language) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    appProvider.setLanguage(language);
  }

  void _showAboutDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showAboutDialog(
      context: context,
      applicationName: l10n.appTitle,
      applicationVersion: '0.0.1',
      applicationLegalese: '© 2025 Taskly Team',
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Text(
            l10n.aboutContent,
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
