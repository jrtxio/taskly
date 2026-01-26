import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Taskly'**
  String get appTitle;

  /// No description provided for @menuFile.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get menuFile;

  /// No description provided for @menuSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get menuSettings;

  /// No description provided for @menuHelp.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get menuHelp;

  /// No description provided for @menuNewDatabase.
  ///
  /// In en, this message translates to:
  /// **'New Database'**
  String get menuNewDatabase;

  /// No description provided for @menuOpenDatabase.
  ///
  /// In en, this message translates to:
  /// **'Open Database'**
  String get menuOpenDatabase;

  /// No description provided for @menuCloseDatabase.
  ///
  /// In en, this message translates to:
  /// **'Close Database'**
  String get menuCloseDatabase;

  /// No description provided for @menuExit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get menuExit;

  /// No description provided for @menuLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get menuLanguage;

  /// No description provided for @menuAbout.
  ///
  /// In en, this message translates to:
  /// **'About Taskly'**
  String get menuAbout;

  /// No description provided for @dialogSelectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get dialogSelectLanguage;

  /// No description provided for @dialogCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get dialogCancel;

  /// No description provided for @dialogConfirm.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get dialogConfirm;

  /// No description provided for @dialogNewDatabase.
  ///
  /// In en, this message translates to:
  /// **'New Database'**
  String get dialogNewDatabase;

  /// No description provided for @dialogEnterDbPath.
  ///
  /// In en, this message translates to:
  /// **'Please enter database file path and name'**
  String get dialogEnterDbPath;

  /// No description provided for @dialogDbPathHint.
  ///
  /// In en, this message translates to:
  /// **'Database file path'**
  String get dialogDbPathHint;

  /// No description provided for @dialogBrowse.
  ///
  /// In en, this message translates to:
  /// **'Browse...'**
  String get dialogBrowse;

  /// No description provided for @dialogInputDbPath.
  ///
  /// In en, this message translates to:
  /// **'Please enter database file path'**
  String get dialogInputDbPath;

  /// No description provided for @dialogSelectDbFile.
  ///
  /// In en, this message translates to:
  /// **'Select Database File'**
  String get dialogSelectDbFile;

  /// No description provided for @dialogConfirmCloseDb.
  ///
  /// In en, this message translates to:
  /// **'Confirm Close Database'**
  String get dialogConfirmCloseDb;

  /// No description provided for @dialogConfirmCloseDbContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to close the current database?'**
  String get dialogConfirmCloseDbContent;

  /// No description provided for @statusDatabaseNotConnected.
  ///
  /// In en, this message translates to:
  /// **'Database Not Connected'**
  String get statusDatabaseNotConnected;

  /// No description provided for @statusDatabaseConnected.
  ///
  /// In en, this message translates to:
  /// **'Database Connected'**
  String get statusDatabaseConnected;

  /// No description provided for @statusDatabaseClosed.
  ///
  /// In en, this message translates to:
  /// **'Database Closed'**
  String get statusDatabaseClosed;

  /// No description provided for @statusDataLoaded.
  ///
  /// In en, this message translates to:
  /// **'Data Loaded'**
  String get statusDataLoaded;

  /// No description provided for @statusSwitchList.
  ///
  /// In en, this message translates to:
  /// **'Switched to list: {name}'**
  String statusSwitchList(String name);

  /// No description provided for @statusCreateList.
  ///
  /// In en, this message translates to:
  /// **'Created list: {name}'**
  String statusCreateList(String name);

  /// No description provided for @statusDeleteList.
  ///
  /// In en, this message translates to:
  /// **'Deleted list successfully'**
  String get statusDeleteList;

  /// No description provided for @statusPleaseOpenDb.
  ///
  /// In en, this message translates to:
  /// **'Please open database first'**
  String get statusPleaseOpenDb;

  /// No description provided for @statusShowToday.
  ///
  /// In en, this message translates to:
  /// **'Showing today\'s tasks'**
  String get statusShowToday;

  /// No description provided for @statusShowPlanned.
  ///
  /// In en, this message translates to:
  /// **'Showing planned tasks'**
  String get statusShowPlanned;

  /// No description provided for @statusShowAll.
  ///
  /// In en, this message translates to:
  /// **'Showing all tasks'**
  String get statusShowAll;

  /// No description provided for @statusShowCompleted.
  ///
  /// In en, this message translates to:
  /// **'Showing completed tasks'**
  String get statusShowCompleted;

  /// No description provided for @statusUpdateTaskState.
  ///
  /// In en, this message translates to:
  /// **'Task status updated'**
  String get statusUpdateTaskState;

  /// No description provided for @statusTaskUpdated.
  ///
  /// In en, this message translates to:
  /// **'Task updated'**
  String get statusTaskUpdated;

  /// No description provided for @statusTaskAdded.
  ///
  /// In en, this message translates to:
  /// **'Task added'**
  String get statusTaskAdded;

  /// No description provided for @statusTaskMoved.
  ///
  /// In en, this message translates to:
  /// **'Task moved to {name}'**
  String statusTaskMoved(String name);

  /// No description provided for @statusTaskDeleted.
  ///
  /// In en, this message translates to:
  /// **'Task deleted'**
  String get statusTaskDeleted;

  /// No description provided for @navToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get navToday;

  /// No description provided for @navPlanned.
  ///
  /// In en, this message translates to:
  /// **'Planned'**
  String get navPlanned;

  /// No description provided for @navAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get navAll;

  /// No description provided for @navCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get navCompleted;

  /// No description provided for @taskListInputHint.
  ///
  /// In en, this message translates to:
  /// **'+ Add Task'**
  String get taskListInputHint;

  /// No description provided for @taskListInputHintNoDb.
  ///
  /// In en, this message translates to:
  /// **'Please create or open database first'**
  String get taskListInputHintNoDb;

  /// No description provided for @taskListEmpty.
  ///
  /// In en, this message translates to:
  /// **'No tasks'**
  String get taskListEmpty;

  /// No description provided for @taskListEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Click \"File\" menu to create or open database'**
  String get taskListEmptyHint;

  /// No description provided for @taskEnterDesc.
  ///
  /// In en, this message translates to:
  /// **'Please enter task description'**
  String get taskEnterDesc;

  /// No description provided for @taskCreateListFirst.
  ///
  /// In en, this message translates to:
  /// **'Please create a task list first'**
  String get taskCreateListFirst;

  /// No description provided for @taskAddFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to add task: {error}'**
  String taskAddFailed(String error);

  /// No description provided for @taskDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get taskDeleteConfirm;

  /// No description provided for @taskDeleteConfirmContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this task? This action cannot be undone.'**
  String get taskDeleteConfirmContent;

  /// No description provided for @taskDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get taskDelete;

  /// No description provided for @sidebarHide.
  ///
  /// In en, this message translates to:
  /// **'Hide Sidebar'**
  String get sidebarHide;

  /// No description provided for @sidebarShow.
  ///
  /// In en, this message translates to:
  /// **'Show Sidebar'**
  String get sidebarShow;

  /// No description provided for @aboutContent.
  ///
  /// In en, this message translates to:
  /// **'A focused and efficient personal task management tool\nHelping you plan, organize and complete tasks easily'**
  String get aboutContent;

  /// No description provided for @dialogEditTask.
  ///
  /// In en, this message translates to:
  /// **'Edit Task'**
  String get dialogEditTask;

  /// No description provided for @dialogCreateList.
  ///
  /// In en, this message translates to:
  /// **'Create List'**
  String get dialogCreateList;

  /// No description provided for @dialogEditList.
  ///
  /// In en, this message translates to:
  /// **'Edit List'**
  String get dialogEditList;

  /// No description provided for @dialogListName.
  ///
  /// In en, this message translates to:
  /// **'List Name'**
  String get dialogListName;

  /// No description provided for @dialogListColor.
  ///
  /// In en, this message translates to:
  /// **'List Color'**
  String get dialogListColor;

  /// No description provided for @dialogListIcon.
  ///
  /// In en, this message translates to:
  /// **'List Icon'**
  String get dialogListIcon;

  /// No description provided for @dialogDeleteList.
  ///
  /// In en, this message translates to:
  /// **'Delete List'**
  String get dialogDeleteList;

  /// No description provided for @dialogDeleteListContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this list and all its tasks? This action cannot be undone.'**
  String get dialogDeleteListContent;

  /// No description provided for @dialogConfirmDeleteList.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"? This action cannot be undone.'**
  String dialogConfirmDeleteList(String name);

  /// No description provided for @dialogClearIcon.
  ///
  /// In en, this message translates to:
  /// **'Clear Icon'**
  String get dialogClearIcon;

  /// No description provided for @dialogClearColor.
  ///
  /// In en, this message translates to:
  /// **'Clear Color'**
  String get dialogClearColor;

  /// No description provided for @dialogInputListName.
  ///
  /// In en, this message translates to:
  /// **'Please enter list name'**
  String get dialogInputListName;

  /// No description provided for @menuShowListInfo.
  ///
  /// In en, this message translates to:
  /// **'Show List Info'**
  String get menuShowListInfo;

  /// No description provided for @menuRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get menuRename;

  /// No description provided for @sectionMyLists.
  ///
  /// In en, this message translates to:
  /// **'My Lists'**
  String get sectionMyLists;

  /// No description provided for @menuMarkCompleted.
  ///
  /// In en, this message translates to:
  /// **'Mark Completed'**
  String get menuMarkCompleted;

  /// No description provided for @menuMarkUncompleted.
  ///
  /// In en, this message translates to:
  /// **'Mark Uncompleted'**
  String get menuMarkUncompleted;

  /// No description provided for @menuMoveToList.
  ///
  /// In en, this message translates to:
  /// **'Move to List'**
  String get menuMoveToList;

  /// No description provided for @menuDeleteTask.
  ///
  /// In en, this message translates to:
  /// **'Delete Task'**
  String get menuDeleteTask;

  /// No description provided for @labelAddDate.
  ///
  /// In en, this message translates to:
  /// **'Add Date'**
  String get labelAddDate;

  /// No description provided for @labelAddTime.
  ///
  /// In en, this message translates to:
  /// **'Add Time'**
  String get labelAddTime;

  /// No description provided for @taskSelectTask.
  ///
  /// In en, this message translates to:
  /// **'Please select a task list'**
  String get taskSelectTask;

  /// No description provided for @dialogCannotAddTask.
  ///
  /// In en, this message translates to:
  /// **'Cannot Add Task'**
  String get dialogCannotAddTask;

  /// No description provided for @dialogDbNotConnectedContent.
  ///
  /// In en, this message translates to:
  /// **'Database not connected, please create or open a database file first'**
  String get dialogDbNotConnectedContent;

  /// No description provided for @dialogAddTask.
  ///
  /// In en, this message translates to:
  /// **'Add New Task'**
  String get dialogAddTask;

  /// No description provided for @labelTaskDesc.
  ///
  /// In en, this message translates to:
  /// **'Task Description:'**
  String get labelTaskDesc;

  /// No description provided for @labelDueDateOptional.
  ///
  /// In en, this message translates to:
  /// **'Due Date (Optional):'**
  String get labelDueDateOptional;

  /// No description provided for @labelTaskList.
  ///
  /// In en, this message translates to:
  /// **'Task List:'**
  String get labelTaskList;

  /// No description provided for @dialogSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get dialogSave;

  /// No description provided for @hintDateSupport.
  ///
  /// In en, this message translates to:
  /// **'Supports: +10m(10 mins), +2h(2 hours), +1d(tomorrow), @10am, @10:30pm'**
  String get hintDateSupport;

  /// No description provided for @dialogTaskDetail.
  ///
  /// In en, this message translates to:
  /// **'Task Detail'**
  String get dialogTaskDetail;

  /// No description provided for @labelTask.
  ///
  /// In en, this message translates to:
  /// **'Task:'**
  String get labelTask;

  /// No description provided for @labelNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes:'**
  String get labelNotes;

  /// No description provided for @labelDate.
  ///
  /// In en, this message translates to:
  /// **'Date:'**
  String get labelDate;

  /// No description provided for @labelTime.
  ///
  /// In en, this message translates to:
  /// **'Time:'**
  String get labelTime;

  /// No description provided for @hintAddNotes.
  ///
  /// In en, this message translates to:
  /// **'Add notes...'**
  String get hintAddNotes;

  /// No description provided for @taskUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update task: {error}'**
  String taskUpdateFailed(String error);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
