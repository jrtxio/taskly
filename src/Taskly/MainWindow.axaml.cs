using Avalonia.Controls;
using Avalonia.Platform.Storage;
using Microsoft.Extensions.Logging;
using Taskly.Services;
using Taskly.ViewModels;

namespace Taskly;

/// <summary>
/// 主窗口，对应原 Flutter 版 MainScreen。
/// 顶部菜单 + 左侧栏 + 主内容区 + 底部状态栏。
/// </summary>
public partial class MainWindow : Window
{
    private MainViewModel? _main;
    private I18nService? _i18n;
    private ILogger<MainWindow>? _logger;

    public MainWindow()
    {
        InitializeComponent();
    }

    public MainWindow(
        MainViewModel main,
        ListPaneViewModel listPane,
        TaskPaneViewModel taskPane,
        I18nService i18n,
        AppTheme theme,
        DialogService dialog,
        ILogger<MainWindow> logger)
    {
        InitializeComponent();

        _main = main;
        _i18n = i18n;
        _logger = logger;

        DataContext = main;

        // 初始化子控件（DataContext 直接绑定各自 VM）
        ListPaneControl.Init(listPane);
        TaskPaneControl.Init(taskPane);

        Width = 1024;
        Height = 768;
        MinWidth = 760;
        MinHeight = 520;

        // 菜单文案本地化 + 监听语言切换
        ApplyLanguage();
        i18n.LanguageChanged += OnLanguageChanged;

        Opened += OnOpened;
    }

    private void OnLanguageChanged(object? sender, EventArgs e) => ApplyLanguage();

    /// <summary>应用当前语言的菜单文案。中文为设计期默认值，切换到英文时覆盖。</summary>
    private void ApplyLanguage()
    {
        if (_i18n is null)
        {
            return;
        }

        MenuFile.Header = _i18n.T("menuFile");
        MenuNewDatabase.Header = _i18n.T("menuNewDatabase");
        MenuOpenDatabase.Header = _i18n.T("menuOpenDatabase");
        MenuCloseDatabase.Header = _i18n.T("menuCloseDatabase");
        MenuExit.Header = _i18n.T("menuExit");
        MenuSettings.Header = _i18n.T("menuSettings");
        MenuLanguage.Header = _i18n.T("menuLanguage");
        MenuLangZh.Header = _i18n.T("menuLangZh");
        MenuLangEn.Header = _i18n.T("menuLangEn");
        MenuDarkMode.Header = _i18n.T("menuDarkMode");
        MenuHelp.Header = _i18n.T("menuHelp");
        MenuAbout.Header = _i18n.T("menuAbout");
    }

    private async void OnOpened(object? sender, EventArgs e)
    {
        if (_main is null)
        {
            return;
        }

        try
        {
            await _main.InitializeAsync();
        }
        catch (Exception ex)
        {
            _logger?.LogError(ex, "Failed to initialize");
        }
    }

    // ---------------- 文件菜单命令 ----------------
    public async Task NewDatabaseAsync()
    {
        if (_main is null)
        {
            return;
        }

        var path = await PickSaveDbPathAsync();
        if (path is null)
        {
            return;
        }

        await _main.CreateDatabaseAsync(path);
    }

    public async Task OpenDatabaseAsync()
    {
        if (_main is null)
        {
            return;
        }

        var path = await PickOpenDbPathAsync();
        if (path is null)
        {
            return;
        }

        await _main.OpenDatabaseAsync(path);
    }

    public async Task CloseDatabaseAsync()
    {
        if (_main is null || !_main.IsDatabaseConnected || _i18n is null)
        {
            return;
        }

        var ok = await new Views.Dialogs.ConfirmDialog(
            _i18n.T("dialogConfirmCloseDb"),
            _i18n.T("dialogConfirmCloseDbContent"),
            _i18n.T("dialogConfirm"),
            _i18n.T("dialogCancel")).ShowDialog<bool>(this);

        if (ok)
        {
            await _main.CloseDatabaseAsync();
        }
    }

    private async Task<string?> PickSaveDbPathAsync()
    {
        var file = await StorageProvider.SaveFilePickerAsync(new FilePickerSaveOptions
        {
            Title = _i18n?.T("dialogSaveDbTitle") ?? "Save Database File",
            DefaultExtension = "db",
            SuggestedFileName = "tasks.db",
            FileTypeChoices = new[] { new FilePickerFileType("Database") { Patterns = new[] { "*.db" } } },
        });
        return file?.Path.LocalPath;
    }

    private async Task<string?> PickOpenDbPathAsync()
    {
        var files = await StorageProvider.OpenFilePickerAsync(new FilePickerOpenOptions
        {
            Title = _i18n?.T("dialogSelectDbFile") ?? "Select Database File",
            AllowMultiple = false,
            FileTypeFilter = new[] { new FilePickerFileType("Database") { Patterns = new[] { "*.db" } } },
        });
        return files.Count > 0 ? files[0].Path.LocalPath : null;
    }

    // ---------------- 菜单事件 ----------------
    private void OnMenuNewDb(object? sender, Avalonia.Interactivity.RoutedEventArgs e) => _ = NewDatabaseAsync();
    private void OnMenuOpenDb(object? sender, Avalonia.Interactivity.RoutedEventArgs e) => _ = OpenDatabaseAsync();
    private void OnMenuCloseDb(object? sender, Avalonia.Interactivity.RoutedEventArgs e) => _ = CloseDatabaseAsync();
    private void OnMenuExit(object? sender, Avalonia.Interactivity.RoutedEventArgs e) => Close();
    private void OnMenuLangZh(object? sender, Avalonia.Interactivity.RoutedEventArgs e) => _ = _main?.SetLanguageAsync("zh");
    private void OnMenuLangEn(object? sender, Avalonia.Interactivity.RoutedEventArgs e) => _ = _main?.SetLanguageAsync("en");
    private void OnMenuToggleTheme(object? sender, Avalonia.Interactivity.RoutedEventArgs e) => _main?.ToggleTheme();
    private void OnMenuAbout(object? sender, Avalonia.Interactivity.RoutedEventArgs e) => _ = ShowAboutAsync();

    private async Task ShowAboutAsync()
    {
        if (_i18n is null)
        {
            return;
        }

        var about = $"Taskly v0.0.2\n© 2025 Taskly Team\n\n{_i18n.T("aboutContent")}";
        await new Views.Dialogs.ConfirmDialog(
            _i18n.T("menuAbout"), about,
            _i18n.T("dialogConfirm"), _i18n.T("dialogCancel")).ShowDialog<bool>(this);
    }
}
