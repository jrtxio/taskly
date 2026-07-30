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
/// 列表面板 ViewModel，对应原 Flutter 版 ListProvider。
/// 管理列表集合、选中列表、CRUD、各列表未完成计数。
/// </summary>
public sealed partial class ListPaneViewModel : ViewModelBase
{
    private readonly IListRepository _listRepo;
    private readonly ITaskRepository _taskRepo;
    private readonly SQLiteDatabase _db;
    private readonly ConfigService _config;
    private readonly ILogger<ListPaneViewModel> _logger;

    /// <summary>主 VM 引用（由 App 在创建后设置，避免构造循环依赖）。</summary>
    internal MainViewModel Main { get; set; } = null!;

    public ListPaneViewModel(
        IListRepository listRepo,
        ITaskRepository taskRepo,
        SQLiteDatabase db,
        ConfigService config,
        ILogger<ListPaneViewModel> logger)
    {
        _listRepo = listRepo;
        _taskRepo = taskRepo;
        _db = db;
        _config = config;
        _logger = logger;
    }

    /// <summary>所有列表。</summary>
    public ObservableCollection<TodoList> Lists { get; } = new();

    /// <summary>各列表未完成任务计数（listId → count）。</summary>
    public Dictionary<int, int> TaskCounts { get; } = new();

    [ObservableProperty]
    private TodoList? _selectedList;

    [ObservableProperty]
    private TaskViewType _currentView = TaskViewType.All;

    [ObservableProperty]
    private bool _isMyListsExpanded = true;

    // 智能视图计数
    [ObservableProperty]
    private int _todayCount;
    [ObservableProperty]
    private int _plannedCount;
    [ObservableProperty]
    private int _allCount;
    [ObservableProperty]
    private int _completedCount;

    partial void OnCurrentViewChanged(TaskViewType value)
    {
        // 切换到智能视图时清除列表选中
        if (value != TaskViewType.List)
        {
            SelectedList = null;
        }

        Main.RefreshPersistentStatus();
    }

    partial void OnSelectedListChanged(TodoList? value)
    {
        Main.RefreshPersistentStatus();
    }

    /// <summary>清空所有数据（数据库断开时）。</summary>
    public void Clear()
    {
        Lists.Clear();
        TaskCounts.Clear();
        SelectedList = null;
        CurrentView = TaskViewType.All;
        TodayCount = PlannedCount = AllCount = CompletedCount = 0;
    }

    /// <summary>加载所有列表。对应原版 loadLists。</summary>
    public async Task LoadListsAsync()
    {
        try
        {
            var lists = await _listRepo.GetAllListsAsync();
            Lists.Clear();
            foreach (var l in lists)
            {
                Lists.Add(l);
            }
        }
        catch (Exception ex)
        {
            _logger?.LogError(ex, "Failed to load lists");
        }
    }

    /// <summary>刷新所有计数（智能视图 + 各列表）。对应原版刷新 taskCounts。</summary>
    public async Task RefreshCountsAsync()
    {
        TodayCount = await _taskRepo.GetTodayTaskCountAsync();
        PlannedCount = await _taskRepo.GetPlannedTaskCountAsync();
        AllCount = await _taskRepo.GetIncompleteTaskCountAsync();
        CompletedCount = await _taskRepo.GetCompletedTaskCountAsync();

        TaskCounts.Clear();
        foreach (var list in Lists)
        {
            var count = await _taskRepo.GetTaskCountByListAsync(list.Id);
            TaskCounts[list.Id] = count;
            list.PendingCount = count;
        }
    }

    /// <summary>获取指定列表的未完成计数。</summary>
    public int GetCount(int listId) => TaskCounts.TryGetValue(listId, out var c) ? c : 0;

    // ---------------- 智能视图选择 ----------------

    [RelayCommand]
    public async Task SelectTodayAsync()
    {
        CurrentView = TaskViewType.Today;
        Main.ShowTransientStatus(I18n.T("statusShowToday"));
        await Main.RefreshTaskPaneAsync();
    }

    [RelayCommand]
    public async Task SelectPlannedAsync()
    {
        CurrentView = TaskViewType.Planned;
        Main.ShowTransientStatus(I18n.T("statusShowPlanned"));
        await Main.RefreshTaskPaneAsync();
    }

    [RelayCommand]
    public async Task SelectAllAsync()
    {
        CurrentView = TaskViewType.All;
        Main.ShowTransientStatus(I18n.T("statusShowAll"));
        await Main.RefreshTaskPaneAsync();
    }

    [RelayCommand]
    public async Task SelectCompletedAsync()
    {
        CurrentView = TaskViewType.Completed;
        Main.ShowTransientStatus(I18n.T("statusShowCompleted"));
        await Main.RefreshTaskPaneAsync();
    }

    /// <summary>选中某个列表。对应原版 selectList。</summary>
    public async Task SelectListAsync(int listId)
    {
        var list = Lists.FirstOrDefault(l => l.Id == listId);
        if (list is null)
        {
            await SelectAllAsync();
            return;
        }

        SelectedList = list;
        CurrentView = TaskViewType.List;
        _config.LastSelectedListId = listId;
        await _config.SaveAsync();
        Main.ShowTransientStatus(I18n.T("statusSwitchList", list.Name));
        await Main.RefreshTaskPaneAsync();
    }

    [RelayCommand]
    public async Task SelectList(TodoList list) => await SelectListAsync(list.Id);

    // ---------------- 列表 CRUD ----------------

    /// <summary>创建列表。</summary>
    public async Task<TodoList?> CreateListAsync(string name, string? icon = null, int? color = null)
    {
        try
        {
            var id = await _listRepo.AddListAsync(name, icon, color);
            var list = await _listRepo.GetListByIdAsync(id);
            if (list is not null)
            {
                Lists.Add(list);
                TaskCounts[list.Id] = 0;
            }

            Main.ShowTransientStatus(I18n.T("statusCreateList", list?.Name ?? name));
            return list;
        }
        catch (Exception ex)
        {
            _logger?.LogError(ex, "Failed to create list");
            Main.ErrorMessage = ex.Message;
            return null;
        }
    }

    /// <summary>更新列表（重命名 + 图标 + 颜色）。</summary>
    public async Task<bool> UpdateListAsync(TodoList list, string name, string? icon, int? color,
        bool clearIcon, bool clearColor)
    {
        try
        {
            await _listRepo.UpdateListAsync(list.Id, name, icon, color, clearIcon, clearColor);
            // 更新本地集合中的对应项
            var idx = Lists.IndexOf(list);
            if (idx >= 0)
            {
                Lists[idx] = list.With(name: name, icon: icon, color: color is not null ? Avalonia.Media.Color.FromUInt32((uint)color.Value) : null,
                    clearIcon: clearIcon, clearColor: clearColor, hasIcon: icon is not null, hasColor: color is not null);
            }

            return true;
        }
        catch (Exception ex)
        {
            _logger?.LogError(ex, "Failed to update list");
            Main.ErrorMessage = ex.Message;
            return false;
        }
    }

    /// <summary>删除列表（级联删除任务）。</summary>
    public async Task<bool> DeleteListAsync(TodoList list)
    {
        try
        {
            await _listRepo.DeleteListAsync(list.Id);
            Lists.Remove(list);
            TaskCounts.Remove(list.Id);

            // 若删除的是当前选中列表，切回全部
            if (SelectedList?.Id == list.Id)
            {
                await SelectAllAsync();
            }

            Main.ShowTransientStatus(I18n.T("statusDeleteList"));
            return true;
        }
        catch (Exception ex)
        {
            _logger?.LogError(ex, "Failed to delete list");
            Main.ErrorMessage = ex.Message;
            return false;
        }
    }

    /// <summary>语言变更回调（刷新绑定文案）。</summary>
    public void OnLanguageChanged()
    {
        // 触发集合相关属性刷新
        OnPropertyChanged(nameof(Lists));
    }

    [RelayCommand]
    private void ToggleMyLists()
    {
        IsMyListsExpanded = !IsMyListsExpanded;
    }
}
