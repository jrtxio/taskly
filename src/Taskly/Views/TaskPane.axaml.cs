using Avalonia.Controls;
using Avalonia.Input;
using Avalonia.Interactivity;
using Microsoft.Extensions.DependencyInjection;
using Taskly.ViewModels;

namespace Taskly.Views;

/// <summary>
/// 主内容区控件，对应原 Flutter 版 widgets/task_list_view.dart。
/// 标题栏 + 快速添加 + 任务列表/分组。
/// </summary>
public partial class TaskPane : UserControl
{
    private Services.I18nService? _i18n;

    public TaskPane()
    {
        InitializeComponent();
    }

    public TaskPaneViewModel? ViewModel => DataContext as TaskPaneViewModel;

    public void Init(TaskPaneViewModel vm)
    {
        DataContext = vm;
        _i18n = App.Services.GetRequiredService<Services.I18nService>();
        _i18n.LanguageChanged += OnLanguageChanged;
        ApplyLanguage();
        vm.PropertyChanged += (s, e) =>
        {
            if (e.PropertyName == nameof(TaskPaneViewModel.ShowCompletedTasks))
            {
                UpdateShowCompletedLabel();
            }
        };
    }

    private void OnLanguageChanged(object? sender, EventArgs e)
    {
        ApplyLanguage();
        UpdateShowCompletedLabel();
    }

    private void ApplyLanguage()
    {
        if (_i18n is not null)
        {
            NoDbHint.Text = _i18n.T("taskListEmptyHint");
            EmptyText.Text = _i18n.T("taskListEmpty");
            UpdateSidebarTooltip();
        }
    }

    /// <summary>根据侧边栏当前显隐状态更新切换按钮的 tooltip 文案。</summary>
    private void UpdateSidebarTooltip()
    {
        if (_i18n is null)
        {
            return;
        }

        var main = App.Services.GetRequiredService<MainViewModel>();
        // 侧边栏可见时按钮意图是「隐藏」，反之「显示」
        ToolTip.SetTip(SidebarToggleBtn, main.IsSidebarVisible
            ? _i18n.T("sidebarHide")
            : _i18n.T("sidebarShow"));
    }

    private void UpdateShowCompletedLabel()
    {
        if (_i18n is not null && ViewModel is not null)
        {
            ShowCompletedLabel.Text = ViewModel.ShowCompletedTasks
                ? _i18n.T("hideCompletedToggle")
                : _i18n.T("showCompletedToggle");
        }
    }

    /// <summary>快速添加回车提交。</summary>
    public void OnQuickAddKeyDown(object? sender, KeyEventArgs e)
    {
        if (e.Key == Key.Enter && ViewModel is not null)
        {
            _ = ViewModel.QuickAddCommand.ExecuteAsync(null);
            e.Handled = true;
        }
    }

    /// <summary>侧边栏切换按钮（通过全局 MainViewModel 命令）。</summary>
    public void OnToggleSidebar(object? sender, RoutedEventArgs e)
    {
        App.Services.GetRequiredService<MainViewModel>().ToggleSidebar();
        UpdateSidebarTooltip();
    }

    /// <summary>显示/隐藏已完成切换。</summary>
    public void OnToggleShowCompleted(object? sender, RoutedEventArgs e)
    {
        _ = ViewModel?.ToggleShowCompletedCommand.ExecuteAsync(null);
    }
}
