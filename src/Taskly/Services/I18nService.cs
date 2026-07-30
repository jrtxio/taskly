using System.ComponentModel;
using System.Globalization;
using CommunityToolkit.Mvvm.ComponentModel;

namespace Taskly.Services;

/// <summary>
/// 国际化服务，对应原 Flutter 版 l10n（app_en.arb / app_zh.arb）。
/// 复用原版全部文案 key/value，支持运行时切换语言并持久化。
/// 继承 ObservableObject 以便 UI 绑定当前语言切换后自动刷新。
/// </summary>
public sealed partial class I18nService : ObservableObject
{
    /// <summary>支持的语言代码。</summary>
    public const string Chinese = "zh";
    public const string English = "en";

    private readonly Dictionary<string, string> _zh = new(StringComparer.Ordinal);
    private readonly Dictionary<string, string> _en = new(StringComparer.Ordinal);

    [ObservableProperty]
    private string _currentLanguage = Chinese;

    public I18nService()
    {
        InitializeChinese();
        InitializeEnglish();
    }

    /// <summary>当前语言（zh / en）。设置后触发属性变更通知。</summary>
    public void SetLanguage(string language)
    {
        var lang = language is English or Chinese ? language : Chinese;
        if (CurrentLanguage != lang)
        {
            CurrentLanguage = lang;
            LanguageChanged?.Invoke(this, EventArgs.Empty);
        }
    }

    /// <summary>语言切换事件，ViewModel 监听后触发刷新。</summary>
    public event EventHandler? LanguageChanged;

    /// <summary>取当前语言文案。支持 {name}/{error}/{length} 占位符替换。</summary>
    public string T(string key, params object[] args)
    {
        var table = CurrentLanguage == English ? _en : _zh;
        var value = table.TryGetValue(key, out var v) ? v : _zh.TryGetValue(key, out var v2) ? v2 : key;

        return args.Length > 0 ? string.Format(CultureInfo.InvariantCulture, value, args) : value;
    }

    /// <summary>当前 CultureInfo（用于日期/数字格式化）。</summary>
    public CultureInfo Culture => CurrentLanguage == English
        ? CultureInfo.GetCultureInfo("en-US")
        : CultureInfo.GetCultureInfo("zh-CN");

    private void InitializeChinese()
    {
        // 应用与菜单
        _zh["appTitle"] = "Taskly";
        _zh["menuFile"] = "文件";
        _zh["menuSettings"] = "设置";
        _zh["menuHelp"] = "帮助";
        _zh["menuNewDatabase"] = "新建数据库";
        _zh["menuOpenDatabase"] = "打开数据库";
        _zh["menuCloseDatabase"] = "关闭数据库";
        _zh["menuExit"] = "退出";
        _zh["menuLanguage"] = "语言";
        _zh["menuAbout"] = "关于";
        _zh["menuLangEn"] = "English";
        _zh["menuLangZh"] = "简体中文";
        _zh["menuShowListInfo"] = "显示列表信息";
        _zh["menuRename"] = "重命名";
        _zh["menuMarkCompleted"] = "标记完成";
        _zh["menuMarkUncompleted"] = "标记未完成";
        _zh["menuMoveToList"] = "移动到列表";
        _zh["menuDeleteTask"] = "删除任务";
        _zh["aboutContent"] = "一款专注高效的个人任务管理工具\n帮助您轻松规划、组织和完成各项任务";

        // 导航/智能列表
        _zh["navToday"] = "今天";
        _zh["navPlanned"] = "计划";
        _zh["navAll"] = "全部";
        _zh["navCompleted"] = "完成";
        _zh["sectionSmartLists"] = "智能列表";
        _zh["sectionMyLists"] = "我的列表";
        _zh["sidebarHide"] = "隐藏侧边栏";
        _zh["sidebarShow"] = "显示侧边栏";

        // 通用对话框
        _zh["dialogSelectLanguage"] = "选择语言";
        _zh["dialogCancel"] = "取消";
        _zh["dialogConfirm"] = "确定";
        _zh["dialogClear"] = "清除";
        _zh["dialogValidationFailed"] = "输入验证失败";
        _zh["dialogSelectIcon"] = "选择图标";
        _zh["dialogSelectColor"] = "选择颜色";
        _zh["dialogClearIcon"] = "清除图标";
        _zh["dialogClearColor"] = "清除颜色";

        // 数据库对话框
        _zh["dialogNewDatabase"] = "新建数据库";
        _zh["dialogEnterDbPath"] = "请输入新数据库文件的路径和名称";
        _zh["dialogDbPathHint"] = "数据库文件路径";
        _zh["dialogBrowse"] = "浏览...";
        _zh["dialogInputDbPath"] = "请输入数据库文件路径";
        _zh["dialogSelectDbFile"] = "选择数据库文件";
        _zh["dialogConfirmCloseDb"] = "确认关闭数据库";
        _zh["dialogConfirmCloseDbContent"] = "确定要关闭当前数据库吗？";
        _zh["dialogSaveDbTitle"] = "保存数据库文件";
        _zh["dialogNoDbOpened"] = "当前没有打开的数据库";

        // 列表对话框
        _zh["dialogCreateList"] = "创建列表";
        _zh["dialogEditList"] = "编辑列表";
        _zh["dialogListName"] = "列表名称";
        _zh["dialogListColor"] = "列表颜色";
        _zh["dialogListIcon"] = "列表图标";
        _zh["dialogDeleteList"] = "删除列表";
        _zh["dialogDeleteListContent"] = "确定要删除此列表及其所有任务吗？此操作无法撤销。";
        _zh["dialogConfirmDeleteList"] = "确定要删除\"{0}\"吗？此操作无法撤销。";
        _zh["dialogInputListName"] = "请输入列表名称";

        // 任务对话框与标签
        _zh["dialogEditTask"] = "编辑任务";
        _zh["dialogAddTask"] = "添加新任务";
        _zh["dialogTaskDetail"] = "任务详情";
        _zh["dialogCannotAddTask"] = "无法添加任务";
        _zh["dialogDbNotConnectedContent"] = "数据库未连接，请先创建或打开数据库文件";
        _zh["dialogSave"] = "保存";
        _zh["labelTaskDesc"] = "任务描述:";
        _zh["labelDueDateOptional"] = "截止日期 (可选):";
        _zh["labelTaskList"] = "任务列表:";
        _zh["labelTask"] = "任务:";
        _zh["labelNotes"] = "备注:";
        _zh["labelDate"] = "日期:";
        _zh["labelTime"] = "时间:";
        _zh["labelAddDate"] = "添加日期";
        _zh["labelAddTime"] = "添加时间";
        _zh["hintAddNotes"] = "添加备注信息...";
        _zh["hintDateSupport"] = "支持: +10m(10分钟), +2h(2小时), +1d(明天), @10am(上午10点), @10:30pm(晚上10:30)";
        _zh["hintDateExample"] = "例如: +10m, @10am, 2025-08-07";
        _zh["taskDeleteConfirm"] = "确认删除";
        _zh["taskDeleteConfirmContent"] = "确定要删除这个任务吗？此操作无法撤销。";
        _zh["taskDelete"] = "删除";

        // 状态栏
        _zh["statusDatabaseNotConnected"] = "未连接数据库";
        _zh["statusDatabaseConnected"] = "数据库已连接";
        _zh["statusDatabaseClosed"] = "数据库已关闭";
        _zh["statusDataLoaded"] = "数据已加载";
        _zh["statusSwitchList"] = "切换到列表: {0}";
        _zh["statusCreateList"] = "创建列表: {0}";
        _zh["statusDeleteList"] = "删除列表成功";
        _zh["statusPleaseOpenDb"] = "请先打开数据库";
        _zh["statusShowToday"] = "显示今天的任务";
        _zh["statusShowPlanned"] = "显示计划中的任务";
        _zh["statusShowAll"] = "显示全部任务";
        _zh["statusShowCompleted"] = "显示完成的任务";
        _zh["statusUpdateTaskState"] = "更新任务状态";
        _zh["statusTaskUpdated"] = "任务已更新";
        _zh["statusTaskAdded"] = "任务已添加";
        _zh["statusTaskMoved"] = "任务已移动到 {0}";
        _zh["statusTaskDeleted"] = "任务已删除";

        // 任务列表 / 验证 / 错误
        _zh["taskListInputHint"] = "+ 添加任务";
        _zh["taskListInputHintNoDb"] = "请先创建或打开数据库";
        _zh["taskListEmpty"] = "暂无任务";
        _zh["taskListEmptyHint"] = "请点击\"文件\"菜单创建或打开数据库";
        _zh["taskEnterDesc"] = "请输入任务描述";
        _zh["taskCreateListFirst"] = "请先创建一个任务列表";
        _zh["taskSelectTask"] = "请选择任务列表";
        _zh["taskAddFailed"] = "添加任务失败: {0}";
        _zh["taskUpdateFailed"] = "更新任务失败: {0}";
        _zh["dateTomorrow"] = "明天";
        _zh["dateYesterday"] = "昨天";
        _zh["errorEnterTaskDesc"] = "请输入任务描述";
        _zh["errorTaskDescTooLong"] = "任务描述不能超过 {0} 个字符";
        _zh["errorEnterListName"] = "请输入列表名称";
        _zh["errorListNameTooLong"] = "列表名称不能超过 {0} 个字符";
        _zh["errorSearchKeywordTooLong"] = "搜索关键词不能超过 {0} 个字符";
        _zh["errorDateTooEarly"] = "日期不能早于 1900 年";
        _zh["errorDateTooLate"] = "日期不能晚于 2100 年";
        _zh["errorInvalidDateFormat"] = "无效的日期格式";

        // 额外 UI 文案
        _zh["showCompletedToggle"] = "显示已完成";
        _zh["hideCompletedToggle"] = "隐藏已完成";
        _zh["searchHint"] = "搜索任务";
    }

    private void InitializeEnglish()
    {
        _en["appTitle"] = "Taskly";
        _en["menuFile"] = "File";
        _en["menuSettings"] = "Settings";
        _en["menuHelp"] = "Help";
        _en["menuNewDatabase"] = "New Database";
        _en["menuOpenDatabase"] = "Open Database";
        _en["menuCloseDatabase"] = "Close Database";
        _en["menuExit"] = "Exit";
        _en["menuLanguage"] = "Language";
        _en["menuAbout"] = "About";
        _en["menuLangEn"] = "English";
        _en["menuLangZh"] = "Simplified Chinese";
        _en["menuShowListInfo"] = "Show List Info";
        _en["menuRename"] = "Rename";
        _en["menuMarkCompleted"] = "Mark Completed";
        _en["menuMarkUncompleted"] = "Mark Uncompleted";
        _en["menuMoveToList"] = "Move to List";
        _en["menuDeleteTask"] = "Delete Task";
        _en["aboutContent"] = "A focused and efficient personal task management tool\nHelping you plan, organize and complete tasks easily";

        _en["navToday"] = "Today";
        _en["navPlanned"] = "Planned";
        _en["navAll"] = "All";
        _en["navCompleted"] = "Completed";
        _en["sectionSmartLists"] = "Smart Lists";
        _en["sectionMyLists"] = "My Lists";
        _en["sidebarHide"] = "Hide Sidebar";
        _en["sidebarShow"] = "Show Sidebar";

        _en["dialogSelectLanguage"] = "Select Language";
        _en["dialogCancel"] = "Cancel";
        _en["dialogConfirm"] = "OK";
        _en["dialogClear"] = "Clear";
        _en["dialogValidationFailed"] = "Validation Failed";
        _en["dialogSelectIcon"] = "Select Icon";
        _en["dialogSelectColor"] = "Select Color";
        _en["dialogClearIcon"] = "Clear Icon";
        _en["dialogClearColor"] = "Clear Color";

        _en["dialogNewDatabase"] = "New Database";
        _en["dialogEnterDbPath"] = "Please enter database file path and name";
        _en["dialogDbPathHint"] = "Database file path";
        _en["dialogBrowse"] = "Browse...";
        _en["dialogInputDbPath"] = "Please enter database file path";
        _en["dialogSelectDbFile"] = "Select Database File";
        _en["dialogConfirmCloseDb"] = "Confirm Close Database";
        _en["dialogConfirmCloseDbContent"] = "Are you sure you want to close the current database?";
        _en["dialogSaveDbTitle"] = "Save Database File";
        _en["dialogNoDbOpened"] = "No database opened";

        _en["dialogCreateList"] = "Create List";
        _en["dialogEditList"] = "Edit List";
        _en["dialogListName"] = "List Name";
        _en["dialogListColor"] = "List Color";
        _en["dialogListIcon"] = "List Icon";
        _en["dialogDeleteList"] = "Delete List";
        _en["dialogDeleteListContent"] = "Are you sure you want to delete this list and all its tasks? This action cannot be undone.";
        _en["dialogConfirmDeleteList"] = "Are you sure you want to delete \"{0}\"? This action cannot be undone.";
        _en["dialogInputListName"] = "Please enter list name";

        _en["dialogEditTask"] = "Edit Task";
        _en["dialogAddTask"] = "Add New Task";
        _en["dialogTaskDetail"] = "Task Detail";
        _en["dialogCannotAddTask"] = "Cannot Add Task";
        _en["dialogDbNotConnectedContent"] = "Database not connected, please create or open a database file first";
        _en["dialogSave"] = "Save";
        _en["labelTaskDesc"] = "Task Description:";
        _en["labelDueDateOptional"] = "Due Date (Optional):";
        _en["labelTaskList"] = "Task List:";
        _en["labelTask"] = "Task:";
        _en["labelNotes"] = "Notes:";
        _en["labelDate"] = "Date:";
        _en["labelTime"] = "Time:";
        _en["labelAddDate"] = "Add Date";
        _en["labelAddTime"] = "Add Time";
        _en["hintAddNotes"] = "Add notes...";
        _en["hintDateSupport"] = "Supports: +10m(10 mins), +2h(2 hours), +1d(tomorrow), @10am, @10:30pm";
        _en["hintDateExample"] = "e.g., +10m, @10am, 2025-08-07";
        _en["taskDeleteConfirm"] = "Confirm Delete";
        _en["taskDeleteConfirmContent"] = "Are you sure you want to delete this task? This action cannot be undone.";
        _en["taskDelete"] = "Delete";

        _en["statusDatabaseNotConnected"] = "Database Not Connected";
        _en["statusDatabaseConnected"] = "Database Connected";
        _en["statusDatabaseClosed"] = "Database Closed";
        _en["statusDataLoaded"] = "Data Loaded";
        _en["statusSwitchList"] = "Switched to list: {0}";
        _en["statusCreateList"] = "Created list: {0}";
        _en["statusDeleteList"] = "Deleted list successfully";
        _en["statusPleaseOpenDb"] = "Please open database first";
        _en["statusShowToday"] = "Showing today's tasks";
        _en["statusShowPlanned"] = "Showing planned tasks";
        _en["statusShowAll"] = "Showing all tasks";
        _en["statusShowCompleted"] = "Showing completed tasks";
        _en["statusUpdateTaskState"] = "Task status updated";
        _en["statusTaskUpdated"] = "Task updated";
        _en["statusTaskAdded"] = "Task added";
        _en["statusTaskMoved"] = "Task moved to {0}";
        _en["statusTaskDeleted"] = "Task deleted";

        _en["taskListInputHint"] = "+ Add Task";
        _en["taskListInputHintNoDb"] = "Please create or open database first";
        _en["taskListEmpty"] = "No tasks";
        _en["taskListEmptyHint"] = "Click \"File\" menu to create or open database";
        _en["taskEnterDesc"] = "Please enter task description";
        _en["taskCreateListFirst"] = "Please create a task list first";
        _en["taskSelectTask"] = "Please select a task list";
        _en["taskAddFailed"] = "Failed to add task: {0}";
        _en["taskUpdateFailed"] = "Failed to update task: {0}";
        _en["dateTomorrow"] = "Tomorrow";
        _en["dateYesterday"] = "Yesterday";
        _en["errorEnterTaskDesc"] = "Please enter task description";
        _en["errorTaskDescTooLong"] = "Task description cannot exceed {0} characters";
        _en["errorEnterListName"] = "Please enter list name";
        _en["errorListNameTooLong"] = "List name cannot exceed {0} characters";
        _en["errorSearchKeywordTooLong"] = "Search keyword cannot exceed {0} characters";
        _en["errorDateTooEarly"] = "Date cannot be earlier than 1900";
        _en["errorDateTooLate"] = "Date cannot be later than 2100";
        _en["errorInvalidDateFormat"] = "Invalid date format";

        _en["showCompletedToggle"] = "Show Completed";
        _en["hideCompletedToggle"] = "Hide Completed";
        _en["searchHint"] = "Search tasks";
    }
}
