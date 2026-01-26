// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Taskly';

  @override
  String get menuFile => '文件';

  @override
  String get menuSettings => '设置';

  @override
  String get menuHelp => '帮助';

  @override
  String get menuNewDatabase => '新建数据库';

  @override
  String get menuOpenDatabase => '打开数据库';

  @override
  String get menuCloseDatabase => '关闭数据库';

  @override
  String get menuExit => '退出';

  @override
  String get menuLanguage => '语言';

  @override
  String get menuAbout => '关于 Taskly';

  @override
  String get dialogSelectLanguage => '选择语言';

  @override
  String get dialogCancel => '取消';

  @override
  String get dialogConfirm => '确定';

  @override
  String get dialogNewDatabase => '新建数据库';

  @override
  String get dialogEnterDbPath => '请输入新数据库文件的路径和名称';

  @override
  String get dialogDbPathHint => '数据库文件路径';

  @override
  String get dialogBrowse => '浏览...';

  @override
  String get dialogInputDbPath => '请输入数据库文件路径';

  @override
  String get dialogSelectDbFile => '选择数据库文件';

  @override
  String get dialogConfirmCloseDb => '确认关闭数据库';

  @override
  String get dialogConfirmCloseDbContent => '确定要关闭当前数据库吗？';

  @override
  String get statusDatabaseNotConnected => '未连接数据库';

  @override
  String get statusDatabaseConnected => '数据库已连接';

  @override
  String get statusDatabaseClosed => '数据库已关闭';

  @override
  String get statusDataLoaded => '数据已加载';

  @override
  String statusSwitchList(String name) {
    return '切换到列表: $name';
  }

  @override
  String statusCreateList(String name) {
    return '创建列表: $name';
  }

  @override
  String get statusDeleteList => '删除列表成功';

  @override
  String get statusPleaseOpenDb => '请先打开数据库';

  @override
  String get statusShowToday => '显示今天的任务';

  @override
  String get statusShowPlanned => '显示计划中的任务';

  @override
  String get statusShowAll => '显示全部任务';

  @override
  String get statusShowCompleted => '显示完成的任务';

  @override
  String get statusUpdateTaskState => '更新任务状态';

  @override
  String get statusTaskUpdated => '任务已更新';

  @override
  String get statusTaskAdded => '任务已添加';

  @override
  String statusTaskMoved(String name) {
    return '任务已移动到 $name';
  }

  @override
  String get statusTaskDeleted => '任务已删除';

  @override
  String get navToday => '今天';

  @override
  String get navPlanned => '计划';

  @override
  String get navAll => '全部';

  @override
  String get navCompleted => '完成';

  @override
  String get taskListInputHint => '+ 添加任务';

  @override
  String get taskListInputHintNoDb => '请先创建或打开数据库';

  @override
  String get taskListEmpty => '暂无任务';

  @override
  String get taskListEmptyHint => '请点击\"文件\"菜单创建或打开数据库';

  @override
  String get taskEnterDesc => '请输入任务描述';

  @override
  String get taskCreateListFirst => '请先创建一个任务列表';

  @override
  String taskAddFailed(String error) {
    return '添加任务失败: $error';
  }

  @override
  String get taskDeleteConfirm => '确认删除';

  @override
  String get taskDeleteConfirmContent => '确定要删除这个任务吗？此操作无法撤销。';

  @override
  String get taskDelete => '删除';

  @override
  String get sidebarHide => '隐藏侧边栏';

  @override
  String get sidebarShow => '显示侧边栏';

  @override
  String get aboutContent => '一款专注高效的个人任务管理工具\n帮助您轻松规划、组织和完成各项任务';

  @override
  String get dialogEditTask => '编辑任务';

  @override
  String get dialogCreateList => '创建列表';

  @override
  String get dialogEditList => '编辑列表';

  @override
  String get dialogListName => '列表名称';

  @override
  String get dialogListColor => '列表颜色';

  @override
  String get dialogListIcon => '列表图标';

  @override
  String get dialogDeleteList => '删除列表';

  @override
  String get dialogDeleteListContent => '确定要删除此列表及其所有任务吗？此操作无法撤销。';

  @override
  String dialogConfirmDeleteList(String name) {
    return '确定要删除“$name”吗？此操作无法撤销。';
  }

  @override
  String get dialogClearIcon => '清除图标';

  @override
  String get dialogClearColor => '清除颜色';

  @override
  String get dialogInputListName => '请输入列表名称';

  @override
  String get menuShowListInfo => '显示列表信息';

  @override
  String get menuRename => '重命名';

  @override
  String get sectionMyLists => '我的列表';

  @override
  String get menuMarkCompleted => '标记完成';

  @override
  String get menuMarkUncompleted => '标记未完成';

  @override
  String get menuMoveToList => '移动到列表';

  @override
  String get menuDeleteTask => '删除任务';

  @override
  String get labelAddDate => '添加日期';

  @override
  String get labelAddTime => '添加时间';

  @override
  String get taskSelectTask => '请选择任务列表';

  @override
  String get dialogCannotAddTask => '无法添加任务';

  @override
  String get dialogDbNotConnectedContent => '数据库未连接，请先创建或打开数据库文件';

  @override
  String get dialogAddTask => '添加新任务';

  @override
  String get labelTaskDesc => '任务描述:';

  @override
  String get labelDueDateOptional => '截止日期 (可选):';

  @override
  String get labelTaskList => '任务列表:';

  @override
  String get dialogSave => '保存';

  @override
  String get hintDateSupport =>
      '支持: +10m(10分钟), +2h(2小时), +1d(明天), @10am(上午10点), @10:30pm(晚上10:30)';

  @override
  String get dialogTaskDetail => '任务详情';

  @override
  String get labelTask => '任务:';

  @override
  String get labelNotes => '备注:';

  @override
  String get labelDate => '日期:';

  @override
  String get labelTime => '时间:';

  @override
  String get hintAddNotes => '添加备注信息...';

  @override
  String taskUpdateFailed(String error) {
    return '更新任务失败: $error';
  }
}
