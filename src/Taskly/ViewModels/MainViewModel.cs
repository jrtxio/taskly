using System.Globalization;
using System.Windows.Input;
using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using Microsoft.Extensions.Logging;
using Taskly.Data;
using Taskly.Models;
using Taskly.Services;

namespace Taskly.ViewModels;

/// <summary>
/// 主 ViewModel，对应原 Flutter 版 AppProvider。
/// 全局状态：数据库路径/连接状态、语言、暗色模式、侧边栏显隐、首次启动、状态栏消息、错误状态。
/// 协调 ListPaneViewModel 和 TaskPaneViewModel。
/// </summary>
public sealed partial class MainViewModel : ViewModelBase
{
    private readonly SQLiteDatabase _db;
    private readonly ConfigService _config;
    private readonly AppTheme _theme;
    private readonly ILogger<MainViewModel> _logger;
    private readonly ListPaneViewModel _listPane;
    private readonly TaskPaneViewModel _taskPane;
    private readonly DialogService _dialog;
    private CancellationTokenSource? _statusCts;

    public MainViewModel(
        SQLiteDatabase db,
        ConfigService config,
        AppTheme theme,
        I18nService i18n,
        ListPaneViewModel listPane,
        TaskPaneViewModel taskPane,
        DialogService dialog,
        ILogger<MainViewModel> logger)
    {
        _db = db;
        _config = config;
        _theme = theme;
        _logger = logger;
        _listPane = listPane;
        _taskPane = taskPane;
        _dialog = dialog;
        _i18n = i18n;

        i18n.LanguageChanged += OnLanguageChanged;
    }

    /// <summary>初始化：加载配置，尝试自动连接上次数据库。对应原版 AppProvider.init。</summary>
    public async Task InitializeAsync()
    {
        await _config.LoadAsync();

        // 应用语言
        var lang = _config.Language;
        I18n.SetLanguage(lang);

        // 应用主题（配置默认浅色，如需持久化可扩展）
        _theme.Apply(false);

        // 尝试自动连接上次数据库
        var lastDb = _config.LastDbPath;
        if (!string.IsNullOrEmpty(lastDb) && File.Exists(lastDb))
        {
            try
            {
                await OpenDatabaseAsync(lastDb);
            }
            catch (Exception ex)
            {
                _logger?.LogError(ex, "Failed to open last database: {Path}", lastDb);
                IsFirstLaunch = true;
            }
        }
        else
        {
            IsFirstLaunch = true;
        }
    }

    // ---------------- 数据库连接状态 ----------------

    [ObservableProperty]
    private string _databasePath = string.Empty;

    [ObservableProperty]
    private bool _isDatabaseConnected;

    [ObservableProperty]
    private bool _isFirstLaunch;

    partial void OnIsDatabaseConnectedChanged(bool value)
    {
        // 连接状态变化时通知子视图模型刷新
        if (value)
        {
            _ = RefreshAfterConnectAsync();
        }
        else
        {
            _listPane.Clear();
            _taskPane.Clear();
            _taskPane.NotifyConnectionChanged();
        }
    }

    /// <summary>数据库连接后的数据加载。对应原版 _loadInitialData。</summary>
    private async Task RefreshAfterConnectAsync()
    {
        await _listPane.LoadListsAsync();
        // 恢复上次选中的列表
        var lastListId = _config.LastSelectedListId;
        if (lastListId > 0)
        {
            await _listPane.SelectListAsync(lastListId);
        }
        else
        {
            await _listPane.SelectAllAsync();
        }

        await _listPane.RefreshCountsAsync();
        await _taskPane.RefreshAsync();
        ShowTransientStatus(I18n.T("statusDatabaseConnected"));
    }

    /// <summary>打开已有数据库文件。对应原版 openExistingDatabase。</summary>
    public async Task OpenDatabaseAsync(string path)
    {
        try
        {
            // 若已连接到其他数据库，先关闭，确保 IsDatabaseConnected 从 false→true
            // 翻转，从而触发 OnIsDatabaseConnectedChanged 刷新 UI。
            if (IsDatabaseConnected)
            {
                await CloseDatabaseAsync();
            }

            _db.SetDatabasePath(path);
            await _db.EnsureConnectedAsync();

            DatabasePath = path;
            IsDatabaseConnected = true;
            IsFirstLaunch = false;

            _config.LastDbPath = path;
            await _config.SaveAsync();
        }
        catch (Exception ex)
        {
            _logger?.LogError(ex, "Failed to open database: {Path}", path);
            ErrorMessage = ex.Message;
        }
    }

    /// <summary>新建数据库文件。对应原版 openNewDatabase。</summary>
    public async Task CreateDatabaseAsync(string path)
    {
        // 新建文件路径交给 SQLite 的 ReadWriteCreate 自动创建。
        // OpenDatabaseAsync 内部会先关闭旧库再打开新库。
        await OpenDatabaseAsync(path);
    }

    /// <summary>关闭数据库。对应原版 closeDatabase。</summary>
    public async Task CloseDatabaseAsync()
    {
        try
        {
            await _db.CloseAsync();
        }
        catch (Exception ex)
        {
            _logger?.LogError(ex, "Failed to close database");
        }

        IsDatabaseConnected = false;
        IsFirstLaunch = true;
        DatabasePath = string.Empty;
        _config.LastDbPath = string.Empty;
        await _config.SaveAsync();
        ShowTransientStatus(I18n.T("statusDatabaseClosed"));
    }

    // ---------------- 语言与主题 ----------------

    [ObservableProperty]
    private I18nService _i18n;

    /// <summary>切换语言并持久化。窗口内菜单即时刷新，无需重启。</summary>
    [RelayCommand]
    public async Task SetLanguageAsync(string language)
    {
        I18n.SetLanguage(language);
        _config.Language = language;
        await _config.SaveAsync();
    }

    private void OnLanguageChanged(object? sender, EventArgs e)
    {
        // 触发属性通知，让绑定 I18n 的 UI 刷新
        OnPropertyChanged(nameof(I18n));
        StatusMessage = GetPersistentStatus();
        _listPane.OnLanguageChanged();
        _taskPane.OnLanguageChanged();
    }

    [ObservableProperty]
    private bool _isDark;

    /// <summary>当前是否中文（菜单语言单选用）。</summary>
    public bool IsChinese => I18n.CurrentLanguage == Taskly.Services.I18nService.Chinese;

    /// <summary>切换明暗主题。</summary>
    [RelayCommand]
    public void ToggleTheme()
    {
        IsDark = !IsDark;
        _theme.Apply(IsDark);
    }

    // ---------------- 侧边栏 ----------------

    [ObservableProperty]
    private bool _isSidebarVisible = true;

    [RelayCommand]
    public void ToggleSidebar()
    {
        IsSidebarVisible = !IsSidebarVisible;
    }

    // ---------------- 状态栏 ----------------

    [ObservableProperty]
    private string _statusMessage = string.Empty;

    [ObservableProperty]
    private string? _errorMessage;

    /// <summary>显示瞬态状态消息（3 秒后恢复持久状态）。对应原版 _updateStatus。</summary>
    public void ShowTransientStatus(string message)
    {
        StatusMessage = message;
        _statusCts?.Cancel();
        _statusCts = new CancellationTokenSource();
        var token = _statusCts.Token;
        _ = Task.Delay(3000, token).ContinueWith(t =>
        {
            if (!t.IsCanceled)
            {
                StatusMessage = GetPersistentStatus();
            }
        }, TaskScheduler.Default);
    }

    /// <summary>持久状态：数据库状态 + 当前视图描述。</summary>
    public string GetPersistentStatus()
    {
        if (!IsDatabaseConnected)
        {
            return I18n.T("statusDatabaseNotConnected");
        }

        return _taskPane.GetViewDescription();
    }

    /// <summary>子视图模型调用，刷新持久状态显示。</summary>
    public void RefreshPersistentStatus()
    {
        if (_statusCts is null || _statusCts.IsCancellationRequested)
        {
            StatusMessage = GetPersistentStatus();
        }
    }

    /// <summary>刷新任务面板（ListPane 视图切换后调用）。</summary>
    public Task RefreshTaskPaneAsync() => _taskPane.RefreshAsync();
}
