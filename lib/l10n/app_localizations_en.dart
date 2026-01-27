// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Taskly';

  @override
  String get menuFile => 'File';

  @override
  String get menuSettings => 'Settings';

  @override
  String get menuHelp => 'Help';

  @override
  String get menuNewDatabase => 'New Database';

  @override
  String get menuOpenDatabase => 'Open Database';

  @override
  String get menuCloseDatabase => 'Close Database';

  @override
  String get menuExit => 'Exit';

  @override
  String get menuLanguage => 'Language';

  @override
  String get menuAbout => 'About';

  @override
  String get dialogSelectLanguage => 'Select Language';

  @override
  String get dialogCancel => 'Cancel';

  @override
  String get dialogConfirm => 'OK';

  @override
  String get dialogNewDatabase => 'New Database';

  @override
  String get dialogEnterDbPath => 'Please enter database file path and name';

  @override
  String get dialogDbPathHint => 'Database file path';

  @override
  String get dialogBrowse => 'Browse...';

  @override
  String get dialogInputDbPath => 'Please enter database file path';

  @override
  String get dialogSelectDbFile => 'Select Database File';

  @override
  String get dialogConfirmCloseDb => 'Confirm Close Database';

  @override
  String get dialogConfirmCloseDbContent =>
      'Are you sure you want to close the current database?';

  @override
  String get statusDatabaseNotConnected => 'Database Not Connected';

  @override
  String get statusDatabaseConnected => 'Database Connected';

  @override
  String get statusDatabaseClosed => 'Database Closed';

  @override
  String get statusDataLoaded => 'Data Loaded';

  @override
  String statusSwitchList(String name) {
    return 'Switched to list: $name';
  }

  @override
  String statusCreateList(String name) {
    return 'Created list: $name';
  }

  @override
  String get statusDeleteList => 'Deleted list successfully';

  @override
  String get statusPleaseOpenDb => 'Please open database first';

  @override
  String get statusShowToday => 'Showing today\'s tasks';

  @override
  String get statusShowPlanned => 'Showing planned tasks';

  @override
  String get statusShowAll => 'Showing all tasks';

  @override
  String get statusShowCompleted => 'Showing completed tasks';

  @override
  String get statusUpdateTaskState => 'Task status updated';

  @override
  String get statusTaskUpdated => 'Task updated';

  @override
  String get statusTaskAdded => 'Task added';

  @override
  String statusTaskMoved(String name) {
    return 'Task moved to $name';
  }

  @override
  String get statusTaskDeleted => 'Task deleted';

  @override
  String get navToday => 'Today';

  @override
  String get navPlanned => 'Planned';

  @override
  String get navAll => 'All';

  @override
  String get navCompleted => 'Completed';

  @override
  String get taskListInputHint => '+ Add Task';

  @override
  String get taskListInputHintNoDb => 'Please create or open database first';

  @override
  String get taskListEmpty => 'No tasks';

  @override
  String get taskListEmptyHint =>
      'Click \"File\" menu to create or open database';

  @override
  String get taskEnterDesc => 'Please enter task description';

  @override
  String get taskCreateListFirst => 'Please create a task list first';

  @override
  String taskAddFailed(String error) {
    return 'Failed to add task: $error';
  }

  @override
  String get taskDeleteConfirm => 'Confirm Delete';

  @override
  String get taskDeleteConfirmContent =>
      'Are you sure you want to delete this task? This action cannot be undone.';

  @override
  String get taskDelete => 'Delete';

  @override
  String get sidebarHide => 'Hide Sidebar';

  @override
  String get sidebarShow => 'Show Sidebar';

  @override
  String get aboutContent =>
      'A focused and efficient personal task management tool\nHelping you plan, organize and complete tasks easily';

  @override
  String get dialogEditTask => 'Edit Task';

  @override
  String get dialogCreateList => 'Create List';

  @override
  String get dialogEditList => 'Edit List';

  @override
  String get dialogListName => 'List Name';

  @override
  String get dialogListColor => 'List Color';

  @override
  String get dialogListIcon => 'List Icon';

  @override
  String get dialogDeleteList => 'Delete List';

  @override
  String get dialogDeleteListContent =>
      'Are you sure you want to delete this list and all its tasks? This action cannot be undone.';

  @override
  String dialogConfirmDeleteList(String name) {
    return 'Are you sure you want to delete \"$name\"? This action cannot be undone.';
  }

  @override
  String get dialogClearIcon => 'Clear Icon';

  @override
  String get dialogClearColor => 'Clear Color';

  @override
  String get dialogInputListName => 'Please enter list name';

  @override
  String get menuShowListInfo => 'Show List Info';

  @override
  String get menuRename => 'Rename';

  @override
  String get sectionMyLists => 'My Lists';

  @override
  String get menuMarkCompleted => 'Mark Completed';

  @override
  String get menuMarkUncompleted => 'Mark Uncompleted';

  @override
  String get menuMoveToList => 'Move to List';

  @override
  String get menuDeleteTask => 'Delete Task';

  @override
  String get labelAddDate => 'Add Date';

  @override
  String get labelAddTime => 'Add Time';

  @override
  String get taskSelectTask => 'Please select a task list';

  @override
  String get dialogCannotAddTask => 'Cannot Add Task';

  @override
  String get dialogDbNotConnectedContent =>
      'Database not connected, please create or open a database file first';

  @override
  String get dialogAddTask => 'Add New Task';

  @override
  String get labelTaskDesc => 'Task Description:';

  @override
  String get labelDueDateOptional => 'Due Date (Optional):';

  @override
  String get labelTaskList => 'Task List:';

  @override
  String get dialogSave => 'Save';

  @override
  String get hintDateSupport =>
      'Supports: +10m(10 mins), +2h(2 hours), +1d(tomorrow), @10am, @10:30pm';

  @override
  String get hintDateExample => 'e.g., +10m, @10am, 2025-08-07';

  @override
  String get dialogTaskDetail => 'Task Detail';

  @override
  String get labelTask => 'Task:';

  @override
  String get labelNotes => 'Notes:';

  @override
  String get labelDate => 'Date:';

  @override
  String get labelTime => 'Time:';

  @override
  String get hintAddNotes => 'Add notes...';

  @override
  String taskUpdateFailed(String error) {
    return 'Failed to update task: $error';
  }

  @override
  String get dialogSaveDbTitle => 'Save Database File';

  @override
  String get dialogNoDbOpened => 'No database opened';

  @override
  String get menuLangEn => 'English';

  @override
  String get menuLangZh => 'Simplified Chinese';

  @override
  String get dateTomorrow => 'Tomorrow';

  @override
  String get dateYesterday => 'Yesterday';

  @override
  String get dialogSelectIcon => 'Select Icon';

  @override
  String get dialogSelectColor => 'Select Color';

  @override
  String get dialogClear => 'Clear';

  @override
  String get errorEnterTaskDesc => 'Please enter task description';

  @override
  String errorTaskDescTooLong(int length) {
    return 'Task description cannot exceed $length characters';
  }

  @override
  String get errorEnterListName => 'Please enter list name';

  @override
  String errorListNameTooLong(int length) {
    return 'List name cannot exceed $length characters';
  }

  @override
  String errorSearchKeywordTooLong(int length) {
    return 'Search keyword cannot exceed $length characters';
  }

  @override
  String get errorDateTooEarly => 'Date cannot be earlier than 1900';

  @override
  String get errorDateTooLate => 'Date cannot be later than 2100';

  @override
  String get errorInvalidDateFormat => 'Invalid date format';

  @override
  String get dialogValidationFailed => 'Validation Failed';
}
