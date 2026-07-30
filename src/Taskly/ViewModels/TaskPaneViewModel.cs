using System.Collections.ObjectModel;
using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using Microsoft.Extensions.Logging;
using Taskly.Data;
using Taskly.Models;
using Taskly.Repositories;
using Taskly.Services;

namespace Taskly.ViewModels;

/// <summary>
/// 任务面板 ViewModel，对应原 Flutter 版 TaskProvider。
/// 管理当前任务列表、搜索、快速添加、行内编辑、分组显示、showCompleted 开关。
/// 当前视图与选中列表从 ListPaneViewModel 获取。
/// </summary>
public sealed partial class TaskPaneViewModel : ViewModelBase
{
    private readonly ITaskRepository _taskRepo;
    private readonly IListRepository _listRepo;
    private readonly SQLiteDatabase _db;
    private readonly ListPaneViewModel _listPane;
    private readonly DateParser _dateParser;
    private readonly ILogger<TaskPaneViewModel> _logger;

    private MainViewModel? _main;

    /// <summary>主 VM 引用（由 App 在创建后设置，避免构造循环依赖）。
    /// 设置时订阅其属性变化，以便连接状态变更时刷新派生属性。</summary>
    internal MainViewModel Main
    {
        get => _main!;
        set
        {
            if (_main is not null)
            {
                _main.PropertyChanged -= OnMainPropertyChanged;
            }

            _main = value;
            if (_main is not null)
            {
                _main.PropertyChanged += OnMainPropertyChanged;
            }
        }
    }

    /// <summary>主 VM 的属性变化时，刷新依赖它的派生属性。</summary>
    private void OnMainPropertyChanged(object? sender, System.ComponentModel.PropertyChangedEventArgs e)
    {
        if (e.PropertyName == nameof(MainViewModel.IsDatabaseConnected))
        {
            // 连接状态变化时，通知所有依赖它的派生属性重新求值
            OnPropertyChanged(nameof(IsConnected));
            OnPropertyChanged(nameof(IsNotConnected));
            OnPropertyChanged(nameof(IsNoDb));
            OnPropertyChanged(nameof(ShowEmptyState));
            OnPropertyChanged(nameof(QuickAddHint));
        }
        else if (e.PropertyName == nameof(MainViewModel.StatusMessage))
        {
            // 状态消息变化无需处理
        }
    }

    public TaskPaneViewModel(
        ITaskRepository taskRepo,
        IListRepository listRepo,
        SQLiteDatabase db,
        ListPaneViewModel listPane,
        DateParser dateParser,
        ILogger<TaskPaneViewModel> logger)
    {
        _taskRepo = taskRepo;
        _listRepo = listRepo;
        _db = db;
        _listPane = listPane;
        _dateParser = dateParser;
        _logger = logger;

        Tasks.CollectionChanged += OnTasksChanged;
    }

    /// <summary>当前显示的任务（已按完成态排序）。</summary>
    public ObservableCollection<TaskItem> Tasks { get; } = new();

    /// <summary>任务集合变化时，刷新依赖它的派生属性（HasTasks/IsEmpty/ShowEmptyState）。</summary>
    private void OnTasksChanged(object? sender, System.Collections.Specialized.NotifyCollectionChangedEventArgs e)
    {
        OnPropertyChanged(nameof(HasTasks));
        OnPropertyChanged(nameof(IsEmpty));
        OnPropertyChanged(nameof(ShowEmptyState));
    }

    /// <summary>分组显示时的组（仅「全部」视图使用）。key=listId。</summary>
    public ObservableCollection<TaskGroup> Groups { get; } = new();

    [ObservableProperty]
    private string _quickAddText = string.Empty;

    [ObservableProperty]
    private string _searchKeyword = string.Empty;

    [ObservableProperty]
    private bool _showCompletedTasks;

    [ObservableProperty]
    private bool _isLoading;

    [ObservableProperty]
    private TaskItem? _selectedTask;

    /// <summary>是否分组显示（仅「全部」视图分组）。</summary>
    public bool IsGrouped => _listPane.CurrentView == TaskViewType.All && string.IsNullOrEmpty(SearchKeyword);

    /// <summary>当前是否无数据库连接。</summary>
    public bool IsNoDb => !Main.IsDatabaseConnected;

    /// <summary>清空数据（数据库断开时）。</summary>
    public void Clear()
    {
        Tasks.Clear();
        Groups.Clear();
        QuickAddText = string.Empty;
        SearchKeyword = string.Empty;
        ShowCompletedTasks = false;
    }

    /// <summary>刷新当前视图的任务。对应原版 refreshTasks。</summary>
    public async Task RefreshAsync()
    {
        if (!Main.IsDatabaseConnected)
        {
            Tasks.Clear();
            Groups.Clear();
            return;
        }

        IsLoading = true;
        try
        {
            var viewType = _listPane.CurrentView;
            var listId = _listPane.SelectedList?.Id;
            var keyword = SearchKeyword;

            List<TaskItem> tasks;
            if (!string.IsNullOrEmpty(keyword))
            {
                tasks = await _taskRepo.SearchTasksAsync(keyword);
            }
            else
            {
                tasks = await _taskRepo.GetTasksByViewAsync(
                    viewType, listId, keyword, showCompleted: ShowCompletedTasks);
            }

            Tasks.Clear();
            foreach (var t in tasks)
            {
                Tasks.Add(t);
            }

            await RebuildGroupsAsync();
        }
        catch (Exception ex)
        {
            _logger?.LogError(ex, "Failed to refresh tasks");
        }
        finally
        {
            IsLoading = false;
        }
    }

    /// <summary>重建分组（仅「全部」视图）。</summary>
    private async Task RebuildGroupsAsync()
    {
        Groups.Clear();
        if (!IsGrouped)
        {
            return;
        }

        var grouped = await _taskRepo.GroupTasksByListAsync(Tasks.ToList());
        // 按 Lists 顺序排列组，孤立项按 listId 排在后面
        var ordered = new List<(int ListId, TodoList? List, List<TaskItem> Items)>();
        foreach (var list in _listPane.Lists)
        {
            if (grouped.TryGetValue(list.Id, out var items))
            {
                ordered.Add((list.Id, list, items));
                grouped.Remove(list.Id);
            }
        }

        foreach (var kv in grouped.OrderBy(g => g.Key))
        {
            ordered.Add((kv.Key, null, kv.Value));
        }

        foreach (var (listId, list, items) in ordered)
        {
            Groups.Add(new TaskGroup(listId, list, items));
        }
    }

    // ---------------- 快速添加 ----------------

    /// <summary>快速添加任务（从输入框）。对应原版 quick-add 路径。
    /// 会用 DateParser.extractTimeCommand 提取日期命令。</summary>
    [RelayCommand]
    public async Task QuickAddAsync()
    {
        var raw = QuickAddText;
        if (string.IsNullOrWhiteSpace(raw) || !Main.IsDatabaseConnected)
        {
            return;
        }

        // 提取文本中的日期/时间命令
        var (text, timeCommand) = _dateParser.ExtractTimeCommand(raw);
        if (string.IsNullOrWhiteSpace(text))
        {
            text = raw.Trim();
        }

        // 解析日期命令
        string? dueDate = null;
        string? dueTime = null;
        if (timeCommand is not null)
        {
            var parsed = _dateParser.Parse(timeCommand);
            if (parsed is not null)
            {
                dueDate = DateParser.ExtractDateOnly(parsed);
                dueTime = DateParser.ExtractTimeOnly(parsed);
                // 纯日期命令（如 +1d）解析后时间为当前时刻，不显示时间
                if (timeCommand.StartsWith('+') && dueTime == "00:00")
                {
                    dueTime = null;
                }
            }
        }

        // 确定目标列表
        var targetListId = _listPane.SelectedList?.Id ?? (await _listRepo.GetDefaultListAsync())?.Id ?? 0;
        if (targetListId == 0)
        {
            Main.ErrorMessage = I18n.T("taskCreateListFirst");
            return;
        }

        var task = new TaskItem(
            id: 0,
            listId: targetListId,
            text: text,
            createdAt: DateTime.Now.ToString("o"),
            dueDate: dueDate,
            dueTime: dueTime);

        try
        {
            var newId = await _taskRepo.AddTaskAsync(task);
            task.Id = newId;
            Tasks.Insert(0, task);
            await _listPane.RefreshCountsAsync();
            QuickAddText = string.Empty;
            await RebuildGroupsAsync();
            Main.ShowTransientStatus(I18n.T("statusTaskAdded"));
        }
        catch (Exception ex)
        {
            _logger?.LogError(ex, "Failed to add task");
            Main.ErrorMessage = I18n.T("taskAddFailed", ex.Message);
        }
    }

    // ---------------- 任务操作 ----------------

    /// <summary>切换任务完成状态。</summary>
    [RelayCommand]
    public async Task ToggleCompletedAsync(TaskItem task)
    {
        try
        {
            await _taskRepo.ToggleTaskCompletedAsync(task.Id);
            task.Completed = !task.Completed;
            await _listPane.RefreshCountsAsync();
            // 完成态变化后可能需要重排（已完成沉底）
            await ReorderTasksAsync();
            Main.ShowTransientStatus(I18n.T("statusUpdateTaskState"));
        }
        catch (Exception ex)
        {
            _logger?.LogError(ex, "Failed to toggle task {Id}", task.Id);
        }
    }

    /// <summary>更新任务（行内编辑保存）。会提取日期命令。</summary>
    public async Task UpdateTaskTextAsync(TaskItem task, string newText)
    {
        var (text, timeCommand) = _dateParser.ExtractTimeCommand(newText);
        if (string.IsNullOrWhiteSpace(text))
        {
            text = newText.Trim();
        }

        task.Text = text;
        if (timeCommand is not null)
        {
            var parsed = _dateParser.Parse(timeCommand);
            if (parsed is not null)
            {
                task.DueDate = DateParser.ExtractDateOnly(parsed);
                task.DueTime = DateParser.ExtractTimeOnly(parsed);
                if (timeCommand.StartsWith('+') && task.DueTime == "00:00")
                {
                    task.DueTime = null;
                }
            }
        }

        await UpdateTaskAsync(task);
    }

    /// <summary>更新任务（含日期/时间/备注，来自详情对话框）。</summary>
    public async Task UpdateTaskAsync(TaskItem task)
    {
        try
        {
            await _taskRepo.UpdateTaskAsync(task);
            await _listPane.RefreshCountsAsync();
            await ReorderTasksAsync();
            Main.ShowTransientStatus(I18n.T("statusTaskUpdated"));
        }
        catch (Exception ex)
        {
            _logger?.LogError(ex, "Failed to update task {Id}", task.Id);
            Main.ErrorMessage = I18n.T("taskUpdateFailed", ex.Message);
        }
    }

    /// <summary>移动任务到其它列表。</summary>
    public async Task MoveTaskToListAsync(TaskItem task, int newListId)
    {
        task.ListId = newListId;
        try
        {
            await _taskRepo.UpdateTaskAsync(task);
            await _listPane.RefreshCountsAsync();
            await RefreshAsync();
            var list = _listPane.Lists.FirstOrDefault(l => l.Id == newListId);
            Main.ShowTransientStatus(I18n.T("statusTaskMoved", list?.Name ?? newListId.ToString()));
        }
        catch (Exception ex)
        {
            _logger?.LogError(ex, "Failed to move task {Id}", task.Id);
        }
    }

    /// <summary>删除任务。</summary>
    public async Task DeleteTaskAsync(TaskItem task)
    {
        try
        {
            await _taskRepo.DeleteTaskAsync(task.Id);
            Tasks.Remove(task);
            await _listPane.RefreshCountsAsync();
            await RebuildGroupsAsync();
            Main.ShowTransientStatus(I18n.T("statusTaskDeleted"));
        }
        catch (Exception ex)
        {
            _logger?.LogError(ex, "Failed to delete task {Id}", task.Id);
        }
    }

    // ---------------- 搜索 ----------------

    /// <summary>执行搜索。</summary>
    public async Task SearchAsync(string keyword)
    {
        SearchKeyword = keyword ?? string.Empty;
        await RefreshAsync();
    }

    // ---------------- showCompleted ----------------

    [RelayCommand]
    public async Task ToggleShowCompletedAsync()
    {
        ShowCompletedTasks = !ShowCompletedTasks;
        await RefreshAsync();
    }

    // ---------------- 视图描述（状态栏用）----------------

    /// <summary>当前视图的描述文本（用于状态栏持久显示）。</summary>
    public string GetViewDescription()
    {
        if (!string.IsNullOrEmpty(SearchKeyword))
        {
            return I18n.T("searchHint") + ": " + SearchKeyword;
        }

        return _listPane.CurrentView switch
        {
            TaskViewType.Today => I18n.T("statusShowToday"),
            TaskViewType.Planned => I18n.T("statusShowPlanned"),
            TaskViewType.All => I18n.T("statusShowAll"),
            TaskViewType.Completed => I18n.T("statusShowCompleted"),
            TaskViewType.List => _listPane.SelectedList is not null
                ? I18n.T("statusSwitchList", _listPane.SelectedList.Name)
                : I18n.T("statusShowAll"),
            _ => I18n.T("statusShowAll"),
        };
    }

    /// <summary>语言变更回调。</summary>
    public void OnLanguageChanged()
    {
        OnPropertyChanged(nameof(IsGrouped));
    }

    /// <summary>重排任务（已完成沉底）。仅在非分组视图下重排 Tasks。</summary>
    private async Task ReorderTasksAsync()
    {
        if (IsGrouped)
        {
            await RebuildGroupsAsync();
            return;
        }

        var ordered = Tasks.OrderBy(t => t.Completed ? 1 : 0).ToList();
        for (var i = 0; i < ordered.Count; i++)
        {
            var currentAt = Tasks.IndexOf(ordered[i]);
            if (currentAt != i)
            {
                Tasks.Move(currentAt, i);
            }
        }
    }

    // ---------------- XAML 绑定辅助属性 ----------------

    /// <summary>当前任务是否为空（用于显示空状态）。</summary>
    public bool IsEmpty => Tasks.Count == 0 && !IsLoading;

    /// <summary>是否显示空状态（有数据库连接但无任务）。</summary>
    public bool ShowEmptyState => IsEmpty && Main.IsDatabaseConnected;

    /// <summary>是否有任务。</summary>
    public bool HasTasks => Tasks.Count > 0;

    /// <summary>快速添加输入框提示文案。</summary>
    public string QuickAddHint => Main.IsDatabaseConnected ? I18n.T("taskListInputHint") : I18n.T("taskListInputHintNoDb");

    /// <summary>无数据库连接（用于空状态提示可见性）。</summary>
    public bool IsNotConnected => !Main.IsDatabaseConnected;

    /// <summary>数据库已连接（用于快速添加框可见性）。</summary>
    public bool IsConnected => Main.IsDatabaseConnected;
}

/// <summary>任务分组（「全部」视图按列表分组显示）。</summary>
public sealed class TaskGroup
{
    public int ListId { get; }
    public TodoList? List { get; }
    public ObservableCollection<TaskItem> Items { get; }

    public TaskGroup(int listId, TodoList? list, List<TaskItem> items)
    {
        ListId = listId;
        List = list;
        Items = new ObservableCollection<TaskItem>(items);
    }

    public string DisplayName => List?.Name ?? $"List {ListId}";
}
