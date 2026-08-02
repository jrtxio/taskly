using Avalonia.Controls;
using Avalonia.Input;
using Avalonia.Interactivity;
using Avalonia.Platform.Storage;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Taskly.Services;
using Taskly.ViewModels;

using NativeMenuItem = Avalonia.Controls.NativeMenuItem;
using NativeMenu = Avalonia.Controls.NativeMenu;

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

    // macOS 系统菜单栏的 NativeMenuItem 引用（用于 i18n 更新文案 + 勾选态）
    private NativeMenuItem? _nativeFile, _nativeNewDb, _nativeOpenDb, _nativeCloseDb, _nativeExit;
    private NativeMenuItem? _nativeSettings, _nativeLang, _nativeLangZh, _nativeLangEn, _nativeDarkMode;
    private NativeMenuItem? _nativeHelp, _nativeAbout;
    private NativeMenu? _nativeTop;
    private bool _nativeMenuBuilt;
    private readonly bool _useNativeMenu = OperatingSystem.IsMacOS();

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

        // macOS 打包成 .app 后用系统菜单栏（NativeMenu）；但 dotnet run 开发期无 bundle，
        // NativeMenu 不生效，因此始终显示窗口内 Menu 作为可靠后备。
        // NativeMenu 代码保留，打包发布时自然接管系统菜单栏。
        if (_useNativeMenu)
        {
            try
            {
                var lang = ReadLanguageFromConfig();
                _i18n.SetLanguage(lang);
                BuildNativeMenuItems();
                _nativeMenuBuilt = true;
            }
            catch { }
        }

        // 监听侧边栏显隐，平滑调整列宽（收起后任务区占满）
        _lastSidebarWidth = 280;
        main.PropertyChanged += OnMainPropertyChanged;

        Opened += OnOpened;
    }

    private double _lastSidebarWidth;

    /// <summary>侧边栏显隐变化时，调整 Grid 列宽。
    /// 收起时 Width 和 MinWidth 都归零（仅 Width=0 会被 MinWidth=200 钳制，列不会真消失）。</summary>
    private void OnMainPropertyChanged(object? sender, System.ComponentModel.PropertyChangedEventArgs e)
    {
        if (e.PropertyName != nameof(MainViewModel.IsSidebarVisible) || _main is null)
        {
            return;
        }

        // 第一列是侧边栏列，第二列是分割线列
        var sidebarCol = ContentGrid.ColumnDefinitions[0];
        var splitterCol = ContentGrid.ColumnDefinitions[1];

        if (_main.IsSidebarVisible)
        {
            // 展开：恢复 MinWidth 约束 + 记住的宽度 + 显示分割线
            sidebarCol.MinWidth = 200;
            sidebarCol.Width = new GridLength(_lastSidebarWidth);
            splitterCol.Width = GridLength.Auto;
            Splitter.IsVisible = true;
            ListPaneControl.IsVisible = true;
        }
        else
        {
            // 收起：先记住当前宽度，再把两列都归零、隐藏，让任务区占满
            if (sidebarCol.Width.IsAbsolute)
            {
                _lastSidebarWidth = sidebarCol.Width.Value;
            }
            sidebarCol.MinWidth = 0;
            sidebarCol.Width = new GridLength(0);
            splitterCol.Width = new GridLength(0);
            Splitter.IsVisible = false;
            ListPaneControl.IsVisible = false;
        }
    }

    private void OnLanguageChanged(object? sender, EventArgs e) => ApplyLanguage();

    /// <summary>构建 macOS 系统菜单栏（NativeMenu）。结构与窗口内 Menu 对等。
    /// 幂等：首次构建并 SetMenu；后续调用（语言切换）只更新已有 item 的 Header 和勾选态，
    /// 避免 SetMenu 传新对象导致 "menu does not match" 崩溃。
    /// 异步：内部 await config 加载（不能在 UI 线程用 GetAwaiter().GetResult() 否则死锁）。</summary>
    private async Task SetupNativeMenuAsync()
    {
        if (_i18n is null)
        {
            return;
        }

        // 已构建过：只更新文案/勾选态
        if (_nativeMenuBuilt)
        {
            UpdateNativeMenuText();
            return;
        }

        // 确保 config 已加载 + 语言已应用（独立于 InitializeAsync 的数据库打开，避免被慢操作阻塞）
        var cfg = App.Services.GetRequiredService<Data.ConfigService>();
        await cfg.LoadAsync();
        _i18n.SetLanguage(cfg.Language);

        _nativeMenuBuilt = true;
        BuildNativeMenuItems();
    }

    /// <summary>构建 NativeMenuItem 对象并装配（用当前 _i18n 语言）。</summary>
    private void BuildNativeMenuItems()
    {
        if (_i18n is null)
        {
            return;
        }

        // 文件菜单
        _nativeNewDb = NewNativeItem(_i18n.T("menuNewDatabase"), (s, e) => OnMenuNewDb(s, new RoutedEventArgs()), "Cmd+N");
        _nativeOpenDb = NewNativeItem(_i18n.T("menuOpenDatabase"), (s, e) => OnMenuOpenDb(s, new RoutedEventArgs()), "Cmd+O");
        _nativeCloseDb = NewNativeItem(_i18n.T("menuCloseDatabase"), (s, e) => OnMenuCloseDb(s, new RoutedEventArgs()), "Cmd+W");
        _nativeExit = NewNativeItem(_i18n.T("menuExit"), (s, e) => OnMenuExit(s, new RoutedEventArgs()), "Cmd+Q");
        _nativeFile = new NativeMenuItem { Header = _i18n.T("menuFile"), Menu = new NativeMenu() };
        _nativeFile.Menu!.Items.Add(_nativeNewDb);
        _nativeFile.Menu!.Items.Add(_nativeOpenDb);
        _nativeFile.Menu!.Items.Add(_nativeCloseDb);
        _nativeFile.Menu!.Items.Add(new NativeMenuItemSeparator());
        _nativeFile.Menu!.Items.Add(_nativeExit);

        // 设置菜单
        _nativeLangZh = new NativeMenuItem
        {
            Header = _i18n.T("menuLangZh"),
            ToggleType = NativeMenuItemToggleType.Radio,
            IsChecked = _main?.IsChinese ?? true,
        };
        _nativeLangZh.Click += (s, e) => OnMenuLangZh(s, new RoutedEventArgs());
        _nativeLangEn = new NativeMenuItem
        {
            Header = _i18n.T("menuLangEn"),
            ToggleType = NativeMenuItemToggleType.Radio,
            IsChecked = !(_main?.IsChinese ?? true),
        };
        _nativeLangEn.Click += (s, e) => OnMenuLangEn(s, new RoutedEventArgs());
        _nativeLang = new NativeMenuItem { Header = _i18n.T("menuLanguage"), Menu = new NativeMenu() };
        _nativeLang.Menu!.Items.Add(_nativeLangZh);
        _nativeLang.Menu!.Items.Add(_nativeLangEn);

        _nativeDarkMode = new NativeMenuItem
        {
            Header = _i18n.T("menuDarkMode"),
            ToggleType = NativeMenuItemToggleType.CheckBox,
            IsChecked = _main?.IsDark ?? false,
        };
        _nativeDarkMode.Click += (s, e) => OnMenuToggleTheme(s, new RoutedEventArgs());
        _nativeSettings = new NativeMenuItem { Header = _i18n.T("menuSettings"), Menu = new NativeMenu() };
        _nativeSettings.Menu!.Items.Add(_nativeLang);
        _nativeSettings.Menu!.Items.Add(_nativeDarkMode);

        // 帮助菜单
        _nativeAbout = NewNativeItem(_i18n.T("menuAbout"), (s, e) => OnMenuAbout(s, new RoutedEventArgs()));
        _nativeHelp = new NativeMenuItem { Header = _i18n.T("menuHelp"), Menu = new NativeMenu() };
        _nativeHelp.Menu!.Items.Add(_nativeAbout);

        // 装配到窗口（macOS 渲染到系统菜单栏）
        _nativeTop = new NativeMenu();
        _nativeTop.Items.Add(_nativeFile);
        _nativeTop.Items.Add(_nativeSettings);
        _nativeTop.Items.Add(_nativeHelp);

        // 订阅 NeedsUpdate：macOS 在菜单即将显示时触发，此时改标题（含顶级）能可靠刷新。
        // 这绕过了"语言切换后改 Header 不立即生效"的局限。
        _nativeTop.NeedsUpdate += OnNativeMenuNeedsUpdate;

        // 挂到 Application 而非 Window：macOS 上 Application 级 NativeMenu 才是主菜单栏
        NativeMenu.SetMenu(Avalonia.Application.Current, _nativeTop);
    }

    /// <summary>菜单即将显示时，按当前语言同步所有标题（含顶级）。</summary>
    private void OnNativeMenuNeedsUpdate(object? sender, EventArgs e)
    {
        UpdateNativeMenuText();
    }

    /// <summary>更新 macOS NativeMenu 各 item 的文案和勾选态（语言切换时调用）。
    /// 只改属性不重建对象——native exporter 会监听 Header 变化自动刷新。</summary>
    private void UpdateNativeMenuText()
    {
        if (_i18n is null)
        {
            return;
        }

        if (_nativeFile is not null) _nativeFile.Header = _i18n.T("menuFile");
        if (_nativeNewDb is not null) _nativeNewDb.Header = _i18n.T("menuNewDatabase");
        if (_nativeOpenDb is not null) _nativeOpenDb.Header = _i18n.T("menuOpenDatabase");
        if (_nativeCloseDb is not null) _nativeCloseDb.Header = _i18n.T("menuCloseDatabase");
        if (_nativeExit is not null) _nativeExit.Header = _i18n.T("menuExit");
        if (_nativeSettings is not null) _nativeSettings.Header = _i18n.T("menuSettings");
        if (_nativeLang is not null) _nativeLang.Header = _i18n.T("menuLanguage");
        if (_nativeLangZh is not null) _nativeLangZh.Header = _i18n.T("menuLangZh");
        if (_nativeLangEn is not null) _nativeLangEn.Header = _i18n.T("menuLangEn");
        if (_nativeDarkMode is not null) _nativeDarkMode.Header = _i18n.T("menuDarkMode");
        if (_nativeHelp is not null) _nativeHelp.Header = _i18n.T("menuHelp");
        if (_nativeAbout is not null) _nativeAbout.Header = _i18n.T("menuAbout");

        var isZh = _i18n.CurrentLanguage == I18nService.Chinese;
        if (_nativeLangZh is not null) _nativeLangZh.IsChecked = isZh;
        if (_nativeLangEn is not null) _nativeLangEn.IsChecked = !isZh;
        if (_nativeDarkMode is not null && _main is not null) _nativeDarkMode.IsChecked = _main.IsDark;
    }

    /// <summary>同步读 config.ini 的 language（构造函数用，不走 async）。</summary>
    private static string ReadLanguageFromConfig()
    {
        try
        {
            var path = Data.PathUtils.GetConfigPath();
            if (File.Exists(path))
            {
                foreach (var raw in File.ReadAllLines(path))
                {
                    var line = raw.Trim();
                    if (line.StartsWith("language", StringComparison.OrdinalIgnoreCase))
                    {
                        var eq = line.IndexOf('=');
                        if (eq > 0)
                        {
                            var v = line[(eq + 1)..].Trim();
                            if (v == "en" || v == "zh") return v;
                        }
                    }
                }
            }
        }
        catch { }
        return "zh";
    }

    /// <summary>便捷构造一个带 Click 的 NativeMenuItem。</summary>
    private static NativeMenuItem NewNativeItem(string header, EventHandler onClick, string? gesture = null)
    {
        var item = new NativeMenuItem { Header = header };
        if (gesture is not null)
        {
            item.Gesture = KeyGesture.Parse(gesture);
        }
        item.Click += onClick;
        return item;
    }

    /// <summary>应用当前语言的菜单文案。中文为设计期默认值，切换到英文时覆盖。
    /// 同时更新窗口内 Menu 和 macOS NativeMenu 的文案。</summary>
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
        MenuTools.Header = _i18n.T("menuTools");
        MenuInstallCli.Header = _i18n.T("menuInstallCli");
        MenuUninstallCli.Header = _i18n.T("menuUninstallCli");

        // macOS NativeMenu：首次构建已在 OnOpened 完成（正确的语言），
        // 语言切换时只需更新文案/勾选态（顶级标题运行时刷新受限，需重启）。
        if (_useNativeMenu && _nativeMenuBuilt)
        {
            UpdateNativeMenuText();
        }
    }

    private async void OnOpened(object? sender, EventArgs e)
    {
        if (_main is null)
        {
            return;
        }

        try
        {
            // macOS NativeMenu 已在构造函数里同步构建（保证窗口创建时就挂上）
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

        var dialog = new Views.Dialogs.ConfirmDialog(
            _i18n.T("dialogConfirmCloseDb"),
            _i18n.T("dialogConfirmCloseDbContent"),
            _i18n.T("dialogConfirm"),
            _i18n.T("dialogCancel"));
        await dialog.ShowDialog(this);

        if (dialog.Result)
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
            SuggestedFileName = "tasks",
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

    // ---------------- 命令行工具安装 ----------------
    private void OnMenuInstallCli(object? sender, Avalonia.Interactivity.RoutedEventArgs e) => _ = InstallCliAsync(install: true);
    private void OnMenuUninstallCli(object? sender, Avalonia.Interactivity.RoutedEventArgs e) => _ = InstallCliAsync(install: false);

    private async Task InstallCliAsync(bool install)
    {
        if (_i18n is null)
        {
            return;
        }

        var result = install ? Cli.CliInstaller.Install() : Cli.CliInstaller.Uninstall();

        var title = install ? _i18n.T("menuInstallCli") : _i18n.T("menuUninstallCli");
        await new Views.Dialogs.ConfirmDialog(
            title,
            result.Message + (result.NeedsShellRestart ? "\n\n请打开新的终端窗口使更改生效。" : ""),
            _i18n.T("dialogConfirm"),
            _i18n.T("dialogCancel")).ShowDialog<bool>(this);
    }

    private async Task ShowAboutAsync()
    {
        if (_i18n is null)
        {
            return;
        }

        var about = $"Taskly v0.2.1\n© 2026 Taskly Team\n\n{_i18n.T("aboutContent")}";
        await new Views.Dialogs.ConfirmDialog(
            _i18n.T("menuAbout"), about,
            _i18n.T("dialogConfirm"), _i18n.T("dialogCancel")).ShowDialog<bool>(this);
    }
}
